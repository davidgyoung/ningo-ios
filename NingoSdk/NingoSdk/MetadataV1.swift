//
//  MetadataV1.swift
//  NingoSdk
//
//  Created by David G. Young on 1/21/18.
//

import Foundation

public class MetadataV1 {
    var loctype: String?
    var radius: Double?
    var location: Location?
    var info: [InfoRecord] = []
    var categories: [String] = []
    
    public init() {
        
    }
}
