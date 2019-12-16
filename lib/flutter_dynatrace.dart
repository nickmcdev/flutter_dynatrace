import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'dart:io' show Platform;

class Dynatrace {
  static const _platform = const MethodChannel('dev.nickmc.flutter_dynatrace/dynatrace');

  static final String url = "http://nickmcapache1.dtwlab.dynatrace.org:81/json/weather.json";

  static Future enterTest({String parentAction, String parentActionName, String subAction, String subActionName}) async {
    if (parentAction != null && parentActionName != null && subAction == null && subActionName == null) {
      try {
        debugPrint("Parent Action value: $parentAction, Parent Action name: $parentActionName");
        await _platform.invokeMethod('enterTest', {"enterParentActionTest": parentAction, "enterParentActionNameTest": parentActionName});
        } on PlatformException catch (e) {
      debugPrint("Failed to create User Action: '${e.message}'.");
      } 
    } else if (parentAction != null && parentActionName == null && subAction != null && subActionName != null) {
      try {
        debugPrint("Sub Action value: $subAction, Sub Action name: $subActionName");
        await _platform.invokeMethod('subTest', {"enterSubActionTest": subAction, "enterSubActionNameTest": subActionName, "enterSubActionParentAction": parentAction});
        } on PlatformException catch (e) {
      debugPrint("Failed to create User Action: '${e.message}'.");
      }
    } else {
      debugPrint("Wrong parameters used in function.");
    }
  }

  static Future leaveTest({String parentAction, String subAction}) async {
    if (parentAction != null && subAction == null) {
      try {
        await _platform.invokeMethod('leaveTest', {"leaveParentActionTest": parentAction});
        } on PlatformException catch (e) {
          debugPrint("Failed to leave Parent User Action: '${e.message}'.");
        }
      } else if (parentAction == null && subAction != null) {
        try {
          await _platform.invokeMethod('leaveSubTest', {"leaveSubActionTest": subAction});
          } on PlatformException catch (e) {
            debugPrint("Failed to leave Sub User Action: '${e.message}'.");
        }
      }
  }

  static Future reportValue({String parentAction, String subAction, String key, String stringValue, int intValue, doubleValue}) async {
    if (parentAction != null && subAction == null && key != null) {
      if (stringValue != null && intValue == null && doubleValue == null) {
        try {
          debugPrint("Parent Action value: $parentAction, Key: $key, String Value: $stringValue");
          await _platform.invokeMethod('reportStringParentTest', {"pActionRSTest": parentAction, "pActionRSKeyTest": key, "pActionRSValueTest": stringValue});
        } on PlatformException catch (e) {
          debugPrint("Failed to reportValue String with Parent User Action: '${e.message}'.");
        }
      } else if (stringValue == null && intValue != null && doubleValue == null) {
        try {
          debugPrint("Parent Action value: $parentAction, Key: $key, Int Value: $intValue");
          await _platform.invokeMethod('reportIntParentTest', {"pActionRITest": parentAction, "pActionRIKeyTest": key, "pActionRIValueTest": intValue});
        } on PlatformException catch (e) {
          debugPrint("Failed to reportValue Int with Parent User Action: '${e.message}'.");
        }
      } else if (stringValue == null && intValue == null && doubleValue != null) {
        try {
          debugPrint("Parent Action value: $parentAction, Key: $key, Double Value: $stringValue");
          await _platform.invokeMethod('reportDoubleParentTest', {"pActionRDTest": parentAction, "pActionRDKeyTest": key, "pActionRDValueTest": doubleValue});
        } on PlatformException catch (e) {
          debugPrint("Failed to reportValue Double with Parent User Action: '${e.message}'.");
        }
      } else {
        debugPrint("Wrong parameters used. Please add proper values for parentAction/subAction, key and either stringValue/intValue/doubleValue");
      }
    } else if (parentAction == null && subAction != null && key != null) {
      if (stringValue != null && intValue == null && doubleValue == null) {
        try {
          debugPrint("Sub Action value: $subAction, Key: $key, String Value: $stringValue");
          await _platform.invokeMethod('reportStringSubTest', {"sActionRSTest": subAction, "sActionRSKeyTest": key, "sActionRSValueTest": stringValue});
        } on PlatformException catch (e) {
          debugPrint("Failed to reportValue String with Sub User Action: '${e.message}'.");
        }
      } else if (stringValue == null && intValue != null && doubleValue == null) {
        try {
          debugPrint("Sub Action value: $subAction, Key: $key, Int Value: $intValue");
          await _platform.invokeMethod('reportIntSubTest', {"sActionRITest": subAction, "sActionRIKeyTest": key, "sActionRIValueTest": intValue});
        } on PlatformException catch (e) {
          debugPrint("Failed to reportValue Int with Sub User Action: '${e.message}'.");
        }
      } else if (stringValue == null && intValue == null && doubleValue != null) {
        try {
          debugPrint("Sub Action value: $subAction, Key: $key, Double Value: $stringValue");
          await _platform.invokeMethod('reportDoubleSubTest', {"sActionRDTest": subAction, "sActionRDKeyTest": key, "sActionRDValueTest": doubleValue});
        } on PlatformException catch (e) {
          debugPrint("Failed to reportValue Double with Sub User Action: '${e.message}'.");
        }
      } else {
        debugPrint("Wrong parameters used. Please add proper values for parentAction/subAction, key and either stringValue/intValue/doubleValue");
      }
    }
  }

