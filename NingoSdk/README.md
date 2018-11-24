# NingoSdk
iOS Framework for reading and writing beacon metadata over the Ningo API

Documentation version 0.4

## Change log

0.4 Compile for Swift 4.2
0.3 Build working unviersal framework
0.2 Add notes about universal framework
0.1 Initial revision for testing

## Project Setup

1. Drag the NingoSdk.framework file into your app in XCode (downloadable from https://github.com/davidgyoung/ningo-ios/releases).  (Unzip it first if necessary.)
2. In XCode go to App -> General -> Embedded Binaries, and use the + icon to add the NingoSdk.framework binary
3. In XCode go to App -> Build Settings, and search for "Embedded Content Contains Swift Code". Set this to Yes 
4. Edit your project's Info.plist, adding the following entry.  Without this entry, beacons cannot be detected:
```
<key>NSLocationAlwaysUsageDescription</key>
<string>Location is required to detect retail locations.</string>
```
5. For each Swift class where you are using the NingoSdk framework, add `import NingoSdk` near the top of the file.  For Objective C classes, add `#import <NingoSdk/NingoSdk.h>`

One you complete the above steps, you will be able to access the SDK's classes from your app's code.

## Building a Universal Framework

When you build the SDK through XCode, by default it will generate a framwork for either the simulator or for iOS devices, and you won't be able to use the same framework binary for both.  In order to build a universal framwork that works on both the simulator and on iOS devices, build the NingoSDK-Universal target, then get the output NingoSDK.framework from the `./NingoSdk.framework` folder.

## Read Only and Read/Write Access

The iOS client works in two modes: read only and read/write.

To read data, you need only embed a Ningo auth token string inside your iOS app.  You can use this token to read beacon metadata for a specific beacon identifier or a group of beacons within a requested distance of a location.  Here is an example API call:

```
var readonlyAuthToken =...;

// Find a specific beacon
let getBeaconClient = GetBeaconClient(authToken: readonlyAuthToken)
getBeaconClient.get(identifier: "2F234454-CF6D-4A0F-ADF2-F4911BA9FFA6_1_1_ibeacon", completionHandler: { (beacon, errorCode, errorDescription) in
  if beacon != nil {
    NSLog("Got beacon: \(beacon!.identifier)")
  }
  else {
    NSLog("Error getting beacon: \(errorCode!)")
  }
})


// Find all beacons nearby
let queryBeaconClient = QueryBeaconClient(authToken: readonlyAuthToken)
queryBeaconClient.query(latitude: 38.93, longitude: -77.28, radiusMeters: 1000.0, completionHandler: { (beacons, errorCode, errorDescription) in
  if beacons != nil {
    NSLog("Got beacons: \(beacons!.first!.identifier)")
  }
  else {
    NSLog("Error getting beacons: \(errorCode!)")
  }
})

```

Either way, the returned Beacon objects can be accessed like this:

```
let ningoBeacon = beacons[0]
let ningoMetadata = ningoBeacon.metadata
let ningoLocation = ningoMetadata.location
let latitude = ningoLocation.latitude
```

To write data, app users first need an account on the Ningo system.  Using the email and password for this account, they can get a read write auth token like this:

```
let authClient = AuthenticationClient()
authClient.authenticate(email: myEmail, password: myPassword) { (authToken, error) in
  if let error = error {
    NSLog("Error logging in: \(error)")
  }
  else {
    myReadWriteToken = authToken
  }
}
```

This auth token can then be used to perform all the read-only mode APIs above as well as the following write API:


```
let postBeaconClient = PostBeaconClient(authToken: authToken!)
postBeaconClient.post(beacon: beacon!, completionHandler: { (beacon, errorCode, errorDescription) in
  if beacon != nil {
    NSLog("Updated beacon: \(beacon!.identifier)")
  }
  else {
  NSLog("Error updating beacon: \(errorCode!)")
  }
})

```

A full reference app, along with the source code to this SDK is available in the root of this repository.

## API Tokens

In order to use this SDK you must obtain an API token.  There are two types of API tokens, both of which require you to create an account on the Ningo server with a username and password.  See above for how to use the SDK in read/write mode.

### Obtaining a Readonly Token

Readonly tokens provide the ablity to query beacon data based on a static token embedded in your mobile app.
As its name implies, you cannot use such a token to write data.  To obtain a readonly token, you may run a command like this from a Linux or Unix workstation:

```
$ curl -i -XPOST https://ningo-api.herokuapp.com/api/public/v1/authentication -H "Content-Type: application/json" -d '{"email":"david@radiusnetworks.com","password":"xxxxxxxx", "readonly": "true"}'
HTTP/1.1 200 OK
Server: Cowboy
Date: Wed, 29 Mar 2017 21:14:20 GMT
Connection: keep-alive
X-Frame-Options: SAMEORIGIN
X-Xss-Protection: 1; mode=block
X-Content-Type-Options: nosniff
Content-Type: application/json; charset=utf-8
Etag: W/"d06d7264a58b218419a95fcccffef456"
Cache-Control: max-age=0, private, must-revalidate
X-Request-Id: bf1db7ee-0c09-4fec-90ae-a59fbe9e010b
X-Runtime: 0.081724
Transfer-Encoding: chunked
Via: 1.1 vegur

{"auth_token":"akL9eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxLCJleHAiOjE0OTA5MDg0NjB9.bjmSpLI_bV30B_M6brEHLQEUac_fqGJOEOmj6urmJFc", "readonly": true}
```

Once you have this token you can put it in your app like this:

```
public let apiToken="akL9eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxLCJleHAiOjE0OTA5MDg0NjB9.bjmSpLI_bV30B_M6brEHLQEUac_fqGJOEOmj6urmJFc"
```

