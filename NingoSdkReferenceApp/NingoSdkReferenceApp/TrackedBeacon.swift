//
//  TrackedBeacon.swift
//  BeaconScanner
//
//  Created by David G. Young on 1/12/18.
//  Copyright © 2018 Altbeacon. All rights reserved.
//

import Foundation
import CoreLocation
import NingoSdk

public class TrackedBeacon {
    var beacon: MockableCLBeacon
    var lastDetected: Date
    let key: String
    
    init(beacon: MockableCLBeacon) {
        self.beacon = beacon
        self.lastDetected = Date()
        self.key = TrackedBeacon.makeKey(beacon: beacon)
    }
    static func makeKey(beacon: MockableCLBeacon) -> String {
        return "\(beacon.proximityUUID.uuidString)_\(beacon.major)_\(beacon.minor)_ibeacon"
    }
}
