//import Flutter
//import UIKit
//import Dynatrace
//
//public class SwiftFlutterDynatracePlugin: NSObject, FlutterPlugin {
//
//
//  public static func register(with registrar: FlutterPluginRegistrar) {
//    let channel = FlutterMethodChannel(name: "dev.nickmc.flutter_dynatrace/dynatrace", binaryMessenger: registrar.messenger())
//    let instance = SwiftFlutterDynatracePlugin()
//    registrar.addMethodCallDelegate(instance, channel: channel)
//  }
//
//  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
//    switch call.method {
//      case "enterAction0":
//        //var actionName0 = call.arguments("enterAction0Values")
//        let action0 = DTXAction.enter(withName: "Test Action 0")
//        action0?.leave()
//      case "enterAction1":
//        var actionName1 = call.arguments as! String
//        var action1 = DTXAction.enter(withName: "Test Action 1")
//        action1?.leave()
//        //result("iOS " + UIDevice.current.systemVersion)
//      case "enterAction2":
//        var actionName2 = call.arguments as! String
//        var action2 = DTXAction.enter(withName: "Test Action 2")
//        action2?.leave()
//      default:
//        result(FlutterMethodNotImplemented)
//    }
//  }
//}
import Flutter
import UIKit
import Dynatrace

public class SwiftFlutterDynatracePlugin: NSObject, FlutterPlugin {


  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "dev.nickmc.flutter_dynatrace/dynatrace", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterDynatracePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    var action0: DTXAction?
    var action1: DTXAction?
    var action2: DTXAction?
    
    var parentActions = [Int: DTXAction?]()
    var parentActionCounter: Int = 0;
    var subActions = [Int: [Int: DTXAction?]]()
    var subActionCounter: Int = 0;
    
    switch call.method {
        // TODO: Find a better system to handle and store actions - Tried a map/dictionary and array/list but for some reason UA reponse time was between 6 seconds and 20 seconds for a simple enter/leaveAction :(
    case "enterAction0":
        let argsEnterAction0 = call.arguments as! [String: Any]
        let actionName0 = argsEnterAction0["enterActionValues0"]  as! String
        action0 = DTXAction.enter(withName: actionName0)
        action0?.leave()
        parentActionCounter += 1
    case "enterAction1":
        let argsEnterAction1 = call.arguments as! [String: Any]
        let actionName1 = argsEnterAction1["enterActionValues1"]  as! String
        action1 = DTXAction.enter(withName: actionName1)
        action1?.leave()
    case "enterAction2":
        let argsEnterAction2 = call.arguments as! [String: Any]
        let actionName2 = argsEnterAction2["enterActionValues2"]  as! String
        action2 = DTXAction.enter(withName: actionName2)
        action2?.leave()
    case "leaveAction0":
        action0?.leave()
    case "leaveAction1":
        action1?.leave()
    case "leaveAction2":
        action2?.leave()
    case "endVisit":
        Dynatrace.endVisit()
    case "shutdown":
        Dynatrace.shutdown();
    case "flushEvents":
        Dynatrace.flushEvents();
    case "identifyUser":
        let argsUserTag = call.arguments as! [String: Any]
        let userTag = argsUserTag["userTag"] as! String
        Dynatrace.identifyUser(userTag)
    case "startupWithInfoPlistSettings":
        Dynatrace.startupWithInfoPlistSettings()
        
        // TODO: Add note in doc that if you set the data collection level to OFF or do not start the agent and trigger an enterAction via platform channel (Dynatrace.enterAction) the app will crash unless you use an optional and ensure you properly call the action and handle
    case "setDataCollectionLevel":
        let argsSetDataCollectionLevel = call.arguments as! [String: Any]
        let setDataCollectionLevel = argsSetDataCollectionLevel["dataCollectionLevel"] as! Int
        if (setDataCollectionLevel == 0) {
            Dynatrace.setDataCollectionLevel(DTX_DataCollectionLevel.off)
        } else if (setDataCollectionLevel == 1) {
            Dynatrace.setDataCollectionLevel(DTX_DataCollectionLevel.performance)
        } else if (setDataCollectionLevel == 2) {
            Dynatrace.setDataCollectionLevel(DTX_DataCollectionLevel.userBehavior)
        } else {
        }
    case "setCrashReportingOptedIn":
        let argsSetCrashReportingCaptureStatus = call.arguments as! [String: Any]
        let setCrashReportingCaptureStatus = argsSetCrashReportingCaptureStatus["setCrashReportingOptedIn"] as! Bool
        Dynatrace.setCrashReportingOptedIn(setCrashReportingCaptureStatus)
    case "isCrashReportingOptedIn":
        var isCrashReportingOptedIn: Bool
        isCrashReportingOptedIn = Dynatrace.crashReportingOptedIn()
        result(isCrashReportingOptedIn)
    case "getDataCollectionLevel":
        if (Dynatrace.dataCollectionLevel() == DTX_DataCollectionLevel.off) {
            result("OFF")
        } else if (Dynatrace.dataCollectionLevel() == DTX_DataCollectionLevel.userBehavior) {
            result("USER_BEHAVIOR")
        } else if (Dynatrace.dataCollectionLevel() == DTX_DataCollectionLevel.performance) {
            result("PERFORMANCE")
        }
    default:
        result(FlutterMethodNotImplemented)
    }
  }
}
