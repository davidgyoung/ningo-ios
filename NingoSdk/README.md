# NingoSdk
iOS Framework for reading and writing beacon metadata over the Ningo API

Documentation version 0.1

## Change log


## Project Setup

1. Drag the NingoSdk.framework file into your app in XCode.  (Unzip it first if necessary.)
2. In XCode go to App -> General -> Embedded Binaries, and use the + icon to add the NingoSdk.framework binary
3. In XCode go to App -> Build Settings, and search for "Embedded Content Contains Swift Code". Set this to Yes 
4. Edit your project's Info.plist, adding the following entry.  Without this entry, beacons cannot be detected:
```
<key>NSLocationAlwaysUsageDescription</key>
<string>Location is required to detect retail locations.</string>
```
5. For each Swift class where you are using the NingoSdk framework, add `import NingoSdk` near the top of the file.  For Objective C classes, add `#import <NingoSdk/NingoSdk.h>`

## Requesting Permissions

In order for the app to be able to detect beacons, you must first get the operating system to prompt the user for location permission.  You trigger this to happen from a `ViewController`, by calling the following code:

<pre>
  let beaconDetector = BeaconDetector.sharedInstance
  if beaconDetector.requestLocationPermissionIfNeeded() {
    let alert = UIAlertController(title: "Location Services Denied", message: "This app can't function because it has been denied access to location services.  Please go to settings for this app and grant location access.", preferredStyle: UIAlertControllerStyle.alert)
    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
    self.present(alert, animated: true, completion: nil)
  }
</pre>

The sample code above will request location permission from a user, and return false if it is explicitly denied.  In this case, the example shows presenting an explanation to the user of why they cannot continue to use the app.




