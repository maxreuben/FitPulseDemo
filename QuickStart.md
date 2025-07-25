# QuickStart
This is the QuickStart Guide for this iOS Demo app. It is an iOS app that tracks pulse rate and breathing rate using facial analysis through the front camera. 
It uses the Physiology API and SmartSpectra SDK made by Presage Technologies. 
### Requirements
* Xcode 15 or newer
* iOS 16 or newer
* Not usable with emulators or the Xcode simulator

## Setup
1. Register for an API Key or use an Oauth token from [physiology.presagetech.com](physiology.presagetech.com). Follow the instructions given [here](https://github.com/Presage-Security/SmartSpectra/blob/main/docs/authentication.md)
2. Copy and include the API Key in a file such as Config.xcconfig and paste the API key in it as `API_KEY = "YOUR API_KEY HERE`. Alternatively, you can also just add the API Key in your Info.plist as a custom attribute.
Note that this is for testing & development purposes only. For deployment, use an Oauth token, in which case you can skip this step. After Oauth registration, just download the .plist file and store in the root folder of your repo.
3. After including the API Key your Info.plist, it should look something like this:<img width="683" height="364" alt="image" src="https://github.com/user-attachments/assets/b0f9ab27-ae1b-4c4e-b187-39cca6114668" />
4. Make sure the Info.plist and Config.xcconfig file are added to the Target's Build Settings under Packaging like such:<img width="627" height="159" alt="image" src="https://github.com/user-attachments/assets/1cac5cf7-3cb7-4e6e-985b-8d0e7cb8cbc0" />

5. Add the SmartSpectraSDKSwift by right-clicking the project in Xcode sidebar and clicking on Add Package Dependencies... or by going to File -> "Add Package Dependencies...". In the "Search or Enter Package URL" field, enter the URL: "https://github.com/Presage-Security/SmartSpectra". For the "Dependency Rule," select "Branch" and then "main.". For "Add to Target," select your project.
6. Setup the signing and capabilities for the demo app target in Xcode. Make sure to select your development team and set a unique bundle identifier.
7. Connect your iOS device to your computer.
8. Select your device as the target in Xcode.
9. Click the "Run" button in Xcode to build and run the demo app on your device.
10. Follow the on-screen instructions in the app to conduct a measurement and view the results.

For more info on SmartSpectra SDK for iOS: [Github](https://github.com/Presage-Security/SmartSpectra/tree/main/swift) [Documentation](https://docs.physiology.presagetech.com/swift/documentation/smartspectraswiftsdk)

