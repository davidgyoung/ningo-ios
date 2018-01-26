//
//  MetadataV1.swift
//  NingoSdk
//
//  Created by David G. Young on 1/21/18.
//

import Foundation

public class MetadataV1 {
    public var loctype: String?
    public var radius: Double?
    public var location: Location?
    public var info: [InfoRecord]? = nil
    public var categories: [String]? = nil
    private var dict: [String: Any]?
    
    public init() {
        
    }
    
    public static func fromDict(dict: [String:Any]) -> MetadataV1 {
        let metadata = MetadataV1()
        metadata.dict = dict
        metadata.loctype = dict["loctype"] as? String
        metadata.radius = dict["radius"] as? Double
        if let infoArray = dict["info"] as? [[String:Any]] {
            var infos: [InfoRecord] = []
            for info in infoArray {
                infos.append(InfoRecord.fromDict(dict: info))
            }
            metadata.info = infos
        }

        if let categoryArray = dict["categories"] as? [Any?] {
            metadata.categories = []
            for category in categoryArray {
                if let category = category as? String {
                    metadata.categories!.append(category)
                }
            }
        }
        if let locationDict = dict["location"] as? [String:Any] {
            if let latitude = locationDict["latitude"] as? Double,
                let longitude = locationDict["longitude"] as? Double {
                let location = Location(latitude: latitude, longitude: longitude)
                location.altitude = locationDict["altitude"] as? Double
                location.hAccuracy = locationDict["hAccuracy"] as? Double
                location.vAccuracy = locationDict["vAccuracy"] as? Double
                location.type = locationDict["tyoe"] as? String
                metadata.location = location
            }
        }
        return metadata
    }
    
    public func toDict() -> [String:Any] {
        var dict: [String:Any] = [
            "location": location?.toDict() as Any
        ]
        if let loctype = loctype {
            dict["loctype"] = loctype
        }
        if let radius = radius {
            dict["radius"] = radius
        }
        if let info = info {
            dict["info"] = InfoRecord.toDicts(info: info)
        }
        if let categories = categories {
            dict["categories"] = categories as Any
        }
        return dict
    }
    
    public func toJson() -> String {
        if let dict = dict {
            let options = JSONSerialization.WritingOptions.prettyPrinted
            if JSONSerialization.isValidJSONObject(dict) {
                do {
                    let data = try JSONSerialization.data(withJSONObject: dict, options: options)
                    if let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                        return string as String
                    }
                }  catch {
                    return ""
                }
            }
        }
        return ""
    }
}
