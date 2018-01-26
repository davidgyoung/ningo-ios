//
//  MockableCLBeacon.swift
//
//  Created by David G. Young on 1/25/18.
//

import CoreLocation

@objc public class MockableCLBeacon: NSObject {
    public var proximityUUID: UUID
    public var major: NSNumber
    public var minor: NSNumber
    public var rssi: Int = 0
    public var accuracy: CLLocationAccuracy = 1.0
    public var proximity: CLProximity = CLProximity.near

    public init(beacon: CLBeacon) {
        proximityUUID = beacon.proximityUUID
        major = beacon.major
        minor = beacon.minor
        rssi = beacon.rssi
        accuracy = beacon.accuracy
        proximity = beacon.proximity
    }
    
    public init(proximityUUID: UUID, major: NSNumber, minor: NSNumber) {
        self.proximityUUID = proximityUUID
        self.major = major
        self.minor = minor
    }
    
}
