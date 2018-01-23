//
//  AppDelegate.swift
//  NingoSdk
//
//  Created by David Young on 1/1/18.
//

import UIKit
import NingoSdk

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var log: String = ""
    var eventTextView: UITextView?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        NSLog("NingoSdkReferenceApp started up.")
        Settings().saveSetting(key: Settings.ningoReadonlyApiTokenKey, value: "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxLCJ3cml0ZWFibGUiOmZhbHNlLCJleHAiOjQ2NjkwMjk2NTF9.2aHrvak4hwpuuvi9uOS9jwtf3ZPXd6nOSOXbDfW9Onk")
        
        let authClient = AuthenticationClient()
        authClient.authenticate(email: "david@radiusnetworks.com", password: "Test1234") { (authToken, error) in
            if let error = error {
                NSLog("Error logging in: \(error)")
            }
            else {
                NSLog("Got an auth token: \(authToken!)")
                let getBeaconClient = GetBeaconClient(authToken: authToken!)
                getBeaconClient.get(identifier: "2F234454-CF6D-4A0F-ADF2-F4911BA9FFA6_1_1_ibeacon", completionHandler: { (beacon, errorCode, errorDescription) in
                    if beacon != nil {
                        NSLog("Got beacon: \(beacon!.identifier)")
                        let postBeaconClient = PostBeaconClient(authToken: authToken!)
                        postBeaconClient.post(beacon: beacon!, completionHandler: { (beacon, errorCode, errorDescription) in
                            if beacon != nil {
                                NSLog("Updated beacon: \(beacon!.identifier)")
                            }
                            else {
                                NSLog("Error updating beacon: \(errorCode!)")
                            }
                        })

                    }
                    else {
                        NSLog("Error getting beacon: \(errorCode!)")
                    }
                })
                let queryBeaconClient = QueryBeaconClient(authToken: authToken!)
                queryBeaconClient.query(latitude: 38.93, longitude: -77.28, radiusMeters: 20000.0, completionHandler: { (beacons, errorCode, errorDescription) in
                    if beacons != nil {
                        NSLog("Got beacons: \(beacons!.first!.identifier)")
                    }
                    else {
                        NSLog("Error getting beacon: \(errorCode!)")
                    }
                })
            }
        }
                
        return true
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

