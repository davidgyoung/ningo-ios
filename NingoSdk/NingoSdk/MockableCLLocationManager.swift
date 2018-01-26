//
//  MockableLocationManager.swift
//  NingoSdk
//
//  Created by David G. Young on 1/25/18.
//

import CoreLocation

public class MockableCLLocationManager: CLLocationManager {
    private var _mockableDelegate: MockableCLLocationManagerDelegate? = nil
    public var mockableDelegate: MockableCLLocationManagerDelegate? {
        set {
            _mockableDelegate = newValue
            self.forwardingDelegate.delegate = _mockableDelegate
            self.delegate = forwardingDelegate
        }
        get {
            return _mockableDelegate
        }
    }
    public func detectMockableBeacons(beacons: [MockableCLBeacon]) {
        forwardingDelegate.detectMockableBeacons(beacons: beacons)
    }
    override public func startRangingBeacons(in region: CLBeaconRegion) {
        super.startRangingBeacons(in: region)
    }
    
    
    private var forwardingDelegate = ForwardingLocationManagerDelegate(delegate:nil)
    
    private class ForwardingLocationManagerDelegate: NSObject, CLLocationManagerDelegate {
        var delegate: MockableCLLocationManagerDelegate?
        var mockableBeacons: [MockableCLBeacon] = []
        init(delegate: MockableCLLocationManagerDelegate?) {
            self.delegate = delegate
            super.init()
        }
        public func detectMockableBeacons(beacons: [MockableCLBeacon]) {
            mockableBeacons = beacons
        }

        public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            delegate?.locationManager?(manager, didUpdateLocations: locations)
        }
        public func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
            delegate?.locationManager?(manager, didUpdateHeading: newHeading)
        }
        public func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
            return delegate?.locationManagerShouldDisplayHeadingCalibration?(manager) ?? false
        }
        public func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
            delegate?.locationManager?(manager, didDetermineState: state, for: region)
        }
        public func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
            var mockableBeacons: [MockableCLBeacon] = []
            for beacon in beacons {
                mockableBeacons.append(MockableCLBeacon(beacon: beacon))
            }
            delegate?.locationManager?(manager, didRangeBeacons: mockableBeacons, in: region)
        }
        public func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error) {
            delegate?.locationManager?(manager, rangingBeaconsDidFailFor: region, withError: error)
        }
        public func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
            delegate?.locationManager?(manager, didEnterRegion: region)
        }
        public func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
            delegate?.locationManager?(manager, didExitRegion: region)
        }
        public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            delegate?.locationManager?(manager, didFailWithError: error)
        }
        public func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
            delegate?.locationManager?(manager, monitoringDidFailFor: region, withError: error)
        }
        public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            delegate?.locationManager?(manager, didChangeAuthorization: status)
        }
        public func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
            delegate?.locationManager?(manager, didStartMonitoringFor: region)
        }
        public func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
            delegate?.locationManagerDidPauseLocationUpdates?(manager)
        }
        public func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
            delegate?.locationManagerDidResumeLocationUpdates?(manager)
        }
        public func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
            delegate?.locationManager?(manager, didFinishDeferredUpdatesWithError: error)
        }
        public func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
            delegate?.locationManager?(manager, didVisit: visit)
        }
    }
    
}


