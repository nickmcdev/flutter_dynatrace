import Flutter
import UIKit
import Dynatrace

public class SwiftFlutterDynatracePlugin: NSObject, FlutterPlugin {
    
    var parentActionId: Int = 0
    var parentActions: [String: DTXAction] = [:]
    var parentActionList = [DTXAction?]()
    
    var subActionId: Int = 0
    var subActions: [String: DTXAction] = [:]
    var subActionList = [DTXAction?]()
    
//    // Web Request
    var webParentActionId: Int = 0
    var webParentActions: [String: DTXWebRequestTiming] = [:]
    var webParentActionTimings = [DTXWebRequestTiming?]()
    
    var webSubActionId: Int = 0
    var webSubActions: [String: DTXWebRequestTiming] = [:]
    var webSubActionTimings = [DTXWebRequestTiming?]()
    
    
    var webActionList = [DTXAction?]()
    var webAction: DTXAction?
    var wrStatusCode: Int = -1
    var webrequestTiming: DTXWebRequestTiming?


  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "dev.nickmc.flutter_dynatrace/dynatrace", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterDynatracePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    
    switch call.method {
    case "enterAction":
        let argsEnterAction = call.arguments as! [String: Any]
        let parentAction = argsEnterAction["enterParentAction"] as! String
        let parentActionName = argsEnterAction["enterParentActionName"]  as! String
        self.parentActionList.append(DTXAction.enter(withName: parentActionName))
        print("ActionId: \(self.parentActionId)")
        self.parentActions[parentAction] = self.parentActionList[parentActionId]
        print("Parent Action Id: \(parentActionId)")
        self.parentActionId += 1
        print("Parent Action Id: \(parentActionId)")
        print(parentActionName)
        print(parentAction)
        
    case "subAction":
        let argsEnterSubAction = call.arguments as! [String: Any]
        let subAction = argsEnterSubAction["enterSubAction"] as! String
        let subActionName = argsEnterSubAction["enterSubActionName"]  as! String
        let parentAction = argsEnterSubAction["enterSubActionParentAction"] as! String
        self.subActionList.append(DTXAction.enter(withName: subActionName, parentAction: parentActions[parentAction]))
        print("ActionId: \(self.subActionId)")
        self.subActions[subAction] = self.subActionList[subActionId]
        print("Sub Action Id: \(subActionId)")
        self.subActionId += 1
        print("Sub Action Id: \(subActionId)")
        print(subActionName)
        print(subAction)
        
    case "leaveAction":
        let argsLeaveAction = call.arguments as! [String: Any]
        let parentAction = argsLeaveAction["leaveParentAction"] as! String
        parentActions[parentAction]?.leave()
        print(parentActions.keys)
        if parentActions[parentAction] == nil {
            print("No entry for action named \(parentAction)")
        }
        
    case "leaveSubAction":
        let argsLeaveAction = call.arguments as! [String: Any]
        let subAction = argsLeaveAction["leaveSubAction"] as! String
        subActions[subAction]?.leave()
        print(subActions.keys)
        if parentActions[subAction] == nil {
            print("No entry for action named \(subAction)")
        }
        
    case "webUserActionEnter":
        let argsEnterWebAction = call.arguments as! [String: Any]
        let urlFromFlutter = argsEnterWebAction["webUserActionUrl"] as! String
        var xdyna: String?
        let url = URL(string: urlFromFlutter)
        self.webAction = DTXAction.enter(withName: "WebRequest: \(urlFromFlutter)")
        if let dynatraceHeaderValue = Dynatrace.getRequestTagValue(for: url) {
            self.webrequestTiming = DTXWebRequestTiming.getDTXWebRequestTiming(dynatraceHeaderValue, request: url)
            xdyna = dynatraceHeaderValue
        }
        if (url != nil) {
            self.webrequestTiming?.start()
            result(xdyna);
        } else {
            result("Not able to capture Web User Action as URL is nil");
        }
        
    case "webParentActionEnter":
            let argsEnterWebAction = call.arguments as! [String: Any]
            let urlFromFlutter = argsEnterWebAction["webParentActionUrl"] as! String
            let webParentAction: Int = webParentActionId
            print("TESTDTX: URL: \(urlFromFlutter)")
            var xdyna: String?
            let url = URL(string: urlFromFlutter)
            if let dynatraceHeaderValue = Dynatrace.getRequestTagValue(for: url) {
                self.webParentActions[urlFromFlutter] = DTXWebRequestTiming.getDTXWebRequestTiming(dynatraceHeaderValue, request: url)
                xdyna = dynatraceHeaderValue
            }
            
            print("TESTDTX: Web Action Id: \(webParentAction)")
            self.webParentActionId += 1
            print("TESTDTX: Web Action Id: \(webParentAction)")
            if (url != nil) {
                self.webParentActions[urlFromFlutter]?.start()
                print(xdyna as Any)
                result(xdyna)
            } else {
                result("Not able to capture Web User Action as URL is nil");
            }
        
    case "webParentActionResponse":
        let argsLeaveWebAction = call.arguments as! [String: Any]
        let wrStatusCode = argsLeaveWebAction["webParentActionResponseCode"] as! Int
        let webParentActionLeaveUrl = argsLeaveWebAction["webParentActionLeaveUrl"] as! String
        if (wrStatusCode != 200) {
            webParentActions[webParentActionLeaveUrl]?.stop("Failed request: \(wrStatusCode)")
            if let value = webParentActions.removeValue(forKey: webParentActionLeaveUrl) {
                print("The value \(value) was removed.")
            } else {
                print("No value found for that key.")
            }
            print("TESTDTX: Web Request Failed!")
        } else {
            webParentActions[webParentActionLeaveUrl]?.stop("200")
            if let value = webParentActions.removeValue(forKey: webParentActionLeaveUrl) {
                print("The value \(value) was removed.")
            } else {
                print("No value found for that key.")
            }
            print("TESTDTX: Web Request Successful!")
        }
        
    case "webSubActionEnter":
            let argsEnterWebSubAction = call.arguments as! [String: Any]
            let urlFromFlutter = argsEnterWebSubAction["webSubActionUrl"] as! String
            let webSubAction: Int = webSubActionId
            print("TESTDTX: URL: \(urlFromFlutter)")
            var xdyna: String?
            let url = URL(string: urlFromFlutter)
            if let dynatraceHeaderValue = Dynatrace.getRequestTagValue(for: url) {
                self.webSubActionTimings.append(DTXWebRequestTiming.getDTXWebRequestTiming(dynatraceHeaderValue, request: url))
                self.webSubActions[urlFromFlutter] = self.webSubActionTimings[webSubAction]
                xdyna = dynatraceHeaderValue
            }
            
            print("TESTDTX: Web Action Id: \(webSubAction)")
            self.webSubActionId += 1
            print("TESTDTX: Web Action Id: \(webSubAction)")
            if (url != nil) {
                self.webSubActions[urlFromFlutter]?.start()
                print(xdyna as Any)
                result(xdyna)
            } else {
                result("Not able to capture Web User Action as URL is nil");
            }
        
    case "webSubActionResponse":
        let argsLeaveWebSubAction = call.arguments as! [String: Any]
        let wrStatusCode = argsLeaveWebSubAction["webSubActionResponseCode"] as! Int
        let webSubActionLeaveUrl = argsLeaveWebSubAction["webSubActionLeaveUrl"] as! String
        if (wrStatusCode != 200) {
            webSubActions[webSubActionLeaveUrl]?.stop("Failed request: \(wrStatusCode)")
            print("TESTDTX: Web Request Failed!")
        } else {
            webSubActions[webSubActionLeaveUrl]?.stop("200")
            print("TESTDTX: Web Request Successful!")
        }
        
    case "reportStringParent":
        let argsReportStringParentAction = call.arguments as! [String: Any]
        let parentAction = argsReportStringParentAction["pActionRS"] as! String
        let keyParentAction = argsReportStringParentAction["pActionRSKey"]  as! String
        let stringValueParentAction = argsReportStringParentAction["pActionRSValue"] as! String
        print(parentAction)
        print(keyParentAction)
        print(stringValueParentAction)
        parentActions[parentAction]?.reportValue(withName: keyParentAction, stringValue: stringValueParentAction)
    
    case "reportIntParent":
        let argsReportIntParentAction = call.arguments as! [String: Any]
        let parentAction = argsReportIntParentAction["pActionRI"] as! String
        let keyParentAction = argsReportIntParentAction["pActionRIKey"]  as! String
        let intValueParentAction = argsReportIntParentAction["pActionRIValue"] as! Int64
        print(parentAction)
        print(keyParentAction)
        print(intValueParentAction)
        parentActions[parentAction]?.reportValue(withName: keyParentAction, intValue: intValueParentAction)
        
    case "reportDoubleParent":
        let argsReportDoubleParentAction = call.arguments as! [String: Any]
        let parentAction = argsReportDoubleParentAction["pActionRD"] as! String
        let keyParentAction = argsReportDoubleParentAction["pActionRDKey"]  as! String
        let doubleValueParentAction = argsReportDoubleParentAction["pActionRDValue"] as! Double
        print(parentAction)
        print(keyParentAction)
        print(doubleValueParentAction)
        parentActions[parentAction]?.reportValue(withName: keyParentAction, doubleValue: doubleValueParentAction)
    
    case "reportStringSub":
        let argsReportStringSubAction = call.arguments as! [String: Any]
        let subAction = argsReportStringSubAction["sActionRS"] as! String
        let keySubAction = argsReportStringSubAction["sActionRSKey"]  as! String
        let stringValueSubAction = argsReportStringSubAction["sActionRSValue"] as! String
        print(subAction)
        print(keySubAction)
        print(stringValueSubAction)
        subActions[subAction]?.reportValue(withName: keySubAction, stringValue: stringValueSubAction)
    
    case "reportIntSub":
        let argsReportIntSubAction = call.arguments as! [String: Any]
        let subAction = argsReportIntSubAction["sActionRI"] as! String
        let keySubAction = argsReportIntSubAction["sActionRIKey"]  as! String
        let intValueSubAction = argsReportIntSubAction["sActionRIValue"] as! Int64
        print(subAction)
        print(keySubAction)
        print(intValueSubAction)
        subActions[subAction]?.reportValue(withName: keySubAction, intValue: intValueSubAction)
        
    case "reportDoubleSub":
        let argsReportDoubleSubAction = call.arguments as! [String: Any]
        let subAction = argsReportDoubleSubAction["sActionRD"] as! String
        let keySubAction = argsReportDoubleSubAction["sActionRDKey"]  as! String
        let doubleValueSubAction = argsReportDoubleSubAction["sActionRDValue"] as! Double
        print(subAction)
        print(keySubAction)
        print(doubleValueSubAction)
        subActions[subAction]?.reportValue(withName: keySubAction, doubleValue: doubleValueSubAction)
        
    case "reportEventParent":
        let argsReportEventParentAction = call.arguments as! [String: Any]
        let parentAction = argsReportEventParentAction["pActionRE"] as! String
        let reportEventValue = argsReportEventParentAction["pActionREValue"]  as! String
        print(parentAction)
        print(reportEventValue)
        parentActions[parentAction]?.reportEvent(withName: reportEventValue)
        
    case "reportEventSub":
        let argsReportEventSubAction = call.arguments as! [String: Any]
        let subAction = argsReportEventSubAction["sActionRE"] as! String
        let reportEventValue = argsReportEventSubAction["sActionREValue"]  as! String
        print(subAction)
        print(reportEventValue)
        subActions[subAction]?.reportEvent(withName: reportEventValue)
    
    case "reportErrorParent":
        let argsReportErrorParentAction = call.arguments as! [String: Any]
        let parentAction = argsReportErrorParentAction["pActionRErr"] as! String
        let reportErrorValue = argsReportErrorParentAction["pActionRErrValue"]  as! String
        print(parentAction)
        print(reportErrorValue)
        parentActions[parentAction]?.reportEvent(withName: reportErrorValue)
        
    case "reportErrorSub":
        let argsReportErrorSubAction = call.arguments as! [String: Any]
        let subAction = argsReportErrorSubAction["sActionRErr"] as! String
        let reportErrorValue = argsReportErrorSubAction["sActionRErrValue"]  as! String
        print(subAction)
        print(reportErrorValue)
        subActions[subAction]?.reportEvent(withName: reportErrorValue)
    
    case "endVisit":
        Dynatrace.endVisit()
        
    case "shutdown":
        Dynatrace.shutdown()
        
    case "flushEvents":
        Dynatrace.flushEvents()
        
    case "identifyUser":
        let argsUserTag = call.arguments as! [String: Any]
        let userTag = argsUserTag["userTag"] as! String
        Dynatrace.identifyUser(userTag)
        
    case "startupWithInfoPlistSettings":
        Dynatrace.startupWithInfoPlistSettings()
        
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
        print("Capture status on?: \(DTX_StatusCode.captureOn)")
        
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