  static Future reportEvent({String parentAction, String subAction, String event}) async {
    if (parentAction != null && subAction == null && event != null) {
      try {
          debugPrint("Parent Action value: $parentAction, Event: $event");
          await _platform.invokeMethod('reportEventParent', {"pActionRE": parentAction, "pActionREValue": event});
        } on PlatformException catch (e) {
          debugPrint("Failed to reportEvent with Parent User Action: '${e.message}'.");
        }
    } else if (parentAction == null && subAction != null && event != null) {
      try {
          debugPrint("Sub Action value: $subAction, Event: $event");
          await _platform.invokeMethod('reportEventSub', {"sActionRE": subAction, "sActionREValue": event});
        } on PlatformException catch (e) {
          debugPrint("Failed to reportEvent with Sub User Action: '${e.message}'.");
        }
    } else {
      debugPrint("Wrong parameters used. Please add proper values for parentAction/subAction and event");
    }
  }

  static Future reportError({String parentAction, String subAction, String error}) async {
    if (parentAction != null && subAction == null && error != null) {
      try {
          debugPrint("Parent Action value: $parentAction, Event: $error");
          await _platform.invokeMethod('reportErrorParent', {"pActionRErr": parentAction, "pActionRErrValue": error});
        } on PlatformException catch (e) {
          debugPrint("Failed to reportError with Parent User Action: '${e.message}'.");
        }
    } else if (parentAction == null && subAction != null && error != null) {
      try {
          debugPrint("Sub Action value: $subAction, Error: $error");
          await _platform.invokeMethod('reportErrorSub', {"sActionRErr": subAction, "sActionRErrValue": error});
        } on PlatformException catch (e) {
          debugPrint("Failed to reportError with Sub User Action: '${e.message}'.");
        }
    } else {
      debugPrint("Wrong parameters used. Please add proper values for parentAction/subAction and error");
    }
  }
    

  static Future<String> webUserAction(String url, String requestType) async {
    final String tagHeaderName = "x-dynatrace";
    int responseCode;
    String responseBody;
    String requestTag;

    requestTag = await webAction(url);
    debugPrint("x-dynatrace value = " + requestTag.toString());
    if (requestType == "GET") {
      var response = await http.get(Uri.encodeFull(url), headers: {tagHeaderName:requestTag});
      responseCode = response.statusCode;
      leaveWebUserAction(responseCode);
      responseBody = response.body;
      debugPrint("Response Status Code: " + responseCode.toString());
      debugPrint("Response Status Body: " + responseBody.toString());
    } else if (requestType == "POST") {
      var response = await http.post(Uri.encodeFull(url), headers: {tagHeaderName:requestTag});
      responseCode = response.statusCode;
      leaveWebUserAction(responseCode);
      responseBody = response.body;
      debugPrint("Response Status Code: " + responseCode.toString());
      debugPrint("Response Body: " + responseBody.toString());
    }
    return responseBody;
  }

  static Future<void> leaveWebUserAction(int responseCode) async {
    try {
      _platform.invokeMethod('webUserActionResponse', {"webUserActionResponseCode":responseCode});
    } on PlatformException catch (e) {
      debugPrint("Failed to leave Web User Action: '${e.message}'.");
    }
  }

