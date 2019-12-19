# flutter_dynatrace

This plugin allows you to use the Dynatrace Mobile SDKs (iOS and Android) to help monitor your Flutter apps. 

This plugin is **NOT** officially supported by Dynatrace. 


## How to use the plugin:
Android:
![Grade snippet in WebUI](https://github.com/nickmcdev/flutter_dynatrace/blob/master/example/doc/webUIGradle.png)
Add the code snippet from the WebUI to your Root build.gradle file:
![Grade snippet in Android Studio](https://github.com/nickmcdev/flutter_dynatrace/blob/master/example/doc/gradleUpdateAndroidStudio.png)
[Link to the official Dynatrace doc on implementing the above](https://www.dynatrace.com/support/help/shortlink/dynatrace-android-gradle-plugin-first-steps)

iOS:
Go to your project in terminal and run:
pod install
![pod install command in terminal](https://github.com/nickmcdev/flutter_dynatrace/blob/master/example/doc/podInstall.png)
Add the code snippet from the WebUI to your **Runner info.plist**:
![info.plist in WebUI](https://github.com/nickmcdev/flutter_dynatrace/blob/master/example/doc/infoPList.png)
![info.plist in Xcode](https://github.com/nickmcdev/flutter_dynatrace/blob/master/example/doc/flutterInfoPList.png)


### Starting the Agent manually:
````
import 'package:flutter_dynatrace/flutter_dynatrace.dart';
import 'dart:io' show Platform;

String appId = "updateThisValue";
String beaconUrl = "updateThisValue";

// This can be set in the initState function so that the agents can start when the app starts
@override
  void initState() {
	if (Platform.isIOS == true) {
		Dynatrace.startupWithInfoPlistSettings();
	} else if (Platform.isAndroid == true) {
		// startup(String appId, String beaconUrl, bool withDebugLogging, bool certValidation, bool crashReporting, bool optIn)
		Dynatrace.startup(appId, beaconUrl, true, false, false, false);

	super.initState();
  }

````


### Create user action:
You will need to use the following combinations of parameters(or this SDK call won’t work):
For enterAction:
parentAction and parentActionName
or
subAction, subActionName **AND** parentAction

For leaveAction:
parentAction
or
subAction

#### Single Action
````
Dynatrace.enterAction(parentAction: actions[0], parentActionName: "Touch on " + options[1]);
// do something
Dynatrace.leaveAction(parentAction: actions[0]);
````

#### Sub Actions
````
Dynatrace.enterAction(parentAction: actions[1], parentActionName: "Touch on " + options[2]);
// do something
Dynatrace.enterAction(subAction: actions[2], subActionName: "First Sub Action", parentAction: actions[1]);
// do something
Dynatrace.enterAction(subAction: actions[3], subActionName: "Second Sub Action", parentAction: actions[1]);
// do something
Dynatrace.enterAction(subAction: actions[4], subActionName: "Third Sub Action", parentAction: actions[1]);
// do something
Dynatrace.leaveAction(subAction: actions[4]);
Dynatrace.leaveAction(subAction: actions[3]);
Dynatrace.leaveAction(subAction: actions[2]);
Dynatrace.leaveAction(parentAction: actions[1]);
````

#### Web Action
````
String url = "https://dog.ceo/api/breeds/image/random";
Dynatrace.enterAction(parentAction: actions[5], parentActionName: "Touch on " + options[3]);
// This is used for web requests of application/json and will automatically tag and time the request and return of response body if you want to use it.
// I will add more functionality to this in upcoming releases/updates
// requestType can be "POST" or "GET" - if others are used, the web request will not occur
Dynatrace.dynaWebRequest(parentAction: actions[5], url: url, requestType: "GET");
Dynatrace.dynaWebRequest(parentAction: actions[5], url: url, requestType: "GET");
Dynatrace.dynaWebRequest(parentAction: actions[5], url: url, requestType: "GET");
Dynatrace.dynaWebRequest(parentAction: actions[5], url: url, requestType: "GET");
Dynatrace.dynaWebRequest(parentAction: actions[5], url: url, requestType: "GET");
Dynatrace.leaveAction(parentAction: actions[5]);
````

#### Web Action with reportValue (String)
````
Dynatrace.enterAction(parentAction: actions[6], parentActionName: "Touch on Web Action + reportString");
// This is used for web requests of application/json and will automatically tag and time the request and return of response body if you want to use it.
// I will add more functionality to this in upcoming releases/updates
// requestType can be "POST" or "GET" - if others are used, the web request will not occur
// set response to String of JSON
String reportValueMessage = await Dynatrace.dynaWebRequest(parentAction: actions[6], url: "https://dog.ceo/api/breeds/image/random", requestType: "GET");
// decode response
var jsonResp = json.decode(reportValueMessage);
// set new String to grab the key title's value
var message = jsonResp["message"];
// use the reportValue(string) SDK to put it in the waterfall
Dynatrace.reportValue(parentAction: actions[6], key: "Message", stringValue: message);
// leave action
Dynatrace.leaveAction(parentAction: actions[6]);
````

#### Using reportValue:
You will need to use the following combinations of parameters(or this SDK call won’t work):
parentAction, key AND either stringValue, intValue or doubleValue
or
subAction, key AND either stringValue, intValue or doubleValue

reportError will require parentAction || subAction + error as string (appednd .toString())
I will also try and find a better way to approach the reportError SDK call in future releases

reportEvent will require parentAction || subAction + event

````
int a = 100; 
int b = 0; 
int result;

Dynatrace.enterAction(parentAction: actions[12], parentActionName: "Touch on + " + options[10]);
Dynatrace.reportValue(parentAction: actions[12], key: "Dynatrace", stringValue: "All-in-one, all you need");
Dynatrace.reportValue(parentAction: actions[12], key: "Jenny", intValue: 8675309);
Dynatrace.reportValue(parentAction: actions[12], key: "Mobile", doubleValue: 1.337);
Dynatrace.reportEvent(parentAction: actions[12], event: "Data has been received!");
try {  
    result = a ~/ b; 
} catch(e) { 
    Dynatrace.reportError(parentAction: actions[12], error: e.toString()); 
} 
Dynatrace.leaveAction(parentAction: actions[12]);
````

#### Using identifyUser:
````
String userName = "flutter@dynatrace.com"; 
Dynatrace.identifyUser(userName);
````

#### No parameter SDK calls:
````
Dynatrace.flushEvents();
Dynatrace.endVisit();
Dynatrace.shutdown();
````

#### SDK calls with return values:
These will return a Future<T> instance so you will need to create a function that allows for the async await properties so that the value from the Native layer will not generate a future instance (just like Promises for JavaScript)
````
dataCollectionLevel() async {	
    String collLevel = await Dynatrace.getDataCollectionLevel();
	debugPrint(collLevel);
}

crashReportCapture() async {
	bool crashReport = await Dynatrace.isCrashReportingOptedIn();
	debugPrint(crashReport.toString());
}

isCaptureStatus() async {
	bool capture = await Dynatrace.getCaptureStatus();
	debugPrint(capture.toString());
}
````

### Results from the Example app in Dynatrace (Left is Android - Right is iOS):
Overall Sessions:
![Sessions](https://github.com/nickmcdev/flutter_dynatrace/blob/master/example/doc/exampleAppAndroidLeftiOSRight.png) 

Single Action:
![Single Action](https://github.com/nickmcdev/flutter_dynatrace/blob/master/example/doc/singleAction.png) 

Sub Actions:
![Sub Actions](https://github.com/nickmcdev/flutter_dynatrace/blob/master/example/doc/subActions.png) 

Web Action:
![Web Action](https://github.com/nickmcdev/flutter_dynatrace/blob/master/example/doc/webAction.png)

Web Action with reportString:
![Web Action](https://github.com/nickmcdev/flutter_dynatrace/blob/master/example/doc/webActionReportString.png)

reportValue - String:
![reportValue - String](https://github.com/nickmcdev/flutter_dynatrace/blob/master/example/doc/reportString.png)

reportValue - Int:
![reportValue - Int](https://github.com/nickmcdev/flutter_dynatrace/blob/master/example/doc/reportInt.png)

reportValue - Double:
![reportValue - Double](https://github.com/nickmcdev/flutter_dynatrace/blob/master/example/doc/reportDouble.png)

reportEvent:
![reportEvent](https://github.com/nickmcdev/flutter_dynatrace/blob/master/example/doc/reportEvent.png)

reportError:
![reportError](https://github.com/nickmcdev/flutter_dynatrace/blob/master/example/doc/reportError.png)

reportValues:
![reportValues](https://github.com/nickmcdev/flutter_dynatrace/blob/master/example/doc/reportValues.png)

I will provide more examples and features in upcoming releases. Any feedback on what you like and or don't like and what would be useful to have changed/updated, would be fantastic!

Thanks!
