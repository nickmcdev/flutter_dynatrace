import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:flutter_dynatrace/flutter_dynatrace.dart';
import 'dart:io' show Platform;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  static const String _title = 'Flutter Dynatrace Example';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: Scaffold(
        appBar: AppBar(
          title: const Text(_title),
          centerTitle: true,
          brightness: Brightness.dark,
        ),
        body: MyStatefulWidget(),
      ),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  MyStatefulWidget({Key key}) : super(key: key);

  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {


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
  String dropdownValue = 'Start Agent';
  List<String> options = ['Start Agent', 'Single Action', 'Sub Action', 'Action with reportString', 'Action with reportInt', 'Action with reportDouble', 'Action with reportEvent', 'Web Action', 'reportString', 'reportInt', 'reportDouble', 'reportEvent', 'Flush data', 'Tag user', 'End Session', 'Shutdown Agent', 'Collection level: OFF', 'Collection level: PERFORMANCE', 'Collection level: USER_BEHAVIOR', 'setCrashReportingOptedIn: true', 'setCrashReportingOptedIn: false', 'getDataCollectionLevel', 'getCaptureStatus', 'isCrashReportingOptedIn'];
  List<String> actions = ['singleAction', 'subAction', 'reportString', 'reportInt', 'reportDouble', 'reportEvent', 'webAction'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Nothing triggered yet!'),
              DropdownButton<String>(
                value: dropdownValue,
                icon: Icon(Icons.arrow_downward),
                iconSize: 24,
                elevation: 16,
                style: TextStyle(color: Colors.deepPurple),
                underline: Container(
                  height: 2,
                  color: Colors.deepPurpleAccent,
                ),
                onChanged: (String newValue) {
                  setState(() {
                    dropdownValue = newValue;
                  });
                },
                items: options
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              FloatingActionButton(
                  tooltip: 'Test the API!',
                  child: Icon(Icons.check),
                  onPressed: () {
                    example();
                    // setState(() {
                    //   Dynatrace.enterAction("setStateText", "setState - Text Widget");
                    //   Text('Triggered $dropdownValue');
                    //   Dynatrace.leaveAction("setStateText");
                    // });
                  }
              ),
            ],
          ),
        )
    );
  }
  example() {
    switch(dropdownValue) {
      case 'Start Agent': {
        if (Platform.isIOS == true) {
          Dynatrace.startupWithInfoPlistSettings();
        } else if (Platform.isAndroid == true) {
          String appId = "daf8fa7f-899a-41bd-8d5f-7a414010dea6";
          String beaconUrl = "https://bf96722syz.bf.dynatrace.com/mbeacon";
          Dynatrace.startup(appId, beaconUrl, true, false, false, false);
        }
      }
      break;
      case 'Single Action': {
        var now = new DateTime.now();
        Dynatrace.enterAction(parentAction: "testAction", parentActionName: "Test Action1!");
        Dynatrace.enterAction(subAction: "testSubAction", subActionName: "Test Sub Action1!", parentAction: "testAction");
        Dynatrace.enterAction(subAction: "testSubAction2", subActionName: "Test Sub Action2!", parentAction: "testAction");
        
        Dynatrace.enterAction(subAction: "testSubAction3", subActionName: "Test Sub Action3!", parentAction: "testAction");
        Dynatrace.leaveAction(subAction: "testSubAction3");
        Dynatrace.leaveAction(subAction: "testSubAction2");
        
        Dynatrace.reportValue(parentAction: "testAction", key: "reportString", stringValue: "It works!");
        Dynatrace.reportValue(parentAction: "testAction", key: "reportInt", intValue: 1337);
        Dynatrace.reportValue(parentAction: "testAction", key: "reportDouble", doubleValue: 13.37);
        Dynatrace.reportEvent(parentAction: "testAction", event: "Here is the event!");
        Dynatrace.reportError(parentAction: "testAction", error: "Index out of range.");
      //  Dynatrace.enterAction(parentAction: "testAction", subAction: "testSubAction", subActionName: "Test SubAction1!");
      // //  Dynatrace.leaveTest(subAction: "testSubAction");
        Dynatrace.reportValue(subAction: "testSubAction", key: "reportString", stringValue: "It works!");
        Dynatrace.reportValue(subAction: "testSubAction", key: "reportInt", intValue: 1337);
        Dynatrace.reportValue(subAction: "testSubAction", key: "reportDouble", doubleValue: 13.37);
        Dynatrace.reportEvent(subAction: "testSubAction", event: "Here is the event!");
        Dynatrace.reportError(subAction: "testSubAction", error: "Index out of range.");
      //  Dynatrace.enterAction(parentAction: "testAction", subAction: "testSubAction2", subActionName: "Test SubAction2!");
      // //  Dynatrace.leaveTest(subAction: "testSubAction2");
      //  Dynatrace.reportValue(subAction: "testSubAction2", key: "reportString", stringValue: "It works!");
      //  Dynatrace.reportValue(subAction: "testSubAction2", key: "reportInt", intValue: 1337);
      //  Dynatrace.reportValue(subAction: "testSubAction2", key: "reportDouble", doubleValue: 13.37);
      //  Dynatrace.reportEvent(subAction: "testSubAction2", event: "Here is the event!");
      //   Dynatrace.reportError(subAction: "testSubAction2", error: "Index out of range.");
      //  Dynatrace.enterAction(parentAction: "testAction", subAction: "testSubAction3", subActionName: "Test SubAction3!");
      // //  Dynatrace.leaveTest(subAction: "testSubAction3");
      //  Dynatrace.reportValue(subAction: "testSubAction3", key: "reportString", stringValue: "It works!");
      //  Dynatrace.reportValue(subAction: "testSubAction3", key: "reportInt", intValue: 1337);
      //  Dynatrace.reportValue(subAction: "testSubAction3", key: "reportDouble", doubleValue: 13.37);
      //  Dynatrace.reportEvent(subAction: "testSubAction3", event: "Here is the event!");
      //   Dynatrace.reportError(subAction: "testSubAction3", error: "Index out of range.");
      //  Dynatrace.enterAction(parentAction: "testAction", subAction: "testSubAction4", subActionName: "Test SubAction4!");
      // //  Dynatrace.leaveTest(subAction: "testSubAction4");
      //  Dynatrace.reportValue(subAction: "testSubAction4", key: "reportString", stringValue: "It works!");
      //  Dynatrace.reportValue(subAction: "testSubAction4", key: "reportInt", intValue: 1337);
      //  Dynatrace.reportValue(subAction: "testSubAction4", key: "reportDouble", doubleValue: 13.37);
      //  Dynatrace.reportEvent(subAction: "testSubAction4", event: "Here is the event!");
      //   Dynatrace.reportError(subAction: "testSubAction4", error: "Index out of range.");
      //  Dynatrace.enterAction(parentAction: "testAction", subAction: "testSubAction5", subActionName: "Test SubAction5!");
      //   // Dynatrace.leaveTest(subAction: "testSubAction5");
      //   Dynatrace.reportValue(subAction: "testSubAction5", key: "reportString", stringValue: "It works!");
      //   Dynatrace.reportValue(subAction: "testSubAction5", key: "reportInt", intValue: 1337);
      //   Dynatrace.reportValue(subAction: "testSubAction5", key: "reportDouble", doubleValue: 13.37);
      //   Dynatrace.reportEvent(subAction: "testSubAction5", event: "Here is the event!");
      //   Dynatrace.reportError(subAction: "testSubAction5", error: "Index out of range.");
      //   Dynatrace.leaveAction(subAction: "testSubAction");
      //  Dynatrace.leaveAction(subAction: "testSubAction2");
      //  Dynatrace.leaveAction(subAction: "testSubAction3");
      //  Dynatrace.leaveAction(subAction: "testSubAction4");
      //  Dynatrace.leaveAction(subAction: "testSubAction5");
      //   Dynatrace.leaveAction(parentAction: "testAction");
      //   Dynatrace.enterAction(parentAction: "testAction2", parentActionName: "Test Action2!");
      //   Dynatrace.leaveAction(parentAction: "testAction2");
      //   Dynatrace.enterAction(parentAction: "testAction3", parentActionName: "Test Action3!");
      //   Dynatrace.leaveAction(parentAction: "testAction3");
      //   Dynatrace.enterAction(parentAction: "testAction4", parentActionName: "Test Action4!");
      //   Dynatrace.enterAction(parentAction: "testAction5", parentActionName: "Test Action5!");

      //   Dynatrace.leaveAction(parentAction: "testAction4");
      //   Dynatrace.leaveAction(parentAction: "testAction5");
      Dynatrace.leaveAction(subAction: "testSubAction");
      Dynatrace.leaveAction(parentAction: "testAction");

      }
      break;
      case 'Sub Action': {
        var now = new DateTime.now();

      }
      break;

      case 'Web Action': {
        //String url = "https://jsonplaceholder.typicode.com/todos/1";
        String url = "http://nickmcapache1.dtwlab.dynatrace.org:81/json/nick.json";
        Dynatrace.enterAction(parentAction: "webActionButton", parentActionName: "Touch on Web Action Button");
        Dynatrace.webUserAction(parentAction: "webActionButton", url: "http://nickmcapache1.dtwlab.dynatrace.org:81/json/nick.json", requestType: "GET");
        Dynatrace.webUserAction(parentAction: "webActionButton", url: "http://nickmcapache1.dtwlab.dynatrace.org:81/json/nick2.json", requestType: "GET");
        Dynatrace.webUserAction(parentAction: "webActionButton", url: "http://nickmcapache1.dtwlab.dynatrace.org:81/json/nick3.json", requestType: "GET");
        Dynatrace.webUserAction(parentAction: "webActionButton", url: "http://nickmcapache1.dtwlab.dynatrace.org:81/json/nick4.json", requestType: "GET");
        Dynatrace.webUserAction(parentAction: "webActionButton", url: "http://nickmcapache1.dtwlab.dynatrace.org:81/json/nick5.json", requestType: "GET");
        Dynatrace.enterAction(subAction: "webSubActionButton", subActionName: "Sub Action Button", parentAction: "webActionButton");
        Dynatrace.webUserAction(parentAction: "webActionButton", url: "http://nickmcapache1.dtwlab.dynatrace.org:81/json/nick6.json", requestType: "GET");
        Dynatrace.webUserAction(parentAction: "webActionButton", url: "http://nickmcapache1.dtwlab.dynatrace.org:81/json/nick7.json", requestType: "GET");
        Dynatrace.webUserAction(parentAction: "webActionButton", url: "http://nickmcapache1.dtwlab.dynatrace.org:81/json/nick8.json", requestType: "GET");
        Dynatrace.webUserAction(parentAction: "webActionButton", url: "http://nickmcapache1.dtwlab.dynatrace.org:81/json/nick9.json", requestType: "GET");
        Dynatrace.webUserAction(parentAction: "webActionButton", url: "http://nickmcapache1.dtwlab.dynatrace.org:81/json/nick10.json", requestType: "GET");
        Dynatrace.leaveAction(subAction: "webSubActionButton");
        Dynatrace.leaveAction(parentAction: "webActionButton");

        // Dynatrace.webUserAction("http://nickmcapache1.dtwlab.dynatrace.org:81/json/nick.json", "GET");
        // Dynatrace.webUserAction("http://nickmcapache1.dtwlab.dynatrace.org:81/json/nick2.json", "GET");
        // Dynatrace.webUserAction("http://nickmcapache1.dtwlab.dynatrace.org:81/json/nick3.json", "GET");
        // Dynatrace.webUserAction("http://nickmcapache1.dtwlab.dynatrace.org:81/json/nick4.json", "GET");
        // Dynatrace.webUserAction("http://nickmcapache1.dtwlab.dynatrace.org:81/json/nick5.json", "GET");
        // Dynatrace.webUserAction("http://nickmcapache1.dtwlab.dynatrace.org:81/json/nick6.json", "GET");
        // Dynatrace.webUserAction("http://nickmcapache1.dtwlab.dynatrace.org:81/json/nick7.json", "GET");
        // Dynatrace.webUserAction("http://nickmcapache1.dtwlab.dynatrace.org:81/json/nick8.json", "GET");
        // Dynatrace.webUserAction("http://nickmcapache1.dtwlab.dynatrace.org:81/json/nick9.json", "GET");
        // Dynatrace.webUserAction("http://nickmcapache1.dtwlab.dynatrace.org:81/json/nick10.json", "GET");
      }
      break;
      case 'reportString': {
        // Dynatrace.enterAction("reportString", "reportString!");
        // //Dynatrace.reportValueString("reportString", "ReportStringAction", "We did it!");
        // Dynatrace.leaveAction("reportString");
      }
      break;
      case 'reportInt': {
        // Dynatrace.enterAction("reportInt", "reportInt!");
        // //Dynatrace.reportValueInt("reportInt", "ReportIntAction", 10000);
        // Dynatrace.leaveAction("reportInt");
      }
      break;
      case 'reportDouble': {
        // statements;

      }
      break;
      case 'reportEvent': {
        // statements;
      }
      break;
      case 'Flush data': {
        Dynatrace.flushEvents();
      }
      break;
      case 'Tag user': {
        Dynatrace.identifyUser("TestNick!");
      }
      break;
      case 'End Session': {
        Dynatrace.endVisit();
      }
      break;
      case 'Shutdown Agent': {
        Dynatrace.shutdown();
      }
      break;
      case 'Collection level: OFF': {
        Dynatrace.setDataCollectionLevel("OFF");
      }
      break;
      case 'Collection level: PERFORMANCE': {
        Dynatrace.setDataCollectionLevel("PERFORMANCE");
      }
      break;
      case 'Collection level: USER_BEHAVIOR': {
        Dynatrace.setDataCollectionLevel("USER_BEHAVIOR");
      }
      break;
      case 'setCrashReportingOptedIn: true': {
        Dynatrace.setCrashReportingOptedIn(true);
      }
      break;
      case 'setCrashReportingOptedIn: false': {
        Dynatrace.setCrashReportingOptedIn(false);
      }
      break;
      case 'getDataCollectionLevel': {
        dataCollectionLevel();
      }
      break;
      case 'getCaptureStatus': {
        // Android only
        isCaptureStatus();
      }
      break;
      case 'isCrashReportingOptedIn': {
        crashReportCapture();

      }
      break;
      default: {
        //statements;
      }
      break;
    }
    
  }
}
