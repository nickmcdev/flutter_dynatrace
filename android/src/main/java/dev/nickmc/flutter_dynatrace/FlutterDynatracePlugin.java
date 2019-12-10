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

import java.io.IOException;
import java.net.MalformedURLException;
import java.util.ArrayList;
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

  // User Action
  int parentActionCount = 0;
  int subActionCount = 0;
  //String actionLeaveValue = "";

  Map<Integer, DTXAction> parentActions;
  DTXAction parentAction0, parentAction1, parentAction2;
  String parentActionName0, parentActionName1, parentActionName2;
  DTXAction subAction;
  DTXAction batteryLevel;
  DTXAction connectionType;
  ArrayList<DTXAction> parentActionsList = new ArrayList<DTXAction>();
  ArrayList<DTXAction> subActionsList = new ArrayList<DTXAction>();
  ArrayList<DTXAction> subActions0 = new ArrayList<DTXAction>();
  ArrayList<DTXAction> subActions1 = new ArrayList<DTXAction>();
  ArrayList<DTXAction> subActions2 = new ArrayList<DTXAction>();
  ArrayList<String> parentActionValues = new ArrayList<String>();
  ArrayList<String> subActionValues = new ArrayList<String>();


  // reportValue
  ArrayList<String> reportStringValues = new ArrayList<String>();
  ArrayList<String> reportIntValues = new ArrayList<String>();
  ArrayList<String> reportDoubleValues = new ArrayList<String>();
  ArrayList<String> reportEventValues = new ArrayList<String>();
  ArrayList<String> reportErrorValues = new ArrayList<String>();
  ArrayList<String> reportErrorThrowableValues = new ArrayList<String>();

  // startupAgent
  ArrayList<String> startupAgentParams = new ArrayList<String>();

  // reportEvent
  String eventValue;

  // reportError
  String errorName;
  int errorValue = -1;
  Throwable errorThrowable;

  // Web Request
  DTXAction webUserAction;
  String requestTag;
  String requestTagHeaderName;
  WebRequestTiming timing;
  String tagIdValue = "";
  String url;
  int statusCodeSuccess = 200;
  int wrStatusCode;


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


  // TODO: Find a better system to handle and store actions - Tried a map/dictionary and array/list but for some reason UA reponse time was between 6 seconds and 20 seconds for a simple enter/leaveAction :(
  @Override
  public void onMethodCall(MethodCall call, Result result) {
    switch (call.method) {
    case "enterAction0":
      //String parentAction = call.argument("enterActionValues");
      parentActionName0 = call.argument("enterActionValues0");
      parentAction0 = Dynatrace.enterAction(parentActionName0);
      //parentActionsList.add(Dynatrace.enterAction(parentAction));
      //result.success(parentActionsList.size() - 1);
      //Log.d("enterAction", "Parent Action ID: " + (parentActionsList.size() - 1));
      parentActionCount++;
      break;

    case "enterAction1":
      parentActionName1 = call.argument("enterActionValues1");
      parentAction1 = Dynatrace.enterAction(parentActionName1);
      Log.d("enterAction", "Action created!");
      break;

    case "enterAction2":
      parentActionName2 = call.argument("enterActionValues2");
      parentAction2 = Dynatrace.enterAction(parentActionName2);
      Log.d("enterAction", "Action created!");
      break;

    case "enterSubAction0":
      String subActionName0 = call.argument("enterSubActionValues0");
      subActions0.add(Dynatrace.enterAction(subActionName0, parentAction0));
      Log.d("enterSubAction", "Action created! - List: " + subActions0.size() + " " + subActions0.toString());
      break;

    case "enterSubAction1":
      String subActionName1 = call.argument("enterSubActionValues1");
      subActions1.add(Dynatrace.enterAction(subActionName1, parentAction1));
      Log.d("enterSubAction", "Action created! - List: " + subActions0.size() + " " + subActions0.toString());
      break;

    case "enterSubAction2":
      String subActionName2 = call.argument("enterSubActionValues2");
      subActions2.add(Dynatrace.enterAction(subActionName2, parentAction2));
      Log.d("enterSubAction", "Action created! - List: " + subActions0.size() + " " + subActions0.toString());
      break;

    case "leaveAction0":
      Log.d("leaveAction", "Action left!");
      parentAction0.leaveAction();
      subActions0.clear();
      break;

    case "leaveAction1":
      Log.d("leaveAction", "Action left!");
      parentAction1.leaveAction();
      subActions1.clear();
      break;

    case "leaveAction2":
      Log.d("leaveAction", "Action left!");
      parentAction2.leaveAction();
      subActions2.clear();
      break;

    case "leaveSubAction0":
      Log.d("leaveSubAction", "Action left! - List: " + subActions0.size() + " " + subActions0.toString());
      int idSubAction0 = call.argument("leaveSubActionValues0");
      subActions0.get(idSubAction0).leaveAction();
      break;

    case "leaveSubAction1":
      Log.d("leaveSubAction", "Action left! - List: " + subActions0.size() + " " + subActions0.toString());
      int idSubAction1 = call.argument("leaveSubActionValues1");
      subActions1.get(idSubAction1).leaveAction();
      break;

    case "leaveSubAction2":
      Log.d("leaveSubAction", "Action left! - List: " + subActions0.size() + " " + subActions0.toString());
      int idSubAction2 = call.argument("leaveSubActionValues2");
      subActions2.get(idSubAction2).leaveAction();
      break;

    case "webUserActionEnter":
      url = call.argument("webUserActionUrl");
      webUserAction = Dynatrace.enterAction("WebRequest - " + url);
      requestTag = webUserAction.getRequestTag();
      timing = Dynatrace.getWebRequestTiming(requestTag);
      requestTagHeaderName = Dynatrace.getRequestTagHeader();
      timing.startWebRequestTiming();
      if (url != null) {
        result.success(requestTag);
      } else {
        result.error("UNAVAILABLE", "Not able to capture User Action.", null);
      }
      break;

    case "webUserActionResponse":
      wrStatusCode = call.argument("webUserActionResponseCode");
      Log.d("WebRequestInfo", "Web Request Status Code: " + wrStatusCode);
      if (wrStatusCode != 200) {
        try {
          timing.stopWebRequestTiming(url, wrStatusCode, "Failed request");
          webUserAction.leaveAction();
          Log.d("WebRequestInfo", "Web Request Failed!");
        } catch (MalformedURLException e) {
          webUserAction.reportError("Web Request Error", e);
          webUserAction.leaveAction();
          e.printStackTrace();
        }
      } else {
        try {
          timing.stopWebRequestTiming(url, wrStatusCode, "OK");
          webUserAction.leaveAction();
          Log.d("WebRequestInfo", "Web Request Successful!");
        } catch (MalformedURLException e) {
          webUserAction.reportError("Web Request Error", e);
          webUserAction.leaveAction();
          e.printStackTrace();
        }
      }
      break;

    case "reportString0":
      reportStringValues = call.argument("reportStringValues0");
      parentAction0.reportValue(reportStringValues.get(0), reportStringValues.get(1));
      reportStringValues.clear();
      break;

    case "reportString1":
      reportStringValues = call.argument("reportStringValues1");
      parentAction1.reportValue(reportStringValues.get(0), reportStringValues.get(1));
      reportStringValues.clear();
      break;

    case "reportString2":
      reportStringValues = call.argument("reportStringValues2");
      parentAction2.reportValue(reportStringValues.get(0), reportStringValues.get(1));
      reportStringValues.clear();
      break;

    case "reportInt0":
      reportIntValues = call.argument("reportIntValues0");
      parentAction0.reportValue(reportIntValues.get(0), Integer.parseInt(reportIntValues.get(1)));
      reportIntValues.clear();
      break;

    case "reportInt1":
      reportIntValues = call.argument("reportIntValues1");
      parentAction1.reportValue(reportIntValues.get(0), Integer.parseInt(reportIntValues.get(1)));
      reportIntValues.clear();
      break;

    case "reportInt2":
      reportIntValues = call.argument("reportIntValues2");
      parentAction2.reportValue(reportIntValues.get(0), Integer.parseInt(reportIntValues.get(1)));
      reportIntValues.clear();
      break;

    case "reportDouble0":
      reportDoubleValues = call.argument("reportDoubleValues0");
      parentAction0.reportValue(reportDoubleValues.get(0), Double.parseDouble(reportDoubleValues.get(1)));
      reportDoubleValues.clear();
      break;

    case "reportDouble1":
      reportDoubleValues = call.argument("reportDoubleValues1");
      parentAction1.reportValue(reportDoubleValues.get(0), Double.parseDouble(reportDoubleValues.get(1)));
      reportDoubleValues.clear();
      break;

    case "reportDouble2":
      reportDoubleValues = call.argument("reportDoubleValues2");
      parentAction2.reportValue(reportDoubleValues.get(0), Double.parseDouble(reportDoubleValues.get(1)));
      reportDoubleValues.clear();
      break;

    // case "reportEvent0":
    //   reportEventValue = call.argument("reportEventValue0");
    //   parentAction0.reportEvent(reportEventValue);
    //   break;

    // case "reportEvent1":
    //   reportEventValue = call.argument("reportEventValue1");
    //   parentAction1.reportEvent(reportEventValue);
    //   break;

    // case "reportEvent2":
    //   reportEventValue = call.argument("reportEventValue2");
    //   parentAction2.reportEvent(reportEventValue);
    //   break;

    // case "reportErrorCode0":
    //   reportErrorValues = call.argument("reportErrorValues0");
    //   parentAction0.reportError(reportErrorValues.get(0), Integer.parseInt(reportErrorValues.get(1)));
    //   reportErrorValues.clear();
    //   break;

    // case "reportErrorCode1":
    //   reportErrorValues = call.argument("reportErrorValues1");
    //   parentAction1.reportError(reportErrorValues.get(0), Integer.parseInt(reportErrorValues.get(1)));
    //   reportErrorValues.clear();
    //   break;

    // case "reportErrorCode2":
    //   reportErrorValues = call.argument("reportErrorValues2");
    //   parentAction2.reportError(reportErrorValues.get(0), Integer.parseInt(reportErrorValues.get(1)));
    //   reportErrorValues.clear();
    //   break;

    // case "reportErrorThrowable0":
    //   reportErrorThrowableValues = call.argument("reportErrorThrowableValues0");
    //   parentAction0.reportError(reportErrorValues.get(0), reportErrorThrowableValues.get(1));
    //   reportErrorThrowableValues.clear();
    //   break;

    // case "reportErrorThrowable1":
    //   reportErrorThrowableValues = call.argument("reportErrorThrowableValues1");
    //   parentAction1.reportError(reportErrorValues.get(0), reportErrorThrowableValues.get(1));
    //   reportErrorThrowableValues.clear();
    //   break;

    // case "reportErrorThrowable2":
    //   reportErrorThrowableValues = call.argument("reportErrorThrowableValues2");
    //   parentAction2.reportError(reportErrorValues.get(0), reportErrorThrowableValues.get(1));
    //   reportErrorThrowableValues.clear();
    //   break;

    // case "reportErrorCode":
    //   reportErrorValues = call.argument("reportErrorValues");
    //   Dynatrace.reportError(reportErrorValues.get(0), Integer.parseInt(reportErrorValues.get(1)));
    //   reportErrorValues.clear();
    //   break;

    // case "reportErrorThrowable":
    //   reportErrorThrowableValues = call.argument("reportErrorThrowableValues");
    //   Dynatrace.reportError(reportErrorValues.get(0), reportErrorThrowableValues.get(1));
    //   reportErrorThrowableValues.clear();
    //   break;

    // case "reportErrorCode":
    //   //errorName = call.argument("reportErrorName");
    //   errorName = "TestError";
    //   errorValue = call.argument("reportErrorValue");
    //   parentAction0.reportError(errorName, errorValue);
    //   break;

    // case "reportErrorThrowable":
    //   //errorName = call.argument("reportErrorNameThrowable");
    //   errorName = "TestError";
    //   errorThrowable = call.argument("reportErrorThrowable");
    //   parentAction0.reportError(errorName, errorThrowable);
    //   break;

    // case "reportErrorCodeNoAction":
    //   //errorName = call.argument("reportErrorNameNoAction");
    //   errorName = "TestError";
    //   errorValue = call.argument("reportErrorValueNoAction");
    //   break;

    // case "reportErrorThrowableNoAction":
    //   //errorName = call.argument("reportErrorNameThrowableNoAction");
    //   errorName = "TestError";
    //   errorThrowable = call.argument("reportErrorThrowableNoAction");
    //   break;

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
       String captureStatusStr;
       boolean captureStatus = Dynatrace.getCaptureStatus();
       if (captureStatus == true) {
         captureStatusStr = "true";
         Log.d("Dyna", "Capture status = " + captureStatusStr);
         result.success(captureStatusStr);
       } else {
         captureStatusStr = "false";
         Log.d("Dyna", "Capture status = " + captureStatusStr);
         result.success(captureStatusStr);
       }

       break;

     case "isCrashReportingOptedIn":
       String crashReportStatusStr;
       boolean crashReportStatus = Dynatrace.isCrashReportingOptedIn();
       if (crashReportStatus == true) {
         crashReportStatusStr = "true";
         Log.d("Dyna", "Crash report capture status = " + crashReportStatusStr);
         result.success(crashReportStatusStr);
       } else {
         crashReportStatusStr = "false";
         Log.d("Dyna", "Crash report capture status = " + crashReportStatusStr);
         result.success(crashReportStatusStr);
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

  public void webUserAction(String url) throws MalformedURLException {
    webUserAction = Dynatrace.enterAction("WebRequest - " + url);
    requestTag = webUserAction.getRequestTag();
    timing = Dynatrace.getWebRequestTiming(requestTag);
    requestTagHeaderName = Dynatrace.getRequestTagHeader();

    try {
      timing.startWebRequestTiming();
      //Response response = client.newCall(request).execute();

      // handle response
      //String body = response.body().string();

      // [7] Once done reading, timing can stop
      timing.stopWebRequestTiming(url, 200, "Success!");
    } catch (IOException e) {
      timing.stopWebRequestTiming(url, -1, e.toString());
      reportError("WebRequestError", e);
    }
    finally {
      webUserAction.leaveAction();
    }

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
