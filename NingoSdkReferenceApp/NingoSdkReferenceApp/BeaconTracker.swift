//
//  BeaconTracker.swift
//  BeaconScanner
//
//  Created by David G. Young on 1/12/18.
//

import CoreLocation
import UIKit

class BeaconTracker: NSObject, CLLocationManagerDelegate {
    static let shared = BeaconTracker()
    let MaxTrackingSecs = 5.0
    var trackedBeacons: [String:TrackedBeacon] = [:]
    var locationManager: CLLocationManager!
    var uuids: [String] = ["2F234454-CF6D-4A0F-ADF2-F4911BA9FFA6"]
    var started = false
    
    override init() {
        super.init()
    }
    
    public func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        for beacon in beacons {
            track(beacon: beacon)
        }
        NotificationCenter.default.post(name: NSNotification.Name("beacons_updated"), object: nil)
    }

    func addUuids(uuids: [String]) {
        var newUuids: [String] = []
        newUuids.append(contentsOf: uuids)
        for uuid in uuids {
            let uuid = uuid.uppercased()
            if uuids.contains(uuid) {
                print("already tracking \(uuid)")
                continue
            }
            if UUID(uuidString: uuid) == nil {
                print("invalid uuid \(uuid)")
                continue
            }
        }
        newUuids.append(contentsOf: uuids)
        let wasStarted = started
        if started {
            stop()
        }
        self.uuids = newUuids
        if wasStarted {
            start()
        }
    }
    
    func start() {
        if locationManager == nil {
            locationManager = CLLocationManager()
            locationManager.delegate = self
        }
        for uuid in uuids {
            locationManager.startRangingBeacons(in: CLBeaconRegion(proximityUUID: UUID(uuidString: uuid)!, identifier: uuid))
        }
        started = true
    }

    func stop() {
        if !started {
            return
        }
        for uuid in uuids {
            locationManager.stopRangingBeacons(in: CLBeaconRegion(proximityUUID: UUID(uuidString: uuid)!, identifier: uuid))
            
        }
        started = false
    }
    
    func track(beacon: CLBeacon) {
        let key = TrackedBeacon.makeKey(beacon: beacon)
        if let trackedBeacon = trackedBeacons[key] {
            trackedBeacon.beacon = beacon
            trackedBeacon.lastDetected = Date()
        }
        else {
            trackedBeacons[key] = TrackedBeacon(beacon: beacon)
        }
        purge()
    }
    
    func purge() {
        var newTrackedBeacons: [String:TrackedBeacon] = [:]
        for key in trackedBeacons.keys {
            if let beacon = trackedBeacons[key] {
                if Date().timeIntervalSince1970 - beacon.lastDetected.timeIntervalSince1970 < MaxTrackingSecs {
                    newTrackedBeacons[key] = beacon
                }
            }
        }
        trackedBeacons = newTrackedBeacons
    }
    
    func sorted(distanceSortOn: Bool = false) -> [TrackedBeacon] {
       return trackedBeacons.values.sorted { (a, b) -> Bool in
            return TrackedBeacon.makeKey(beacon: a.beacon) < TrackedBeacon.makeKey(beacon: b.beacon)
        }
    }
}
