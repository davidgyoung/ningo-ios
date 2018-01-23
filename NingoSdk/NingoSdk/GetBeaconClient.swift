//
//  GetBeaconClient.swift
//  NingoSdk
//
//  Created by David G. Young on 1/19/18.
//

import Foundation

public class GetBeaconClient {
    let restClient: RestClient
    let authToken: String
    let urlPath = "/api/public/v1/beacons/"
    
    public init(authToken: String) {
        restClient = RestClient()
        self.authToken = authToken
    }
    
    public func get(identifier: String, completionHandler: @escaping (_
        beacon: Beacon?, _ errorCode: String?, _ errorDescription: String?) -> Void ) {
        
        let urlPathWithIdentifier = "\(urlPath)\(identifier.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "")"
        
        restClient.makeRequestWithApiKey(method: "GET", urlPath: urlPathWithIdentifier, apiKey: authToken, bodyJson: nil, completionHandler: { (responseHeaders, responseJson, errorCode) in
            if errorCode != nil {
                completionHandler(nil, errorCode, "")
            }
            else {
                if let responseJson = responseJson {
                    if let beacon = Beacon.fromDict(dict: responseJson) {
                        completionHandler(beacon, errorCode, "")
                        return
                    }
                }
                completionHandler(nil, "cannot parse json", "")
            }
        })
    }
    
}
