//
//  BeaconTracker.swift
//  BeaconScanner
//
//  Created by David G. Young on 1/12/18.
//

import CoreLocation
import UIKit
import NingoSdk

class BeaconTracker: NSObject, MockableCLLocationManagerDelegate {
    static let shared = BeaconTracker()
    let MaxTrackingSecs = 5.0
    var trackedBeacons: [String:TrackedBeacon] = [:]
    var locationManager: MockableCLLocationManager!
    var uuids: [String] = ["2F234454-CF6D-4A0F-ADF2-F4911BA9FFA6"]
    var transientUuids: [String] = []
    var started = false
    
    override init() {
        super.init()
    }
    
    func rangedUuidCount() -> Int {
        return locationManager?.rangedRegions.count ?? 0
    }
    
    public func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [MockableCLBeacon], in region: CLBeaconRegion) {
        for beacon in beacons {
            track(beacon: beacon)
        }
        NotificationCenter.default.post(name: NSNotification.Name("beacons_updated"), object: nil)
    }
    
    func updateTransientUuids(uuids: [String]) {
        stopRangingTransientUuids()
        transientUuids = uuids
        startRangingTransientUuids()
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
            locationManager = MockableCLLocationManager()
            locationManager.mockableDelegate = self
        }
        startRangingTransientUuids()
        for uuid in uuids {
            if let region = BeaconTracker.makeRegion(uuidString: uuid) {
                locationManager.startRangingBeacons(in: region)
            }
        }
        started = true
        #if (arch(i386) || arch(x86_64)) && (!os(macOS))
//5d6e3661-cc39-4d15-9607-29413021a082_527_6_ibeacon
        var beacon = MockableCLBeacon(proximityUUID: UUID(uuidString:"5d6e3661-cc39-4d15-9607-29413021a082")!, major: 527, minor: 6)
            self.track(beacon: beacon)
            beacon = MockableCLBeacon(proximityUUID: UUID(uuidString:"f7826da6-4fa2-4e98-8024-bc5b71e0893e")!, major: 17784, minor: 47967)
            self.track(beacon: beacon)
            NotificationCenter.default.post(name: NSNotification.Name("beacons_updated"), object: nil)
        #endif
    }
    
    func stop() {
        if !started {
            return
        }
        for uuid in uuids {
            if let region = BeaconTracker.makeRegion(uuidString: uuid) {
                locationManager.stopRangingBeacons(in: region)
            }
        }
        stopRangingTransientUuids()
        started = false
    }
    
    func track(beacon: MockableCLBeacon) {
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
    
    static func makeRegion(uuidString: String) -> CLBeaconRegion? {
        var region: CLBeaconRegion? = nil
        if let uuid = UUID(uuidString: uuidString) {
            region = CLBeaconRegion(proximityUUID: uuid, identifier: uuidString)
        }
        return region
    }
    private func stopRangingTransientUuids() {
        for uuid in transientUuids {
            if !uuids.contains(uuid.uppercased()) {
                // this uuid is not in the perm uuid list.  stop tracking it
                if let region = BeaconTracker.makeRegion(uuidString: uuid) {
                    locationManager.stopRangingBeacons(in: region)
                }
            }
        }
    }
    
    private func startRangingTransientUuids() {
        for uuid in transientUuids {
            if !uuids.contains(uuid.uppercased()) {
                // this uuid is not in the perm uuid list.  stop tracking it
                if let region = BeaconTracker.makeRegion(uuidString: uuid) {
                    locationManager.startRangingBeacons(in: region)
                }
            }
        }
    }
    
}
