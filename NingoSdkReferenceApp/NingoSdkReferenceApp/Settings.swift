//
//  Settings.swift
//  NingoSdkReferenceApp
//
//  Created by David G. Young on 1/23/18.
//

import Foundation


class Settings {
    static let ningoEmailKey = "NINGO_EMAIL"
    static let ningoPasswordKey = "NINGO_PASSWORD"
    static let ningoReadwriteApiTokenKey = "NINGO_READWRITE_API_TOKEN"
    static let ningoReadonlyApiTokenKey = "NINGO_READONLY_API_TOKEN"
    static let ningoLoginTimeMillis = "NINGO_LOGIN_TIME_MILLIS"
    
    public func getSetting(key: String) -> String? {
        return UserDefaults.standard.object(forKey: key) as? String
    }
    
    public func saveSetting(key: String, value: String) {
        UserDefaults.standard.setValue(value, forKey: key)
    }
}
    
    

