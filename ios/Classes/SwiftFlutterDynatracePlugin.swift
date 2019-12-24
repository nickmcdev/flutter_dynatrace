import Flutter
import UIKit
import Dynatrace

public class SwiftFlutterDynatracePlugin: NSObject, FlutterPlugin {
    
    var parentActions: [String: DTXAction] = [:]
    var subActions: [String: DTXAction] = [:]
    
//    // Web Request
    var webParentActions: [String: DTXWebRequestTiming] = [:]
    var webParentActionsTest: [String: DTXWebRequestTiming] = [:]
    var webSubActions: [String: DTXWebRequestTiming] = [:]
    var wrStatusCode: Int = -1
    var wrParentWRNum: Int = 0


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
        self.parentActions[parentAction] = DTXAction.enter(withName: parentActionName)
        
    case "subAction":
        let argsEnterSubAction = call.arguments as! [String: Any]
        let subAction = argsEnterSubAction["enterSubAction"] as! String
        let subActionName = argsEnterSubAction["enterSubActionName"]  as! String
        let parentAction = argsEnterSubAction["enterSubActionParentAction"] as! String
        self.subActions[subAction] = DTXAction.enter(withName: subActionName, parentAction: parentActions[parentAction])
        print(subActionName)
        print(subAction)
        
    case "leaveAction":
        let argsLeaveAction = call.arguments as! [String: Any]
        let parentAction = argsLeaveAction["leaveParentAction"] as! String
        print(parentActions.keys)
        if parentActions.keys.contains(parentAction) {
            parentActions[parentAction]?.leave()
            parentActions.removeValue(forKey: parentAction)
            print("The value was removed from Parent Action dictionary.")
        } else {
            print("No entry for action named \(parentAction)")
        }
        
    case "leaveSubAction":
        let argsLeaveAction = call.arguments as! [String: Any]
        let subAction = argsLeaveAction["leaveSubAction"] as! String
        print(subActions.keys)
        if subActions.keys.contains(subAction) {
            subActions[subAction]?.leave()
            subActions.removeValue(forKey: subAction)
            print("The value was removed from Parent Action dictionary.")
        } else {
            print("No entry for action named \(subAction)")
        }
        
    case "webParentActionEnter":
        let argsEnterWebAction = call.arguments as! [String: Any]
        let urlFromFlutter = argsEnterWebAction["webParentActionUrl"] as! String
        var urlInfo = [String]()
        let urlTimeMil = Date().currentTimeMillis()
        var urlTimeMilStr = ("\(urlTimeMil)")
        if webParentActions.keys.contains(urlTimeMilStr) {
            urlTimeMilStr = ("\(urlTimeMilStr)_1")
        } else if webParentActions.keys.contains("\(urlTimeMilStr)_1") {
            urlTimeMilStr = ("\(urlTimeMilStr)_2")
        }
        urlInfo.append(urlTimeMilStr)
        let url = URL(string: urlFromFlutter)
        if let dynatraceHeaderValue = Dynatrace.getRequestTagValue(for: url) {
            self.webParentActions[urlTimeMilStr] = DTXWebRequestTiming.getDTXWebRequestTiming(dynatraceHeaderValue, request: url)
            urlInfo.append(dynatraceHeaderValue)
        }
        
        if (url != nil) {
            self.webParentActions[urlTimeMilStr]?.start()
            print(urlInfo[0])
            print(urlInfo[1] as Any)
            result(urlInfo)
            urlInfo.removeAll()
        } else {
            result("Not able to capture Web User Action as URL is nil");
            urlInfo.removeAll()
        }
        
    case "webParentActionResponse":
        let argsLeaveWebAction = call.arguments as! [String: Any]
        let wrStatusCode = argsLeaveWebAction["webParentActionResponseCode"] as! Int
        let webParentActionLeaveTime = argsLeaveWebAction["webParentActionLeaveTime"] as! String
        print("URL Status Code: \(wrStatusCode)")
        print("URL Timing: \(webParentActionLeaveTime)")
        if (wrStatusCode != 200) {
            if webParentActions.keys.contains(webParentActionLeaveTime) {
                webParentActions[webParentActionLeaveTime]?.stop("Failed request: \(wrStatusCode)")
                webParentActions.removeValue(forKey: webParentActionLeaveTime)
                print("The value was removed from Web Parent Action dictionary.")
            } else {
                print("No value found for that key in Web Parent Action dictionary.")
            }
            print("TESTDTX: Web Request Failed!")
        } else {
            if webParentActions.keys.contains(webParentActionLeaveTime) {
                webParentActions[webParentActionLeaveTime]?.stop("200")
                webParentActions.removeValue(forKey: webParentActionLeaveTime)
                print("The value was removed from Web Parent Action dictionary.")
            } else {
                print("No value found for that key in Web Parent Action dictionary.")
            }
            print("TESTDTX: Web Request Successful!")
        }
        
    case "webSubActionEnter":
            let argsEnterWebSubAction = call.arguments as! [String: Any]
            let urlFromFlutter = argsEnterWebSubAction["webSubActionUrl"] as! String
            var urlInfo = [String]()
            let urlTimeMil = Date().currentTimeMillis()
            var urlTimeMilStr = ("\(urlTimeMil)")
            if webSubActions.keys.contains(urlTimeMilStr) {
                urlTimeMilStr = ("\(urlTimeMilStr)_1")
            } else if webSubActions.keys.contains("\(urlTimeMilStr)_1") {
                urlTimeMilStr = ("\(urlTimeMilStr)_2")
            }
            urlInfo.append(urlTimeMilStr)
            let url = URL(string: urlFromFlutter)
            if let dynatraceHeaderValue = Dynatrace.getRequestTagValue(for: url) {
                self.webSubActions[urlTimeMilStr] = DTXWebRequestTiming.getDTXWebRequestTiming(dynatraceHeaderValue, request: url)
                urlInfo.append(dynatraceHeaderValue)
            }
            
            if (url != nil) {
                self.webSubActions[urlTimeMilStr]?.start()
                print(urlInfo[0])
                print(urlInfo[1] as Any)
                result(urlInfo)
                urlInfo.removeAll()
            } else {
                result("Not able to capture Web Sub User Action as URL is nil");
                urlInfo.removeAll()
            }
        
    case "webSubActionResponse":
        let argsLeaveWebSubAction = call.arguments as! [String: Any]
        let wrStatusCode = argsLeaveWebSubAction["webSubActionResponseCode"] as! Int
        let webSubActionLeaveTime = argsLeaveWebSubAction["webSubActionLeaveTime"] as! String
        print("URL Status Code: \(wrStatusCode)")
        print("URL Timing: \(webSubActionLeaveTime)")
        if (wrStatusCode != 200) {
            if webSubActions.keys.contains(webSubActionLeaveTime) {
                webSubActions[webSubActionLeaveTime]?.stop("Failed request: \(wrStatusCode)")
                webSubActions.removeValue(forKey: webSubActionLeaveTime)
                print("The value was removed from Web Sub Action dictionary.")
            } else {
                print("No value found for that key in Web Sub Action dictionary.")
            }
            print("TESTDTX: Web Request Failed!")
        } else {
            if webSubActions.keys.contains(webSubActionLeaveTime) {
                webSubActions[webSubActionLeaveTime]?.stop("200")
                webSubActions.removeValue(forKey: webSubActionLeaveTime)
                print("The value was removed from Web Sub Action dictionary.")
            } else {
                print("No value found for that key in Web Sub Action dictionary.")
            }
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

// Get current time in milliseconds
extension Date {
    func currentTimeMillis() -> Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}
