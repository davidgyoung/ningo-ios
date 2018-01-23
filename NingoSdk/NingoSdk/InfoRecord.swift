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
}
