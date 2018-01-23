//
//  QueryBeaconClient.swift
//  NingoSdk
//
//  Created by David G. Young on 1/21/18.
//

import Foundation

//curl -i -X POST https://ningo-api.herokuapp.com/api/public/v1/beacons/query -d '{"latitude":38, "longitude":-77, "radius_meters": 100000}' -H 'Content-Type: Application/json' -H 'Authorization: Token token="eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxLCJleHAiOjE0OTIyODQ2MDl9.CMfGArSZ_rQw0C6sduVSF9kQfiCU0z9bH69A4C_6x5Y"'

public class QueryBeaconClient {
    let restClient: RestClient
    let authToken: String
    let urlPath = "/api/public/v1/beacons/query"
    
    public init(authToken: String) {
        restClient = RestClient()
        self.authToken = authToken
    }
    
    public func query(latitude: Double, longitude: Double, radiusMeters: Double, completionHandler: @escaping (_
        beacons: [Beacon]?, _ errorCode: String?, _ errorDescription: String?) -> Void ) {
        
        let json: [String:Any] = [
            "latitude": latitude,
            "longitude": longitude,
            "radius_meters": radiusMeters
        ]

        restClient.makeRequestWithApiKey(method: "POST", urlPath: urlPath, apiKey: authToken, bodyJson: json, completionHandler: { (responseHeaders, responseJson, errorCode) in
            if errorCode != nil {
                completionHandler(nil, errorCode, "")
            }
            else {
                if let responseJson = responseJson {
                    if let dictArray = responseJson["beacons"] as? [[String: Any]] {
                        completionHandler(Beacon.fromDictArray(dictArray: dictArray), errorCode, "")
                        return
                    }
                }
                completionHandler(nil, "cannot parse json", "")
            }
        })
    }
    
}
