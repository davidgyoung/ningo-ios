//
//  PermissionRequester.swift
//  BeaconScanner
//
//  Created by David G. Young on 1/12/18.
//  Copyright © 2018 Altbeacon. All rights reserved.
//

import Foundation
import CoreLocation

class PermissionRequester {
    var locationManager = CLLocationManager()
    
    func ensureForegroundPermission() {
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
            locationManager.requestWhenInUseAuthorization()
        }
    }    
}
