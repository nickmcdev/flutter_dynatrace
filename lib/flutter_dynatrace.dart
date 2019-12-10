import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'dart:io' show Platform;

class Dynatrace {
  // Event type calls
  static const _platform = const MethodChannel('dev.nickmc.flutter_dynatrace/dynatrace');

  static final String url = "http://nickmcapache1.dtwlab.dynatrace.org:81/json/weather.json";
  static int _parentActionCounter = 0;

  static List<String> _parentActions = new List();
  static List<String> _subActions0 = new List();
  static List<String> _subActions1 = new List();
  static List<String> _subActions2 = new List();

  // TODO: Find a better system to handle and store actions - Tried a map/dictionary and array/list but for some reason UA reponse time was between 6 seconds and 20 seconds for a simple enter/leaveAction :(
  static Future enterAction(String parentAction, String parentActionName) async {
    _parentActions = ["", "", ""];
    try {
      switch(_parentActionCounter) {
        case 0: {
          _parentActions[0] = parentAction;
          //await _platform.invokeMethod('enterAction0');
          await _platform.invokeMethod('enterAction0', {"enterActionValues0": parentActionName});
          debugPrint("Parent Action value: $parentAction, Parent Action name: $parentActionName");
          _parentActionCounter++;
        }
        break;

        case 1: {
          _parentActions[1] = parentAction;
          await _platform.invokeMethod('enterAction1', {"enterActionValues1": parentActionName});
          //await _platform.invokeMethod('enterAction1');
          debugPrint("Parent Action value: $parentAction, Parent Action name: $parentActionName");
          _parentActionCounter++;
        }
        break;

        case 2: {
          _parentActions[2] = parentAction;
          await _platform.invokeMethod('enterAction2', {"enterActionValues2": parentActionName});
          //await _platform.invokeMethod('enterAction2');
          debugPrint("Parent Action value: $parentAction, Parent Action name: $parentActionName");
          _parentActionCounter = 0;
        }
        break;

        default: {
          debugPrint("parentActionCounter is 3 or greater");
        }
        break;
      }
    } on PlatformException catch (e) {
      debugPrint("Failed to create User Action: '${e.message}'.");
    }
  }

  static Future leaveAction(String parentAction) async {

  //Android
    int parentActionId;
    final List<String> platformUA = ['leaveAction0', 'leaveAction1', 'leaveAction2'];
    if (_parentActions.indexOf(parentAction) != -1) {
      parentActionId = _parentActions.indexOf(parentAction);
    } else {
      parentActionId = -100;
      debugPrint(parentActionId.toString());
      debugPrint("There are no active parent actions with that name!");
    }
    try {
      await _platform.invokeMethod(platformUA[parentActionId]);
      debugPrint(parentActionId.toString());
      debugPrint("Attempting invoke of leaveAction on Native-side!");
    } on PlatformException catch (e) {
      debugPrint("Failed to leave User Action: '${e.message}'.");
    }
  }
  //iOS
//    int parentActionId;
//
//    if (_parentActions.indexOf(parentAction) != -1) {
//      parentActionId = _parentActions.indexOf(parentAction);
//    } else {
//      parentActionId = -100;
//      debugPrint(parentActionId.toString());
//      debugPrint("There are no active parent actions with that name!");
//    }
//    try {
//      switch(parentActionId) {
//        case 0: {
//          await _platform.invokeMethod('leaveAction0');
//        }
//        break;
//
//        case 1: {
//          await _platform.invokeMethod('leaveAction1');
//        }
//        break;
//
//        case 2: {
//          await _platform.invokeMethod('leaveAction2');
//        }
//        break;
//
//        default: {
//          debugPrint("parentActionCounter is 3 or greater");
//        }
//        break;
//
//      }
//    } on PlatformException catch (e) {
//      debugPrint("Failed to leave parent User Action: '${e.message}'.");
//    }
//  }

  static Future enterSubAction(String parentAction, String subAction, String subActionName) async {
    int parentActionId;

    if (_parentActions.indexOf(parentAction) != -1) {
      parentActionId = _parentActions.indexOf(parentAction);
    } else {
      debugPrint("There are no active parent actions with that name!");
    }
    try {
      switch(parentActionId) {
        case 0: {
          _subActions0.add(subAction);
          await _platform.invokeMethod('enterSubAction0', {"enterSubActionValues0": subActionName});
          debugPrint("Sub Action value: $subAction, Sub Action name: $subActionName");
        }
        break;

        case 1: {
          _subActions1.add(subAction);
          await _platform.invokeMethod('enterSubAction1', {"enterSubActionValues1": subActionName});
          debugPrint("Sub Action value: $subAction, Sub Action name: $subActionName");
        }
        break;

        case 2: {
          _subActions2.add(subAction);
          await _platform.invokeMethod('enterSubAction2', {"enterSubActionValues2": subActionName});
          debugPrint("Sub Action value: $subAction, Sub Action name: $subActionName");
        }
        break;

        default: {
          debugPrint("parentActionCounter is 3 or greater");
        }
        break;

      }
    } on PlatformException catch (e) {
      debugPrint("Failed to create Sub User Action: '${e.message}'.");
    }
  }

