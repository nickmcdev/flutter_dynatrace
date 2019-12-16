import Flutter
import UIKit
import Dynatrace

public class SwiftFlutterDynatracePlugin: NSObject, FlutterPlugin {
    
    var parentActionId: Int = 0
    var parentActionsTest: [String: DTXAction] = [:]
    var parentActionList = [DTXAction?]()
    
    var subActionId: Int = 0
    var subActionsTest: [String: DTXAction] = [:]
    var subActionList = [DTXAction?]()
    
//    // Web Request
    var webActionId: Int = 0
    var webActionsTest: [Int: DTXAction] = [:]
    var webActionList = [DTXAction?]()
    var webAction: DTXAction?
//    var requestTag: String
//    var requestTagHeaderName: String
//    var url: String
    var wrStatusCode: Int = -1
    var webrequestTiming: DTXWebRequestTiming?


  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "dev.nickmc.flutter_dynatrace/dynatrace", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterDynatracePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
//    var action0: DTXAction?
//    var action1: DTXAction?
//    var action2: DTXAction?
//
//    var parentActions: [Int: DTXAction] = [:]
//
//    var parentActionCounter = 0
    
    
    switch call.method {
    case "enterTest":
        let argsEnterAction = call.arguments as! [String: Any]
        let parentAction = argsEnterAction["enterParentActionTest"] as! String
        let parentActionName = argsEnterAction["enterParentActionNameTest"]  as! String
        self.parentActionList.append(DTXAction.enter(withName: parentActionName))
        print("ActionId: \(self.parentActionId)")
        self.parentActionsTest[parentAction] = self.parentActionList[parentActionId]
        print("Parent Action Id: \(parentActionId)")
        self.parentActionId += 1
        print("Parent Action Id: \(parentActionId)")
        print(parentActionName)
        print(parentAction)
        
    case "subTest":
        let argsEnterSubAction = call.arguments as! [String: Any]
        let subAction = argsEnterSubAction["enterSubActionTest"] as! String
        let subActionName = argsEnterSubAction["enterSubActionNameTest"]  as! String
        let parentAction = argsEnterSubAction["enterSubActionParentAction"] as! String
        self.subActionList.append(DTXAction.enter(withName: subActionName, parentAction: parentActionsTest[parentAction]))
        print("ActionId: \(self.subActionId)")
        self.subActionsTest[subAction] = self.subActionList[subActionId]
        print("Sub Action Id: \(subActionId)")
        self.subActionId += 1
        print("Sub Action Id: \(subActionId)")
        print(subActionName)
        print(subAction)
        
    case "leaveTest":
        let argsLeaveAction = call.arguments as! [String: Any]
        let parentAction = argsLeaveAction["leaveParentActionTest"] as! String
        parentActionsTest[parentAction]?.leave()
        print(parentActionsTest.keys)
        //parentActionsTest.removeValue(forKey: parentAction)
        if parentActionsTest[parentAction] == nil {
            print("No entry for action named \(parentAction)")
        }
        
    case "leaveSubTest":
        let argsLeaveAction = call.arguments as! [String: Any]
        let subAction = argsLeaveAction["leaveSubActionTest"] as! String
        subActionsTest[subAction]?.leave()
        print(subActionsTest.keys)
        //parentActionsTest.removeValue(forKey: parentAction)
        if parentActionsTest[subAction] == nil {
            print("No entry for action named \(subAction)")
        }
        
    case "webUserActionEnter":
        let argsEnterWebAction = call.arguments as! [String: Any]
        let urlFromFlutter = argsEnterWebAction["webUserActionUrl"] as! String
        //var webAction: Int = webActionId
        var xdyna: String?
        let url = URL(string: urlFromFlutter)
        self.webAction = DTXAction.enter(withName: "WebRequest: \(urlFromFlutter)")
        if let dynatraceHeaderValue = Dynatrace.getRequestTagValue(for: url) {
            self.webrequestTiming = DTXWebRequestTiming.getDTXWebRequestTiming(dynatraceHeaderValue, request: url)
            xdyna = dynatraceHeaderValue
        }
        //self.webActionList.append(DTXAction.enter(withName: "WebRequest: \(urlFromFlutter)"))
        
//        print("WebActionId: \(self.webActionId)")
//        self.webActionsTest[webAction] = self.parentActionList[webActionId]
//        print("Web Action Id: \(webActionId)")
//        self.webActionId += 1
//        print("Web Action Id: \(webActionId)")
        //self.webAction = DTXAction.enter(withName: "WebRequest: \(urlFromFlutter)")
        if (url != nil) {
            self.webrequestTiming?.start()
            result(xdyna);
        } else {
            result("Not able to capture Web User Action as URL is nil");
        }
        
    case "webUserActionEnterTest":
            let argsEnterWebAction = call.arguments as! [String: Any]
            let urlFromFlutter = argsEnterWebAction["webUserActionUrl"] as! String
            let data: [String: Any]
            let webAction: Int = webActionId
            var xdyna: String?
            let url = URL(string: urlFromFlutter)
            self.webActionList.append(DTXAction.enter(withName: "WebRequest: \(urlFromFlutter)"))
            self.webActionsTest[webAction] = self.webActionList[webAction]
            if let dynatraceHeaderValue = Dynatrace.getRequestTagValue(for: url) {
                self.webrequestTiming = DTXWebRequestTiming.getDTXWebRequestTiming(dynatraceHeaderValue, request: url)
                xdyna = dynatraceHeaderValue
            }
            
            print("Web Action Id: \(webActionId)")
            self.webActionId += 1
            print("Web Action Id: \(webActionId)")
            if (url != nil) {
                data = ["x-dynatrace": xdyna as Any, "webActionId": webAction]
                self.webrequestTiming?.start()
                result(data)
                //result(xdyna);
            } else {
                result("Not able to capture Web User Action as URL is nil");
            }


    case "webUserActionResponse":
        let argsLeaveWebAction = call.arguments as! [String: Any]
        self.wrStatusCode = argsLeaveWebAction["webUserActionResponseCode"] as! Int
        //let webAction = argsLeaveWebAction["webUserActionUrl"] as! Int
        if (wrStatusCode != 200) {
            self.webrequestTiming?.stop("Failed request: \(wrStatusCode)")
            self.webAction?.leave()
            //webActionsTest[webAction]?.leave()
            print("Web Request Failed!")
        } else {
            self.webrequestTiming?.stop("200")
            self.webAction?.leave()
            //webActionsTest[webAction]?.leave()
            print("Web Request Successful!")
        }
    case "webUserActionResponseTest":
        let argsLeaveWebAction = call.arguments as! [String: Any]
        let wrStatusCode = argsLeaveWebAction["webUserActionResponseCode"] as! Int
        let webAction = argsLeaveWebAction["webUserActionId"] as! Int
        if (wrStatusCode != 200) {
            webrequestTiming?.stop("Failed request: \(wrStatusCode)")
            //self.webAction?.leave()
            webActionsTest[webAction]?.leave()
            print("Web Request Failed!")
        } else {
            webrequestTiming?.stop("200")
            //self.webAction?.leave()
            webActionsTest[webAction]?.leave()
            print("Web Request Successful!")
        }
        
    case "reportStringParentTest":
        let argsReportStringParentAction = call.arguments as! [String: Any]
        let parentAction = argsReportStringParentAction["pActionRSTest"] as! String
        let keyParentAction = argsReportStringParentAction["pActionRSKeyTest"]  as! String
        let stringValueParentAction = argsReportStringParentAction["pActionRSValueTest"] as! String
        print(parentAction)
        print(keyParentAction)
        print(stringValueParentAction)
        parentActionsTest[parentAction]?.reportValue(withName: keyParentAction, stringValue: stringValueParentAction)
    
    case "reportIntParentTest":
        let argsReportIntParentAction = call.arguments as! [String: Any]
        let parentAction = argsReportIntParentAction["pActionRITest"] as! String
        let keyParentAction = argsReportIntParentAction["pActionRIKeyTest"]  as! String
        let intValueParentAction = argsReportIntParentAction["pActionRIValueTest"] as! Int64
        print(parentAction)
        print(keyParentAction)
        print(intValueParentAction)
        parentActionsTest[parentAction]?.reportValue(withName: keyParentAction, intValue: intValueParentAction)
        
    case "reportDoubleParentTest":
        let argsReportDoubleParentAction = call.arguments as! [String: Any]
        let parentAction = argsReportDoubleParentAction["pActionRDTest"] as! String
        let keyParentAction = argsReportDoubleParentAction["pActionRDKeyTest"]  as! String
        let doubleValueParentAction = argsReportDoubleParentAction["pActionRDValueTest"] as! Double
        print(parentAction)
        print(keyParentAction)
        print(doubleValueParentAction)
        parentActionsTest[parentAction]?.reportValue(withName: keyParentAction, doubleValue: doubleValueParentAction)
    
    case "reportStringSubTest":
        let argsReportStringSubAction = call.arguments as! [String: Any]
        let subAction = argsReportStringSubAction["sActionRSTest"] as! String
        let keySubAction = argsReportStringSubAction["sActionRSKeyTest"]  as! String
        let stringValueSubAction = argsReportStringSubAction["sActionRSValueTest"] as! String
        print(subAction)
        print(keySubAction)
        print(stringValueSubAction)
        subActionsTest[subAction]?.reportValue(withName: keySubAction, stringValue: stringValueSubAction)
    
    case "reportIntSubTest":
        let argsReportIntSubAction = call.arguments as! [String: Any]
        let subAction = argsReportIntSubAction["sActionRITest"] as! String
        let keySubAction = argsReportIntSubAction["sActionRIKeyTest"]  as! String
        let intValueSubAction = argsReportIntSubAction["sActionRIValueTest"] as! Int64
        print(subAction)
        print(keySubAction)
        print(intValueSubAction)
        subActionsTest[subAction]?.reportValue(withName: keySubAction, intValue: intValueSubAction)
        
    case "reportDoubleSubTest":
        let argsReportDoubleSubAction = call.arguments as! [String: Any]
        let subAction = argsReportDoubleSubAction["sActionRDTest"] as! String
        let keySubAction = argsReportDoubleSubAction["sActionRDKeyTest"]  as! String
        let doubleValueSubAction = argsReportDoubleSubAction["sActionRDValueTest"] as! Double
        print(subAction)
        print(keySubAction)
        print(doubleValueSubAction)
        subActionsTest[subAction]?.reportValue(withName: keySubAction, doubleValue: doubleValueSubAction)
        
    case "reportEventParent":
        let argsReportEventParentAction = call.arguments as! [String: Any]
        let parentAction = argsReportEventParentAction["pActionRE"] as! String
        let reportEventValue = argsReportEventParentAction["pActionREValue"]  as! String
        print(parentAction)
        print(reportEventValue)
        parentActionsTest[parentAction]?.reportEvent(withName: reportEventValue)
        
    case "reportEventSub":
        let argsReportEventSubAction = call.arguments as! [String: Any]
        let subAction = argsReportEventSubAction["sActionRE"] as! String
        let reportEventValue = argsReportEventSubAction["sActionREValue"]  as! String
        print(subAction)
        print(reportEventValue)
        subActionsTest[subAction]?.reportEvent(withName: reportEventValue)
    
    case "reportErrorParent":
        let argsReportErrorParentAction = call.arguments as! [String: Any]
        let parentAction = argsReportErrorParentAction["pActionRErr"] as! String
        let reportErrorValue = argsReportErrorParentAction["pActionRErrValue"]  as! String
        print(parentAction)
        print(reportErrorValue)
        parentActionsTest[parentAction]?.reportEvent(withName: reportErrorValue)
        
    case "reportErrorSub":
        let argsReportErrorSubAction = call.arguments as! [String: Any]
        let subAction = argsReportErrorSubAction["sActionRErr"] as! String
        let reportErrorValue = argsReportErrorSubAction["sActionRErrValue"]  as! String
        print(subAction)
        print(reportErrorValue)
        subActionsTest[subAction]?.reportEvent(withName: reportErrorValue)
    
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
