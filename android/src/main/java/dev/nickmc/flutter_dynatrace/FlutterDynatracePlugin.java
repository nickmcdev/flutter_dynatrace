package dev.nickmc.flutter_dynatrace;

import android.app.Activity;
import android.content.Context;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.os.BatteryManager;
import android.telephony.TelephonyManager;
import android.util.Log;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import java.net.MalformedURLException;
import java.net.URL;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import com.dynatrace.android.agent.DTXAction;
import com.dynatrace.android.agent.Dynatrace;
import com.dynatrace.android.agent.WebRequestTiming;
import com.dynatrace.android.agent.conf.DataCollectionLevel;
import com.dynatrace.android.agent.conf.DynatraceConfigurationBuilder;

/** FlutterDynatracePlugin */
public class FlutterDynatracePlugin implements MethodCallHandler {
  private final Activity activity;

  // Tenant info:
  String appId = "daf8fa7f-899a-41bd-8d5f-7a414010dea6";
  String beaconUrl = "https://bf96722syz.bf.dynatrace.com/mbeacon";
  boolean withDebugLogging = true;

  // User Actions
  Map<String, DTXAction> parentActionsMap = new HashMap();
  Map<String, DTXAction> subActionsMap = new HashMap();

  // Web Requests
  Map<String, WebRequestTiming> webParentActions = new HashMap();
  Map<String, WebRequestTiming> webSubActions = new HashMap();

  // Metric Actions
  DTXAction batteryLevel;
  DTXAction connectionType;

  // startupAgent
  ArrayList<String> startupAgentParams = new ArrayList<String>();


