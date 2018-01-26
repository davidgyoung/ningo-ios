//
//  PostBeaconClient.swift
//  NingoSdk
//
//  Created by David G. Young on 1/21/18.
//

public class PostBeaconClient {
    let restClient: RestClient
    let authToken: String
    let urlPath = "/api/public/v1/beacons"
    
    public init(authToken: String) {
        restClient = RestClient()
        self.authToken = authToken
    }
    
    public func post(beacon: Beacon, completionHandler: @escaping (_
        beacon: Beacon?, _ errorCode: String?, _ errorDescription: String?) -> Void ) {
        
        let jsonDict = beacon.toDict()
                
        restClient.makeRequestWithApiKey(method: "POST", urlPath: urlPath, apiKey: authToken, bodyJson: jsonDict, completionHandler: { (responseHeaders, responseJson, errorCode) in
            if errorCode != nil {
                var errorDescription: String? = nil
                if let json = responseJson {
                    errorDescription = json["error"] as? String
                }
                completionHandler(nil, errorCode, errorDescription)
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