  static Future leaveSubAction(String parentAction, String subAction) async {
    int parentActionId;
    int subActionId;

    if (_parentActions.indexOf(parentAction) != -1) {
      parentActionId = _parentActions.indexOf(parentAction);
    } else {
      debugPrint("There are no active sub actions with that name!");
    }
    try {
      switch(parentActionId) {
        case 0: {
          if (_subActions0.indexOf(subAction) != -1) {
            subActionId = _subActions0.indexOf(subAction);
          } else {
            debugPrint("There are no active parent actions with that name!");
          }
          await _platform.invokeMethod('leaveSubAction0', {"leaveSubActionValues0": subActionId});
          debugPrint("Sub Action value: $subAction");
        }
        break;

        case 1: {
          if (_subActions1.indexOf(subAction) != -1) {
            subActionId = _subActions1.indexOf(subAction);
          } else {
            debugPrint("There are no active parent actions with that name!");
          }
          await _platform.invokeMethod('leaveSubAction1', {"leaveSubActionValues1": subActionId});
          debugPrint("Sub Action value: $subAction");
        }
        break;

        case 2: {
          if (_subActions2.indexOf(subAction) != -1) {
            subActionId = _subActions2.indexOf(subAction);
          } else {
            debugPrint("There are no active parent actions with that name!");
          }
          await _platform.invokeMethod('leaveSubAction2', {"leaveSubActionValues2": subActionId});
          debugPrint("Sub Action value: $subAction");
        }
        break;

        default: {
          debugPrint("parentActionCounter is 3 or greater");
        }
        break;

      }
    } on PlatformException catch (e) {
      debugPrint("Failed to leave Sub User Action: '${e.message}'.");
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

  static Future reportValueString(String parentAction, String key, String value) async {
    int parentActionId;
    if (_parentActions.indexOf(parentAction) != -1) {
      parentActionId = _parentActions.indexOf(parentAction);
    } else {
      debugPrint("There are no active parent actions with that name!");
    }
    try {
      switch(parentActionId) {
        case 0: {
          List<String> reportStringValues = [key, value];
          await _platform.invokeMethod('reportString0', {"reportStringValues0": reportStringValues});
          debugPrint("Parent Action value: $parentAction, Key: $key, Value: $value");
          reportStringValues.clear();
        }
        break;

        case 1: {
          List<String> reportStringValues = [key, value];
          await _platform.invokeMethod('reportString1', {"reportStringValues1": reportStringValues});
          debugPrint("Parent Action value: $parentAction, Key: $key, Value: $value");
          reportStringValues.clear();
        }
        break;

        case 2: {
          List<String> reportStringValues = [key, value];
          await _platform.invokeMethod('reportString2', {"reportStringValues2": reportStringValues});
          debugPrint("Parent Action value: $parentAction, Key: $key, Value: $value");
          reportStringValues.clear();
        }
        break;

        default: {
          debugPrint("parentActionCounter is 3 or greater");
        }
        break;
      }
    } on PlatformException catch (e) {
      debugPrint("Failed to create User Action: '${e.message}'.");
    }
  }

  static Future reportValueInt(String parentAction, String key, int value) async {
    int parentActionId;
    if (_parentActions.indexOf(parentAction) != -1) {
      parentActionId = _parentActions.indexOf(parentAction);
    } else {
      debugPrint("There are no active parent actions with that name!");
    }
    try {
      switch(parentActionId) {
        case 0: {
          List<String> reportIntValues = [key, value.toString()];
          await _platform.invokeMethod('reportInt0', {"reportIntValues0": reportIntValues});
          debugPrint("Parent Action value: $parentAction, Key: $key, Value: $value");
          reportIntValues.clear();
        }
        break;

        case 1: {
          List<String> reportIntValues = [key, value.toString()];
          await _platform.invokeMethod('reportInt1', {"reportIntValues1": reportIntValues});
          debugPrint("Parent Action value: $parentAction, Key: $key, Value: $value");
          reportIntValues.clear();
        }
        break;

        case 2: {
          List<String> reportIntValues = [key, value.toString()];
          await _platform.invokeMethod('reportInt2', {"reportIntValues2": reportIntValues});
          debugPrint("Parent Action value: $parentAction, Key: $key, Value: $value");
          reportIntValues.clear();
        }
        break;

        default: {
          debugPrint("parentActionCounter is 3 or greater");
        }
        break;
      }
    } on PlatformException catch (e) {
      debugPrint("Failed to create User Action: '${e.message}'.");
    }
  }

  static Future reportValueDouble(String parentAction, String key, double value) async {
    int parentActionId;
    if (_parentActions.indexOf(parentAction) != -1) {
      parentActionId = _parentActions.indexOf(parentAction);
    } else {
      debugPrint("There are no active parent actions with that name!");
    }
    try {
      switch(parentActionId) {
        case 0: {
          List<String> reportDoubleValues = [key, value.toString()];
          await _platform.invokeMethod('reportDouble0', {"reportDoubleValues0": reportDoubleValues});
          debugPrint("Parent Action value: $parentAction, Key: $key, Value: $value");
          reportDoubleValues.clear();
        }
        break;

        case 1: {
          List<String> reportDoubleValues = [key, value.toString()];
          await _platform.invokeMethod('reportDouble1', {"reportDoubleValues1": reportDoubleValues});
          debugPrint("Parent Action value: $parentAction, Key: $key, Value: $value");
          reportDoubleValues.clear();
        }
        break;

        case 2: {
          List<String> reportDoubleValues = [key, value.toString()];
          await _platform.invokeMethod('reportDouble2', {"reportDoubleValues2": reportDoubleValues});
          debugPrint("Parent Action value: $parentAction, Key: $key, Value: $value");
          reportDoubleValues.clear();
        }
        break;

        default: {
          debugPrint("parentActionCounter is 3 or greater");
        }
        break;
      }
    } on PlatformException catch (e) {
      debugPrint("Failed to create User Action: '${e.message}'.");
    }
  }

  static Future reportError(String parentAction, String key, int value) async {
    int parentActionId;
    if (_parentActions.indexOf(parentAction) != -1) {
      parentActionId = _parentActions.indexOf(parentAction);
    } else {
      debugPrint("There are no active parent actions with that name!");
    }
    try {
      switch(parentActionId) {
        case 0: {
          List<String> reportErrorValues = [key, value.toString()];
          await _platform.invokeMethod('reportError0', {"reportErrorValues0": reportErrorValues});
          debugPrint("Parent Action value: $parentAction, Key: $key, Value: $value");
          reportErrorValues.clear();
        }
        break;

        case 1: {
          List<String> reportErrorValues = [key, value.toString()];
          await _platform.invokeMethod('reportError1', {"reportErrorValues1": reportErrorValues});
          debugPrint("Parent Action value: $parentAction, Key: $key, Value: $value");
          reportErrorValues.clear();
        }
        break;

        case 2: {
          List<String> reportErrorValues = [key, value.toString()];
          await _platform.invokeMethod('reportError2', {"reportErrorValues2": reportErrorValues});
          debugPrint("Parent Action value: $parentAction, Key: $key, Value: $value");
          reportErrorValues.clear();
        }
        break;

        default: {
          debugPrint("parentActionCounter is 3 or greater");
        }
        break;
      }
    } on PlatformException catch (e) {
      debugPrint("Failed to create User Action: '${e.message}'.");
    }
  }

  static Future reportErrorThrowable(String parentAction, String errorName, String throwable) async {
    int parentActionId;
    if (_parentActions.indexOf(parentAction) != -1) {
      parentActionId = _parentActions.indexOf(parentAction);
    } else {
      debugPrint("There are no active parent actions with that name!");
    }
    try {
      switch(parentActionId) {
        case 0: {
          List<String> reportErrorThrowableValues = [errorName, throwable];
          await _platform.invokeMethod('reportErrorThrowable0', {"reportErrorThrowableValues0": reportErrorThrowableValues});
          debugPrint("Parent Action value: $parentAction, Key: $errorName, Value: $throwable");
          reportErrorThrowableValues.clear();
        }
        break;

        case 1: {
          List<String> reportErrorThrowableValues = [errorName, throwable];
          await _platform.invokeMethod('reportErrorThrowable1', {"reportErrorThrowableValues1": reportErrorThrowableValues});
          debugPrint("Parent Action value: $parentAction, Key: $errorName, Value: $throwable");
          reportErrorThrowableValues.clear();
        }
        break;

        case 2: {
          List<String> reportErrorThrowableValues = [errorName, throwable];
          await _platform.invokeMethod('reportErrorThrowable2', {"reportErrorThrowableValues2": reportErrorThrowableValues});
          debugPrint("Parent Action value: $parentAction, Key: $errorName, Value: $throwable");
          reportErrorThrowableValues.clear();
        }
        break;

        default: {
          debugPrint("parentActionCounter is 3 or greater");
        }
        break;
      }
    } on PlatformException catch (e) {
      debugPrint("Failed to create User Action: '${e.message}'.");
    }
  }

  static Future reportErrorNA(String errorName, String error) async {
    try {
      await _platform.invokeMethod('reportErrorNA', {"reportErrorNA": [errorName, error.toString()]});
    } on PlatformException catch (e) {
      debugPrint("Failed to trigger reportDouble with no action: '${e.message}'.");
    }
  }

  static Future reportErrorThrowableNA(String errorName, String throwable) async {
    try {
      await _platform.invokeMethod('reportErrorThrowableNA', {"reportErrorThrowableNA": [errorName, throwable.toString()]});
    } on PlatformException catch (e) {
      debugPrint("Failed to trigger reportDouble with no action: '${e.message}'.");
    }
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



