//
//  Beacon.swift
//  NingoSdk
//
//  Created by David G. Young on 1/19/18.
//

import Foundation

public class Beacon {
    public let identifier: String
    public var identifiers: [String] {
        get {
            var ids = identifier.split(separator: "_")
            if ids.count > 0 {
                ids.remove(at: ids.count-1)
            }
            var stringIds: [String] = []
            for id in ids {
                stringIds.append(String(id))
            }
            return stringIds
        }
    }
    public var metadata: MetadataV1?
    public var wikiBeaconLatitude: Double?
    public var wikiBeaconLongitude: Double?
    
    public init(identifier: String) {
        self.identifier = identifier
    }

    /*
{"beacon":{"identifier":"2f234454-cf6d-4a0f-adf2-f4911ba9ffa6_38911_11_ibeacon","first_identifier":"2f234454-cf6d-4a0f-adf2-f4911ba9ffa6","beacon_type":"ibeacon","metadata":{"categories":["test"],"location":{"latitude":38.93,"longitude":-77.22}},"username":"davidgyoung","updated_at":"2017-07-01T23:20:53.226Z","wikibeacon_datum":null}}
     
{"beacon":{"identifier":"2f234454-cf6d-4a0f-adf2-f4911ba9ffa6_1_1_ibeacon","first_identifier":"2f234454-cf6d-4a0f-adf2-f4911ba9ffa6","beacon_type":"ibeacon","metadata":null,"username":"davidgyoung","updated_at":"2017-12-01T00:33:04.833Z","wikibeacon_datum":{"latitude":null,"longitude":null,"country":null,"country_code":null,"postcode":null,"state":null,"state_district":null,"city":null,"suburb":null,"road":null,"house_number":null,"first_detected_at":"2014-01-07T05:29:56.000Z","last_detected_at":"2017-09-07T22:22:17.609Z"}}}
     
     */
    public static func fromDict(dict: [String:Any?]) -> Beacon? {
        var beaconDict = dict["beacon"] as? [String: Any?] ?? dict
        if let identifier = beaconDict["identifier"] as? String {
            let beacon = Beacon(identifier: identifier)
            if let wikiBeaconDatum = beaconDict["wikibeacon_datum"] as? [String:Any?] {
                beacon.wikiBeaconLatitude = Double(wikiBeaconDatum["latitude"] as? String ?? "")
                beacon.wikiBeaconLongitude = Double(wikiBeaconDatum["longitude"] as? String ?? "")
            }
            if let metadataDict = beaconDict["metadata"] as? [String: Any?] {
                beacon.metadata = MetadataV1.fromDict(dict: metadataDict)
            }
            return beacon
        }
        return nil
    }
    
    public static func fromDictArray(dictArray: [[String:Any?]]) -> [Beacon] {
        var beacons: [Beacon] = []
        for dict in dictArray {
            if let beacon = Beacon.fromDict(dict: dict) {
                beacons.append(beacon)
            }
        }
        return beacons
    }
    
    public func toDict() -> [String:Any] {
        var beacon: [String:Any] = [:]
        beacon["identifier"] = identifier
        if let metadata = metadata {
            beacon["metadata"] = metadata.toDict()
        }
        return beacon
    }

}
