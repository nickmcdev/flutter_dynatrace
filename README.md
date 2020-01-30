# flutter_dynatrace

This plugin allows you to use the Dynatrace Mobile SDKs (iOS and Android) to help monitor your Flutter apps. Please give the example app attached to the plugin repo a go if you want to test out the similar SDK calls in this doc.

This plugin is **NOT** officially supported by Dynatrace. 


## How to use the plugin:
### Android:
![Grade snippet in WebUI](https://github.com/nickmcdev/flutter_dynatrace/blob/master/example/doc/webUIGradle.png)

Add the code snippet from the WebUI to your Root build.gradle file:
![Grade snippet in Android Studio](https://github.com/nickmcdev/flutter_dynatrace/blob/master/example/doc/gradleUpdateAndroidStudio.png)
[Link to the official Dynatrace doc on implementing the above](https://www.dynatrace.com/support/help/shortlink/dynatrace-android-gradle-plugin-first-steps)

### iOS:

{{#callout}}
**IMPORTANT:** If your project uses the default Objective-C and **NOT** Swift as the iOS language used, you will **need** to create a .swift file and create a bridging header as this plugin uses swift and not Objective-C. Here is a stackoverflow post relating to this:
https://stackoverflow.com/questions/50096025/it-gives-errors-when-using-swift-static-library-with-objective-c-project/50495316#50495316
{{/callout}}

Open up the **Runner** project in Xcode and create a new file in the **Runner** folder and create the bridging header when Xcode prompts this. You should see the following result (or something similar of course):
![Bridging Header](https://github.com/nickmcdev/flutter_dynatrace/blob/master/example/doc/bridgingHeader.png) 

---

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
---

### Single/Parent Action:

**Dynatrace.enterAction();**
Required parameters:
- parentAction
- parentActionName

**Dynatrace.leaveAction();**
Required parameters:
- parentAction

````
Dynatrace.enterAction(parentAction: actions[0], parentActionName: "Touch on " + options[1]);
// do something
Dynatrace.leaveAction(parentAction: actions[0]);
````

**Result:**
![Single Action](https://github.com/nickmcdev/flutter_dynatrace/blob/master/example/doc/singleAction.png) 

---

### Sub Actions:

**Dynatrace.enterAction();**
Required parameters:
- parentAction
- subAction
- subActionName

**Dynatrace.leaveAction();**
Required parameters:
- subAction


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

**Result:**
![Sub Actions](https://github.com/nickmcdev/flutter_dynatrace/blob/master/example/doc/subActions.png) 

---

### Web Action (Needs to be inside of a Parent or Sub Action):

*Note:* Currently have this set for JSON requests and request types of **POST or GET**. I will work on making this more dynamic in the future.

**Dynatrace.dynaWebRequest();**
Required parameters:
- parentAction **OR** subAction
- url
- requestType
  - "GET"
  - "POST"

````
List<String> urls = ["https://dog.ceo/api/breed/husky/image/random", "https://dog.ceo/api/breed/labrador/image/random", "https://dog.ceo/api/breed/retriever/images/random", "https://dog.ceo/api/breed/sheepdog/images/random", "https://dog.ceo/api/breed/chow/images/random"];
Dynatrace.enterAction(parentAction: actions[5], parentActionName: "Touch on " + options[3]);
// This is used for web requests of application/json and will automatically tag and time the request and return of response body if you want to use it.
// I will add more functionality to this in upcoming releases/updates
// requestType can be "POST" or "GET" - if others are used, the web request will not occur
Dynatrace.dynaWebRequest(parentAction: actions[5], url: urls[0], requestType: "GET");
Dynatrace.dynaWebRequest(parentAction: actions[5], url: urls[1], requestType: "GET");
Dynatrace.dynaWebRequest(parentAction: actions[5], url: urls[2], requestType: "GET");
Dynatrace.dynaWebRequest(parentAction: actions[5], url: urls[3], requestType: "GET");
Dynatrace.dynaWebRequest(parentAction: actions[5], url: urls[4], requestType: "GET");
Dynatrace.leaveAction(parentAction: actions[5]);
````

**Result:**
![Web Action](https://github.com/nickmcdev/flutter_dynatrace/blob/master/example/doc/webAction.png)

---

### Web Action - Option 2 (Needs to be inside of a Parent or Sub Action):

**Dynatrace.enterWebUserAction();**
Required parameters:
- parentAction **OR** subAction
- url

This future returns a string that includes the **x-dynatrace** header that you need to add as a header value to your http request. 

**Dynatrace.leaveWebUserAction();**
Required parameters:
- parentAction **OR** subAction
- url
- dynaHeader 
- responseCode

**Note:** You will need to use the return value of the future API call **Dynatrace.enterWebUserAction()** as the value for **dynaHeader**,

````
final String dynaHeaderKey = "x-dynatrace";
// or you can use the following API call which will always be x-dynatrace:
final String dynaHeaderKey2 = Dynatrace.getRequestTagHeader();

// enter parent user action
Dynatrace.enterAction(parentAction: actions[13], parentActionName: "Touch on Web Action - Option 2");
// enter sub action
Dynatrace.enterAction(parentAction: actions[13], subAction: actions[14], subActionName: "Sub Web Action - Option 2");
    
    // enter parent web action
String dynaHeaderValue = await Dynatrace.enterWebUserAction(url: url, parentAction: actions[13]);
var response = await http.get(Uri.encodeFull(url), headers: {dynaHeaderKey: dynaHeaderValue});

    // enter sub web action
String dynaHeaderValueSub = await Dynatrace.enterWebUserAction(url: url, subAction: actions[14]);
var responseSub = await http.get(Uri.encodeFull(url), headers: {dynaHeaderKey: dynaHeaderValueSub});
    // leave parent web action
Dynatrace.leaveWebUserAction(parentAction: actions[13], url: url, dynaHeader: dynaHeaderValue, responseCode: response.statusCode);

    // leave sub web action
Dynatrace.leaveWebUserAction(subAction: actions[14], url: url, dynaHeader: dynaHeaderValueSub, responseCode: responseSub.statusCode);
// leave sub user action
Dynatrace.leaveAction(subAction: actions[14]);

// leave parent user action
Dynatrace.leaveAction(parentAction: actions[13]);
````

**Result:**
![Web Action 2 - Android](https://github.com/nickmcdev/flutter_dynatrace/blob/master/example/doc/webAction2Android.png)
![Web Action 2 - iOS](https://github.com/nickmcdev/flutter_dynatrace/blob/master/example/doc/webAction2iOS.png)


### Web Action with reportValue - String:

**Dynatrace.reportValue(); (String)**
Required parameters:
- parentAction **OR** subAction
- key
- stringValue

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

**Result:**
![Web Action with reportString](https://github.com/nickmcdev/flutter_dynatrace/blob/master/example/doc/webActionReportString.png)

With just a parentAction and reportString:
![reportValue - String](https://github.com/nickmcdev/flutter_dynatrace/blob/master/example/doc/reportString.png)

---

### reportValue - Int:

**Dynatrace.reportValue(); (Int)**
Required parameters:
- parentAction **OR** subAction
- key
- intValue

````
Dynatrace.enterAction(parentAction: actions[8], parentActionName: "Touch on + " + options[6]);
Dynatrace.reportValue(parentAction: actions[8], key: "Jenny", intValue: 8675309);
Dynatrace.leaveAction(parentAction: actions[8]);
````

**Result:**
![reportValue - Int](https://github.com/nickmcdev/flutter_dynatrace/blob/master/example/doc/reportInt.png)

---

### reportValue - Double:

**Dynatrace.reportValue(); (Double)**
Required parameters:
- parentAction **OR** subAction
- key
- doubleValue

````
Dynatrace.enterAction(parentAction: actions[9], parentActionName: "Touch on + " + options[7]);
Dynatrace.reportValue(parentAction: actions[9], key: "Mobile", doubleValue: 1.337);
Dynatrace.leaveAction(parentAction: actions[9]);
````

**Result:**
![reportValue - Double](https://github.com/nickmcdev/flutter_dynatrace/blob/master/example/doc/reportDouble.png)

---

### reportEvent:

**Dynatrace.reportEvent();**
Required parameters:
- parentAction **OR** subAction
- event

````
Dynatrace.enterAction(parentAction: actions[10], parentActionName: "Touch on + " + options[8]);
Dynatrace.reportEvent(parentAction: actions[10], event: "Data has been received!");
Dynatrace.leaveAction(parentAction: actions[10]);
````

**Result:**
![reportEvent](https://github.com/nickmcdev/flutter_dynatrace/blob/master/example/doc/reportEvent.png)

---

### reportError:

This is essentially the same implementation as reportEvent currently. I will update this in a future release.

**Dynatrace.reportError();**
Required parameters:
- parentAction **OR** subAction
- error

````
int a = 100; 
int b = 0; 
int result;

Dynatrace.enterAction(parentAction: actions[12], parentActionName: "Touch on + " + options[10]);

	try {  
    	result = a ~/ b; 
    } catch(e) { 
        Dynatrace.reportError(parentAction: actions[12], error: e.toString()); 
    } 

Dynatrace.leaveAction(parentAction: actions[12]);
````

**Result:**
![reportError2](https://github.com/nickmcdev/flutter_dynatrace/blob/master/example/doc/reportError2.png)
![reportError](https://github.com/nickmcdev/flutter_dynatrace/blob/master/example/doc/reportError.png)

---

### All options for reportValue + reportEvent + reportError:

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

**Result:**
![reportValues](https://github.com/nickmcdev/flutter_dynatrace/blob/master/example/doc/reportValues.png)

---

### Using identifyUser:
````
String userName = "flutter@dynatrace.com"; 
Dynatrace.identifyUser(userName);
````
---

### Setting Data Collection Level:
````
// Set level to off - You can use "OFF" or "off"
Dynatrace.setDataCollectionLevel("OFF");

// Set level to performance - You can use "PERFORMANCE" or "performance"
Dynatrace.setDataCollectionLevel("PERFORMANCE");

// Set level to user behavior - You can use "USER_BEHAVIOR" or "user_behavior"
Dynatrace.setDataCollectionLevel("USER_BEHAVIOR");
````
---

### Setting Crash Reporting Capture:
````
// On
Dynatrace.setCrashReportingOptedIn(true);

// Off
Dynatrace.setCrashReportingOptedIn(false);
````
---

### No parameter SDK calls:

````
Dynatrace.flushEvents();
Dynatrace.endVisit();
Dynatrace.shutdown();
````
---

### SDK calls with return values:
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
---

### Results from the Example app in Dynatrace (Left is Android - Right is iOS):
Overall Session view from the above examples:
![Sessions](https://github.com/nickmcdev/flutter_dynatrace/blob/master/example/doc/exampleAppAndroidLeftiOSRight.png) 

---

I will provide more examples and features in upcoming releases. Any feedback on what you like and or don't like and what would be useful to have changed/updated, would be fantastic!

Thanks!
