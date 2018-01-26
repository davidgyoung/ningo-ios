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
    
    public func toDict() -> [String:Any] {
        var dict: [String:Any] = [
            "latitude": latitude,
            "longitude": longitude,
        ]
        
        if let altitude = altitude {
            dict["altitude"] = altitude
        }
        if let type = type {
            dict["type"] = type
        }
        if let hAccuracy = hAccuracy {
            dict["hAccuracy"] = hAccuracy
        }
        if let vAccuracy = vAccuracy {
            dict["vAccuracy"] = vAccuracy
        }
        return dict

    
    }
}
