//
//  AppDelegate.swift
//  NingoSdk
//
//  Created by David Young on 1/1/18.
//

import UIKit
import NingoSdk
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {
    
    var window: UIWindow?
    var log: String = ""
    var eventTextView: UITextView?
    var locationManager: CLLocationManager?
    var lastLocation: CLLocation?
    var nearbyNingoBeacons: [Beacon] = []
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        NSLog("NingoSdkReferenceApp started up.")
        // WARNING:  Do not use this authToken in your own app.  It is rate limited
        // and subject to being disabled at any time without notice.
        // See the README in the project root for instructions on how to generate
        // your own authToken.
        Settings().saveSetting(key: Settings.ningoReadonlyApiTokenKey, value: "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxLCJ3cml0ZWFibGUiOmZhbHNlLCJleHAiOjQ2NjkwMjk2NTF9.2aHrvak4hwpuuvi9uOS9jwtf3ZPXd6nOSOXbDfW9Onk")
        
        // Significant location changes (e.g. cell tower changes) are used to determine when we need
        // to re-query for nearby beacons from ne Ningo API and start monitoring for those beacon UUIDs
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.startMonitoringSignificantLocationChanges()
        if let location = locationManager?.location {
            lastLocation = location
            self.updateNearbyNingoBeacons()
        }
        
        return true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        NSLog("Updated location")
        lastLocation = locations.last!
        updateNearbyNingoBeacons()
    }
    
    func updateNearbyNingoBeacons() {
        let queryClient = QueryBeaconClient(authToken: Settings().getSetting(key: Settings.ningoReadonlyApiTokenKey)!)
        queryClient.query(latitude: lastLocation!.coordinate.latitude, longitude: lastLocation!.coordinate.longitude, radiusMeters: 100) { (beacons, errorCode, errorDetail) in
            if let beacons = beacons {
                self.nearbyNingoBeacons = beacons
            }
        }
        // Get up to 1000 beacon ProximityUUIDs within 10km from our current location, so we can use these for beacon ranging
        let latitude = lastLocation!.coordinate.latitude // 37.3525862 // 38.93
        let longitude = lastLocation!.coordinate.latitude // -122.0496097//  //-77.22
        queryClient.queryFirstIdentifiers(latitude: latitude, longitude: longitude, radiusMeters: 1000, limit: 100) { (proximityUUIDStrings, errorCode, errorDetail) in
            if let proximityUUIDStrings = proximityUUIDStrings {
                NSLog("There are now \(proximityUUIDStrings.count) nearby beacon uuids")
                if proximityUUIDStrings.count > 0 {
                    BeaconTracker.shared.updateTransientUuids(uuids: proximityUUIDStrings)
                }
            }
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
}