  static Future<String> webAction(String url) async {
    String result;
    try {
      result = await _platform.invokeMethod('webUserActionEnter', {"webUserActionUrl":url});
    } on PlatformException catch (e) {
      debugPrint("Failed to create User Action: '${e.message}'.");
    }
    return result;
  }

  static Future flushEvents() async {
    try {
      await _platform.invokeMethod('flushEvents');
    } on PlatformException catch (e) {
      debugPrint("Failed to trigger flushEvents SDK call: '${e.message}'.");
    }
  }

  static Future endVisit() async {
    try {
      await _platform.invokeMethod('endVisit');
    } on PlatformException catch (e) {
      debugPrint("Failed to trigger endVisit SDK call: '${e.message}'.");
    }
  }

  static Future identifyUser(userTag) async {
    try {
      await _platform.invokeMethod('identifyUser', {"userTag":userTag});
    } on PlatformException catch (e) {
      debugPrint("Failed to trigger identifyUser SDK call: '${e.message}'.");
    }
  }

  static Future shutdown() async {
    try {
      await _platform.invokeMethod('shutdown');
    } on PlatformException catch (e) {
      debugPrint("Failed to trigger shutdown SDK call: '${e.message}'.");
    }
  }

  static Future setDataCollectionLevel(String level) async {
    int collLvl;
    if (level == "OFF" || level == "off" || level == "PERFORMANCE" || level == "performance" || level == "USER_BEHAVIOR" || level == "user_behavior") {

      if (level == "OFF" || level == "off") {
        collLvl = 0;
      } else if (level == "PERFORMANCE" || level == "performance") {
        collLvl = 1;
      } else if (level == "USER_BEHAVIOR" || level == "user_behavior") {
        collLvl = 2;
      }
      try {
        await _platform.invokeMethod('setDataCollectionLevel', {"dataCollectionLevel":collLvl});
      } on PlatformException catch (e) {
        debugPrint("Failed to trigger setDataCollectionLevel SDK call: '${e.message}'.");
      }
    } else {
      debugPrint("Wrong value for DataCollectionLevel. Please try OFF, PERFORMANCE or USER_BEHAVIOR");
    }
  }

  static Future setCrashReportingOptedIn(bool reportCrashes) async {
    try {
      await _platform.invokeMethod('setCrashReportingOptedIn', {"setCrashReportingOptedIn":reportCrashes});
    } on PlatformException catch (e) {
      debugPrint("Failed to set crash reporting capture status: '${e.message}'.");
    }
  }

  static Future<String> getDataCollectionLevel() async {
    String result;
    try {
      result = await _platform.invokeMethod('getDataCollectionLevel');
    } on PlatformException catch (e) {
      debugPrint("Failed to get data collection level: '${e.message}'.");
    }
    return result;
  }

  static Future<bool> getCaptureStatus() async {
    bool result;
    if (Platform.isAndroid) {
      try {
        result = await _platform.invokeMethod('getCaptureStatus');
      } on PlatformException catch (e) {
        debugPrint("Failed to get capture status: '${e.message}'.");
      }
    } else {
      debugPrint("This platform does not allow an Android agent only SDK call");
    }
    return result;
  }

  static Future<bool> isCrashReportingOptedIn() async {
    bool result;
    try {
      result = await _platform.invokeMethod('isCrashReportingOptedIn');
    } on PlatformException catch (e) {
      debugPrint("Failed to get crash reporting capture status: '${e.message}'.");
    }
    return result;
  }

  static Future startup(String appId, String beaconUrl, bool withDebugLogging, bool certValidation, bool crashReporting, bool optIn) async {
    try {
      await _platform.invokeMethod('startAndroidAgent', {"startupAgentParams": [appId, beaconUrl, withDebugLogging.toString(), certValidation.toString(), crashReporting.toString(), optIn.toString()]});
    } on PlatformException catch (e) {
      debugPrint("Failed to start Android Agent: '${e.message}'.");
    }
  }

  static Future startupWithInfoPlistSettings() async {
    try {
      await _platform.invokeMethod('startupWithInfoPlistSettings');
    } on PlatformException catch (e) {
      debugPrint("Failed to start iOS Agent: '${e.message}'.");
    }
  }

}



