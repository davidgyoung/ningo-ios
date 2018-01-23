//
//  PermissionHelper.swift
//  NingoSdk
//
//

import Foundation
import CoreLocation

internal class PermissionHelper {
  
  let locationManager: CLLocationManager
  
  internal init(locationManager: CLLocationManager) {
    self.locationManager = locationManager
  }
  internal func isLocationEnabled() -> Bool {
    return CLLocationManager.locationServicesEnabled()
  }
  internal func isAppLocationPermissionGranted() -> Bool {
    print("location authorization status is \(CLLocationManager.authorizationStatus()), desired status is \(CLAuthorizationStatus.authorizedAlways)  comparison: \(CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways)")
    return CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways
  }
  
  internal func isAppLocationPermissionDenied() -> Bool {
    return CLLocationManager.authorizationStatus() == CLAuthorizationStatus.denied
  }
  
  internal func requestLocationPermission() {
    locationManager.requestAlwaysAuthorization()
  }
}

extension CLAuthorizationStatus: CustomStringConvertible {
  public var description: String {
    switch self {
    case .authorizedAlways: return "AuthorizationAlways"
    case .authorizedWhenInUse: return "AuthorizationWhenInUse"
    case .denied: return "AuthorizationDenied"
    case .notDetermined: return "NotDetermined"
    case .restricted: return "Restricted"
    }
  }
}
