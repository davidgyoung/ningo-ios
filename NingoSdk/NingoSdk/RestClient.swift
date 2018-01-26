//
//  RestClient.swift
//  NingoSdk
//
//  Created by David G. Young on 1/19/18.
//

import Foundation

class RestClient {
    //let backgroundQueue = DispatchQueue(label: "com.ningosdk.api", qos: .background)
    let session = URLSession(configuration: RestClient.getSessionConfig())
    var dataTask: URLSessionDataTask?
    var baseUrl = "https://ningo-api.herokuapp.com"

    static func getSessionConfig() -> URLSessionConfiguration {
        let sessionConfig = URLSessionConfiguration.default
        //sessionConfig.timeoutIntervalForRequest = 10.0
        //sessionConfig.timeoutIntervalForResource = 10.0
        return sessionConfig
    }
    
    static func addResponseJsonHeader(headers: [String:[String]]) ->  [String:[String]]  {
        return RestClient.addHeader(headers: headers, key: "Accept", value: "application/json")
    }

    static func addRequestJsonHeader(headers: [String:[String]]) ->  [String:[String]]  {
        return RestClient.addHeader(headers: headers, key: "Content-Type", value: "application/json")
    }

    static func addAuthHeader(headers: [String:[String]], apiKey: String) -> [String:[String]] {
        return RestClient.addHeader(headers: headers, key: "Authorization", value: "Token token=\"\(apiKey)\"")
    }

    static func addHeader(headers: [String:[String]], key: String, value: String) -> [String:[String]] {
        var headers = headers
        if let array = headers[key] {
            var array = array
            array.append(value)
        }
        else {
            headers[key] = [value]
        }
        return headers
    }
    
    func makeRequestWithApiKey(method: String, urlPath: String, apiKey: String, bodyJson: [String:Any]?, completionHandler: @escaping (_ headers: [String:[String]], _ bodyJson: [String:Any]?, _ error: String?) -> Void) {
        let headers = RestClient.addAuthHeader(headers: [:], apiKey: apiKey)
        makeRequest(method: method, urlPath: urlPath, headers: headers, bodyJson: bodyJson, completionHandler: completionHandler)
    }

    
    func makeRequest(method: String, urlPath: String, headers: [String:[String]]?, bodyJson: [String:Any]?, completionHandler: @escaping (_ headerDict: [String:[String]], _ bodyJsonDict: [String:Any]?, _ error: String?) -> Void) {
        let urlString = "\(baseUrl)\(urlPath)"
        var headers = RestClient.addResponseJsonHeader(headers: headers ?? [:])
        var request = URLRequest(url: URL(string: urlString)!, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: TimeInterval(10))
        request.httpMethod = method
        do {
            if let bodyJson = bodyJson {
                let bodyData = try JSONSerialization.data(withJSONObject: bodyJson, options: JSONSerialization.WritingOptions.prettyPrinted)
                request.httpBody = bodyData
                headers = RestClient.addRequestJsonHeader(headers: headers)
            }
        }
        catch {
            NSLog("Can't serialize body data")
        }
        for headerKey in headers.keys {
            if let values = headers[headerKey] {
                for value in values {
                    request.addValue(value, forHTTPHeaderField: headerKey)
                }
            }
        }
        
        dataTask = session.dataTask(with: request) {
            data, response, error in
            NSLog("Back from request")
            var responseError: String? = nil
            
            let response = response as? HTTPURLResponse
            
            var jsonDict: [String:Any]? = nil
            if let error = error as NSError? {
                if error.code == -1001 || error.code == -1009 {
                    responseError = "No network"
                }
            }
            if let data = data {
                do {
                    if let str = String(data: data, encoding: String.Encoding.utf8) {
                        NSLog("JSON from server: \(str)")
                    }
                    if let result = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String:Any] {
                        jsonDict = result
                    }
                    else {
                        let message = "Cannot decode json due to nil deserilization result"
                        NSLog(message)
                        responseError = message
                    }
                }
                catch {
                    let message = "Cannot decode json due to exception"
                    NSLog(message)
                    responseError = message
                }
            }
            else {
                let message = "Response body is unexpectedly nil"
                NSLog(message)
                responseError = message
            }

            var responseHeaders: [String:[String]] = [:]

            if let response = response {
                if response.statusCode == 404 {
                    if (responseError == nil) {
                        responseError = "Code: 404"
                    }
                }
                else if response.statusCode == 401 {
                    responseError = "Code: 401"
                }
                else if response.statusCode < 200 || response.statusCode > 299 {
                    if let error = jsonDict?["error"] as? String {
                        responseError = error
                    }
                    else if let baseError = ((jsonDict?["errors"] as? [String:Any])?["base"] as? [String])?.first {
                        responseError = baseError
                    }
                    else if let fieldNameWithError = (jsonDict?["errors"] as? [String:Any])?.keys.first {
                        if let errorString = ((jsonDict?["errors"] as? [String:Any?])?[fieldNameWithError] as? [String])?.first {
                            responseError = "Invalid value for \(fieldNameWithError): \(errorString)"
                        }
                    }
                    else {
                        responseError = "Code: \(response.statusCode)"
                    }
                }
                for key in response.allHeaderFields.keys {
                    if let key = key as? String, let value = response.allHeaderFields[key] as? String {
                        responseHeaders[key] = [value]
                    }
                }

            }
            else {
                NSLog("Response is unexpectedly nil")
            }

            if let responseError = responseError {
                NSLog("Response has an error \(responseError)")
            }
            
            completionHandler(responseHeaders, jsonDict, responseError)
        }
        dataTask!.resume()
    }

}
