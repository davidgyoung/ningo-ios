# Ningo SDK Git Repository

This source code repository contains iOS code for building the NingoSdk framework and an associated reference application.  This contains two iOS projects and a workspace.

To load this in XCode open the following workspace: `NingoSdkWorkspace.xcworkspace`

This will load up two XCode projects within the workspace:

## NingoSdk

An iOS framework for communicating with the Ningo API to read and write beacon metadata.  See the [README.md](NingoSdk/README.md) for that subfolder for more info.  To use the NingoSDK in your own project, you should
use the universal binary framework.  The universal framwork will allow you to run your app on both the simulator and physical iOS devices.  You can build this universal framework yourself or you can simply download it from the releases section of this project.

## NingoSdkReferenceApp

An iOS app used to test the NingoSdk framework and to provide a reference implementation as an app.  This app queries the online beacon database for all ProximityUUIDs in the vicinity, allowing 
for ranging any nearby beacon that has been detected before by another phone.  It then can display Ningo metadata for that beacon and optionally let the user edit those metadata.

The reference application is set up to compile the source code of the NingoSDK when it is built, and link against it as a subproject.  See the NingoSdk section above for how to use the binary framework in your own project.


