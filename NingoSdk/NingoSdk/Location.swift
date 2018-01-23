//
//  Location.swift
//  NingoSdk
//
//  Created by David G. Young on 1/21/18.
//

import Foundation

public class Location {
    public var longitude: Double
    public var latitude: Double
    public var altitude: Double?
    public var hAccuracy: Double?
    public var vAccuracy: Double?
    public var type: String?
    
    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}