  // Platform channel
  private static final String dyna = "dev.nickmc.flutter_dynatrace/dynatrace";


  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), dyna);
    channel.setMethodCallHandler(new FlutterDynatracePlugin(registrar.activity()));
  }

  private FlutterDynatracePlugin(Activity activity) {
    this.activity = activity;
  }

  public void onMethodCall(MethodCall call, Result result) {
    switch (call.method) {
    case "enterAction":
      String parentAction = call.argument("enterParentAction");
      String parentActionName = call.argument("enterParentActionName");
      Log.d("enterAction", "Parent Action: " + parentAction);
      Log.d("enterAction", "Parent Action name: " + parentActionName);
//      parentActionsList.add(Dynatrace.enterAction(parentActionName));
//      parentActionsMap.put(parentAction, parentActionsList.get(parentActionCount));
      parentActionsMap.put(parentAction, Dynatrace.enterAction(parentActionName));
//      parentActionCount++;
      break;

    case "leaveAction":
      String parentActionLeave = call.argument("leaveParentAction");
      parentActionsMap.get(parentActionLeave).leaveAction();
      break;

    case "subAction":
      String subAction = call.argument("enterSubAction");
      String subActionName = call.argument("enterSubActionName");
      String parentActionSub = call.argument("enterSubActionParentAction");
      Log.d("enterSubAction", "Sub Action: " + subAction);
      Log.d("enterSubAction", "Sub Action name: " + subActionName);
      subActionsMap.put(subAction, Dynatrace.enterAction(subActionName, parentActionsMap.get(parentActionSub)));
      break;

    case "leaveSubAction":
      String subActionLeave = call.argument("leaveSubAction");
      Log.d("leaveSubAction", "Sub Action: " + subActionLeave);
      subActionsMap.get(subActionLeave).leaveAction();
      break;

    case "webParentActionEnter":
      String urlFromFlutter = call.argument("webParentActionUrl");
      String webParentAction = call.argument("webParentAction");
      URL url = null;
      try {
        url = new URL(urlFromFlutter);
      } catch (MalformedURLException e) {
        e.printStackTrace();
      }

      String requestTag = parentActionsMap.get(webParentAction).getRequestTag();
      webParentActions.put(urlFromFlutter, Dynatrace.getWebRequestTiming(requestTag));
      if (url != null) {
        Log.d("DTXWeb", "URL: " + urlFromFlutter);
        webParentActions.get(urlFromFlutter).startWebRequestTiming();
//        webParentActionId++;
        result.success(requestTag);
      }

      break;

    case "webParentActionResponse":
      String webParentActionLeaveUrl = call.argument("webParentActionLeaveUrl");
      int wrStatusCodeParent = call.argument("webParentActionResponseCode");

      if (wrStatusCodeParent != 200) {
        try {
          webParentActions.get(webParentActionLeaveUrl).stopWebRequestTiming(webParentActionLeaveUrl, wrStatusCodeParent, "Failed request.");
        } catch (MalformedURLException e) {
          e.printStackTrace();
        }
      } else if (wrStatusCodeParent == 200) {
        try {
          webParentActions.get(webParentActionLeaveUrl).stopWebRequestTiming(webParentActionLeaveUrl, wrStatusCodeParent, "OK");
        } catch (MalformedURLException e) {
          e.printStackTrace();
        }
      }
      break;

    case "webSubActionEnter":
      String urlFromFlutterSub = call.argument("webSubActionUrl");
      String webSubAction = call.argument("webSubAction");
      URL urlSub = null;
      try {
        urlSub = new URL(urlFromFlutterSub);
      } catch (MalformedURLException e) {
        e.printStackTrace();
      }

      String requestTagSub = subActionsMap.get(webSubAction).getRequestTag();
      webSubActions.put(urlFromFlutterSub, Dynatrace.getWebRequestTiming(requestTagSub));
      if (urlSub != null) {
        Log.d("DTXWeb", "URL: " + urlFromFlutterSub);
        webSubActions.get(urlFromFlutterSub).startWebRequestTiming();
        result.success(requestTagSub);
      }

      break;

    case "webSubActionResponse":
      String webSubActionLeaveUrl = call.argument("webSubActionLeaveUrl");
      int wrStatusCodeSub = call.argument("webSubActionResponseCode");

      if (wrStatusCodeSub != 200) {
        try {
          webSubActions.get(webSubActionLeaveUrl).stopWebRequestTiming(webSubActionLeaveUrl, wrStatusCodeSub, "Failed request.");
        } catch (MalformedURLException e) {
          e.printStackTrace();
        }
      } else if (wrStatusCodeSub == 200) {
        try {
          webSubActions.get(webSubActionLeaveUrl).stopWebRequestTiming(webSubActionLeaveUrl, wrStatusCodeSub, "OK");
        } catch (MalformedURLException e) {
          e.printStackTrace();
        }
      }
      break;

    case "reportStringParent":
      String parentActionRS = call.argument("pActionRS");
      String parentActionRSKey = call.argument("pActionRSKey");
      String parentActionRSValue = call.argument("pActionRSValue");
      parentActionsMap.get(parentActionRS).reportValue(parentActionRSKey, parentActionRSValue);
      break;

    case "reportIntParent":
      String parentActionRI = call.argument("pActionRI");
      String parentActionRIKey = call.argument("pActionRIKey");
      int parentActionRIValue = call.argument("pActionRIValue");
      parentActionsMap.get(parentActionRI).reportValue(parentActionRIKey, parentActionRIValue);
      break;

    case "reportDoubleParent":
      String parentActionRD = call.argument("pActionRD");
      String parentActionRDKey = call.argument("pActionRDKey");
      double parentActionRDValue = call.argument("pActionRDValue");
      parentActionsMap.get(parentActionRD).reportValue(parentActionRDKey, parentActionRDValue);
      break;

    case "reportEventParent":
      String parentActionRE = call.argument("pActionRE");
      String parentActionREventValue = call.argument("pActionREValue");
      parentActionsMap.get(parentActionRE).reportEvent(parentActionREventValue);
      break;

    case "reportErrorParent":
      String parentActionRErr = call.argument("pActionRErr");
      String parentActionRErrValue = call.argument("pActionRErrValue");
      parentActionsMap.get(parentActionRErr).reportEvent(parentActionRErrValue);
      break;

    case "reportStringSub":
      String subActionRS = call.argument("sActionRS");
      String subActionRSKey = call.argument("sActionRSKey");
      String subActionRSValue = call.argument("sActionRSValue");
      subActionsMap.get(subActionRS).reportValue(subActionRSKey, subActionRSValue);
      break;

    case "reportIntSub":
      String subActionRI = call.argument("sActionRI");
      String subActionRIKey = call.argument("sActionRIKey");
      int subActionRIValue = call.argument("sActionRIValue");
      subActionsMap.get(subActionRI).reportValue(subActionRIKey, subActionRIValue);
      break;

    case "reportDoubleSub":
      String subActionRD = call.argument("sActionRD");
      String subActionRDKey = call.argument("sActionRDKey");
      double subActionRDValue = call.argument("sActionRDValue");
      subActionsMap.get(subActionRD).reportValue(subActionRDKey, subActionRDValue);
      break;

    case "reportEventSub":
      String subActionRE = call.argument("sActionRE");
      String subActionREventValue = call.argument("sActionREValue");
      subActionsMap.get(subActionRE).reportEvent(subActionREventValue);
      break;

    case "reportErrorSub":
      String subActionRErr = call.argument("sActionRErr");
      String subActionRErrValue = call.argument("sActionRErrValue");
      subActionsMap.get(subActionRErr).reportEvent(subActionRErrValue);
      break;

    case "endVisit":
      Dynatrace.endVisit();
      result.success("User session ended!");
      break;

    case "shutdown":
      Dynatrace.shutdown();
      result.success("Android agent is shutdown!");
      break;

    case "flushEvents":
      Dynatrace.flushEvents();
      result.success("Flushed data!");
      break;

    case "identifyUser":
      String userTag = call.argument("userTag");
      Dynatrace.identifyUser(userTag);
      result.success("Successfully tagged user: " + userTag);
      break;

    case "setDataCollectionLevel":
      int dataCollectionLvl = call.argument("dataCollectionLevel");
      //String dataCollectionLevelStr = call.argument("dataCollectionLevel");
      Log.d("DataCollectionLevel", String.valueOf(dataCollectionLvl));
      Log.d("OptIn", "Before changing DataCollectionLevel: " + dataCollectionLvl);
      if (dataCollectionLvl == 0) {
        Log.d("OptIn", "Before changing DataCollectionLevel: " + dataCollectionLvl);
        //Log.d("OptIn", "Before changing Crash Reporting: " + String.valueOf(Dynatrace.isCrashReportingOptedIn()));
        Dynatrace.setDataCollectionLevel(DataCollectionLevel.OFF);
        Log.d("DataCollectionLevel", String.valueOf(dataCollectionLvl));
        Log.d("OptIn", Dynatrace.getDataCollectionLevel().toString());
        result.success("setDataCollectionLevel set to " + dataCollectionLvl);
      } else if (dataCollectionLvl == 1) {
        Log.d("OptIn", "Before changing DataCollectionLevel: " + dataCollectionLvl);
        Log.d("DataCollectionLevel", String.valueOf(dataCollectionLvl));
        Dynatrace.setDataCollectionLevel(DataCollectionLevel.PERFORMANCE);
        Log.d("OptIn", Dynatrace.getDataCollectionLevel().toString());
        result.success("setDataCollectionLevel set to " + dataCollectionLvl);
      } else if (dataCollectionLvl == 2) {
        Log.d("OptIn", "Before changing DataCollectionLevel: " + dataCollectionLvl);
        Log.d("DataCollectionLevel", String.valueOf(dataCollectionLvl));
        Log.d("OptIn", Dynatrace.getDataCollectionLevel().toString());
        Dynatrace.setDataCollectionLevel(DataCollectionLevel.USER_BEHAVIOR);
        result.success("setDataCollectionLevel set to " + dataCollectionLvl);
      }
      Log.d("OptIn", "After changing DataCollectionLevel: " + dataCollectionLvl);
      break;

     case "setCrashReportingOptedIn":
       boolean setCrashReportingCaptureStatus = call.argument("setCrashReportingOptedIn");
       Log.d("OptIn", "Before changing Crash Reporting: " + String.valueOf(Dynatrace.isCrashReportingOptedIn()));
       Dynatrace.setCrashReportingOptedIn(setCrashReportingCaptureStatus);
       Log.d("OptIn", String.valueOf(Dynatrace.isCrashReportingOptedIn()));
       result.success("Crash reporting capture status = " + setCrashReportingCaptureStatus);
       break;

     case "getDataCollectionLevel":
       String getDataCollectionLevelStr;
       getDataCollectionLevelStr = Dynatrace.getDataCollectionLevel().toString();
       Log.d("DataCollectionLevel", getDataCollectionLevelStr);
       result.success(getDataCollectionLevelStr);
       break;

     case "getCaptureStatus":
       boolean captureStatus = Dynatrace.getCaptureStatus();
       if (captureStatus == true) {
         Log.d("Dyna", "Capture status = " + captureStatus);
         result.success(captureStatus);
       } else if (captureStatus == false) {
         Log.d("Dyna", "Capture status = " + captureStatus);
         result.success(captureStatus);
       }
       break;

     case "isCrashReportingOptedIn":
       boolean crashReportStatus = Dynatrace.isCrashReportingOptedIn();
       if (crashReportStatus == true) {
         Log.d("Dyna", "Crash report capture status = " + crashReportStatus);
         result.success(crashReportStatus);
       } else {
         Log.d("Dyna", "Crash report capture status = " + crashReportStatus);
         result.success(crashReportStatus);
       }
       break;

    case "startAndroidAgent":
      startupAgentParams = call.argument("startupAgentParams");
      boolean withDebugLogging = Boolean.valueOf(startupAgentParams.get(2));
      boolean certValidation = Boolean.valueOf(startupAgentParams.get(3));
      boolean crashReporting = Boolean.valueOf(startupAgentParams.get(4));
      boolean optIn = Boolean.valueOf(startupAgentParams.get(5));
      startAndroidAgent(startupAgentParams.get(0), startupAgentParams.get(1), withDebugLogging, certValidation, crashReporting, optIn);
      break;


    // case "batteryLevel":
    //   int batteryLevel = getBatteryLevel();
    //   result.success("Device battery level: " + batteryLevel.toString());
    //   break;
    // case "connectionType":
    //   String connType = getNetworkStatusAndType();
    //   result.success("Device connection type: " + connType);
    //   break;

    default:
      result.notImplemented();
      break;
    }
  }

  public void startAndroidAgent(String appId, String beaconUrl, boolean debugLogging, boolean certValidation, boolean crashReporting, boolean optIn) {
    Dynatrace.startup(activity, new DynatraceConfigurationBuilder(appId, beaconUrl)
            .withDebugLogging(debugLogging)
            .withCertificateValidation(certValidation)
            .withCrashReporting(crashReporting)
            .withUserOptIn(optIn)
            .buildConfiguration());
  }

  public void reportValue(DTXAction action, String key, String value) {
    action.reportValue(key, value);
  }

  public void reportValue(DTXAction action, String key, int value) {
    action.reportValue(key, value);
  }

  public void reportValue(DTXAction action, String key, double value) {
    action.reportValue(key, value);
  }

  public void reportEvent(DTXAction action, String eventName) {
    action.reportEvent(eventName);
  }

  public void reportError(DTXAction action, String errorName, int errorCode) {
    action.reportError(errorName, errorCode);
  }

  public void reportError(DTXAction action, String errorName, Throwable throwable) {
    action.reportError(errorName, throwable);
  }

  public void reportError(String errorName, int errorCode) {
    Dynatrace.reportError(errorName, errorCode);
  }

  public void reportError(String errorName, Throwable throwable) {
    Dynatrace.reportError(errorName, throwable);
  }

  public void endVisit() {
    Dynatrace.endVisit();
  }

  public void flushEvents() {
    Dynatrace.flushEvents();
  }

  public void identifyUser(String userTag) {
    Dynatrace.identifyUser(userTag);
  }

  public void tagWebRequest(String url) {
  }

  /**
   Logic in gathering Network/Mobile connection type
   -------------------------------------------------
   */
  public static String getMobileConnType(Context c) {
    TelephonyManager tm = (TelephonyManager)
            c.getSystemService(Context.TELEPHONY_SERVICE);
    int networkType = tm.getNetworkType();
    switch (networkType) {
    // 2G network types:
    case TelephonyManager.NETWORK_TYPE_GPRS:
    case TelephonyManager.NETWORK_TYPE_EDGE:
    case TelephonyManager.NETWORK_TYPE_CDMA:
    case TelephonyManager.NETWORK_TYPE_1xRTT:
    case TelephonyManager.NETWORK_TYPE_IDEN:
      Log.d("ConnectionType", "Connection type found: 2G");
      return "2G";

    // 3G network types:
    case TelephonyManager.NETWORK_TYPE_UMTS:
    case TelephonyManager.NETWORK_TYPE_EVDO_0:
    case TelephonyManager.NETWORK_TYPE_EVDO_A:
    case TelephonyManager.NETWORK_TYPE_HSDPA:
    case TelephonyManager.NETWORK_TYPE_HSUPA:
    case TelephonyManager.NETWORK_TYPE_HSPA:
    case TelephonyManager.NETWORK_TYPE_EVDO_B:
    case TelephonyManager.NETWORK_TYPE_EHRPD:
    case TelephonyManager.NETWORK_TYPE_HSPAP:
      Log.d("ConnectionType", "Connection type found: 3G");
      return "3G";

    // 4G
    case TelephonyManager.NETWORK_TYPE_LTE:
    case TelephonyManager.NETWORK_TYPE_IWLAN:
      Log.d("ConnectionType", "Connection type found: LTE/4G");
      return "LTE/4G";

    //		case TelephonyManager.NETWORK_TYPE_NR:
    //			Log.d(TAG_METRICS, "Connection type found: 5G");
    //			return "5G";

    default:
      return "Unknown!";
    }
  }

  // To check if the device has a network connection and the type of network connection (WIFI or Mobile)
  public String getNetworkStatusAndType(Context c) {
    String connType = "Unknown";

    ConnectivityManager cm = (ConnectivityManager) c.getSystemService(Context.CONNECTIVITY_SERVICE);
    NetworkInfo nI = cm.getActiveNetworkInfo();
    if (nI != null && nI.isConnected()) {
      if (nI.getType() == ConnectivityManager.TYPE_WIFI) {
        connType = "Connection type: Wifi";
        connectionType = Dynatrace.enterAction(connType);
        Log.d("ConnectionType", "Connection type found: " + connType);
        connectionType.leaveAction();
      } else if (nI.getType() == ConnectivityManager.TYPE_MOBILE) {
        connType = getMobileConnType(c);
        connectionType = Dynatrace.enterAction("Connection type: " + connType);
        Log.d("ConnectionType", "Connection type found: " + connType);
        connectionType.leaveAction();
      }
    } else {
      connectionType = Dynatrace.enterAction("Device is not connected or connection type is " + connType);
      Log.d("ConnectionType", "Device is not connected or connection type is " + connType);
      connectionType.leaveAction();
      return connType;
    }
    return "Device is not connected or connection type is unknown!";
  }

  /**
   Battery level logic:
   --------------------
   */
  public int getBatteryLevel(Context c) {

    int batteryPercentage = -1;
    BatteryManager bm = (BatteryManager) c.getSystemService(Context.BATTERY_SERVICE);
    if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.LOLLIPOP) {
      batteryPercentage = bm.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY);
      batteryLevel = Dynatrace.enterAction("Battery percentage " + batteryPercentage + "%");
      Log.i("BatteryLevel", "Battery percentage is: " + batteryPercentage + "%");
      batteryLevel.leaveAction();
    }
    return batteryPercentage;
  }


}
