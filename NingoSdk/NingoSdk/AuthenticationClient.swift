//
//  AuthenticationClient.swift
//  NingoSdk
//
//  Created by David G. Young on 1/19/18.
//

import Foundation

public class AuthenticationClient {
    var restClient: RestClient
    let urlPath = "/api/public/v1/authentication"
    
    public init() {
        restClient = RestClient()
    }
    
    public func authenticate(email: String, password: String, completionHandler: @escaping (_
        authToken: String?, _ error: String?) -> Void ) {
        
        let json: [String:Any] = [
            "email": email,
            "password": password
        ]
        restClient.makeRequest(method: "POST", urlPath: urlPath, headers: [:], bodyJson: json) { (headers, json, error) in
            if let error = error {
                completionHandler(nil, error)
            }
            else {
                guard json?["auth_token"] as? String != nil else {
                    completionHandler("api key missing", nil)
                    return
                }
                completionHandler(json?["auth_token"] as? String, nil)
            }
        }
    }
    
}
