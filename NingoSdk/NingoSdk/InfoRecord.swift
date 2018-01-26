//
//  InfoRecord.swift
//  NingoSdk
//
//  Created by David G. Young on 1/21/18.
//

import Foundation

public class InfoRecord {
    public var lang: String
    public var value: String
    public var description: String?
    
    public init(lang: String, value: String) {
        self.lang = lang
        self.value = value
    }
    
    public func toDict() -> [String: Any] {
        var dict: [String:Any] = [
            "lang": lang,
            "value": value,
        ]
        if let description = description {
            dict["description"] = description as Any
        }
        return dict
    }
    
    public static func toDicts(info: [InfoRecord]) -> [[String: Any]] {
        var dicts : [[String:Any]] = []
        for infoRecord in info {
            dicts.append(infoRecord.toDict())
        }
        return dicts
    }
    
    public static func fromDict(dict: [String:Any]) -> InfoRecord {
        let record = InfoRecord(lang:"", value: "")
        if let lang = dict["lang"] as? String {
            record.lang = lang
        }
        if let value = dict["value"] as? String {
            record.value = value
        }
        record.description = dict["description"] as? String
        return record
    }
}
