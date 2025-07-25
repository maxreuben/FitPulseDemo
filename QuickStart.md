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
3. After including the API Key your Info.plist, it should look something like this:-<img width="683" height="364" alt="image" src="https://github.com/user-attachments/assets/b0f9ab27-ae1b-4c4e-b187-39cca6114668" />
