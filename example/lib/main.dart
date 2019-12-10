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
          Dynatrace.startup(appId, beaconUrl, true, false, false, true);
        }
      }
      break;
      case 'Single Action': {
        var now = new DateTime.now();
        //Dynatrace.enterAction(actions[0], options[1]);
        Dynatrace.enterAction("currentTime0", "Single Action");
//        Dynatrace.enterSubAction("currentTime0", "sub0", "Test Sub Action 0!");
//        Dynatrace.leaveSubAction("currentTime0", "sub0");
//        Dynatrace.enterSubAction("currentTime0", "sub1", "Test Sub Action 1!");
//        Dynatrace.leaveSubAction("currentTime0", "sub1");
        Dynatrace.leaveAction("currentTime0");
        Dynatrace.enterAction("currentTime1", "Test 1 - Current time: $now");
        // Dynatrace.enterSubAction("currentTime1", "sub0", "Test Sub Action 0!");
        // Dynatrace.leaveSubAction("currentTime1", "sub0");
        // Dynatrace.enterSubAction("currentTime1", "sub1", "Test Sub Action 1!");
        // Dynatrace.leaveSubAction("currentTime1", "sub1");
        Dynatrace.leaveAction("currentTime1");
        Dynatrace.enterAction("currentTime2", "Test 2 - Current time: $now");
        // Dynatrace.enterSubAction("currentTime2", "sub0", "Test Sub Action 0!");
        // Dynatrace.leaveSubAction("currentTime2", "sub0");
        // Dynatrace.enterSubAction("currentTime2", "sub1", "Test Sub Action 1!");
        // Dynatrace.leaveSubAction("currentTime2", "sub1");
        Dynatrace.leaveAction("currentTime2");
        Dynatrace.enterAction("currentTime3", "4th!");
        Dynatrace.leaveAction("currentTime3");
      }
      break;
      case 'Sub Action': {
        var now = new DateTime.now();
        Dynatrace.enterAction("currentTime0", "Test 0 - Current time: $now");
        Dynatrace.reportValueString("currentTime0", "reportString0", "Here!");
        Dynatrace.reportValueInt("currentTime0", "reportInt0", 1337);
        Dynatrace.reportValueDouble("currentTime0", "reportDouble0", 13.37);
        Dynatrace.enterSubAction("currentTime0", "sub0", "Test Sub Action 0!");
        Dynatrace.leaveSubAction("currentTime0", "sub0");
        Dynatrace.enterSubAction("currentTime0", "sub1", "Test Sub Action 1!");
        Dynatrace.leaveSubAction("currentTime0", "sub1");
        Dynatrace.enterSubAction("currentTime0", "sub2", "Test Sub Action 2!");
        Dynatrace.leaveSubAction("currentTime0", "sub2");
        Dynatrace.enterSubAction("currentTime0", "sub3", "Test Sub Action 3!");
        Dynatrace.leaveSubAction("currentTime0", "sub3");
        Dynatrace.enterSubAction("currentTime0", "sub4", "Test Sub Action 4!");
        Dynatrace.leaveSubAction("currentTime0", "sub4");
        Dynatrace.reportValueString("currentTime0", "reportString1", "Here!");
        Dynatrace.reportValueInt("currentTime0", "reportInt1", 1337);
        Dynatrace.reportValueDouble("currentTime0", "reportDouble1", 13.37);
        Dynatrace.leaveAction("currentTime0");

        // Dynatrace.enterAction("currentTime1", "Test 1 - Current time: $now");
        // Dynatrace.reportValueString("currentTime1", "reportString0", "Here!");
        // Dynatrace.reportValueInt("currentTime1", "reportInt1", 1337);
        // Dynatrace.reportValueDouble("currentTime1", "reportDouble1", 13.37);
        // Dynatrace.enterSubAction("currentTime1", "sub0", "Test Sub Action 0!");
        // Dynatrace.leaveSubAction("sub0");
        // Dynatrace.enterSubAction("currentTime1", "sub1", "Test Sub Action 1!");
        // Dynatrace.leaveSubAction("sub1");
        // Dynatrace.reportValueString("currentTime1", "reportString1", "Here!");
        // Dynatrace.reportValueInt("currentTime1", "reportInt1", 1337);
        // Dynatrace.reportValueDouble("currentTime1", "reportDouble1", 13.37);
        // Dynatrace.leaveAction("currentTime1");
        // Dynatrace.enterAction("currentTime2", "Test 2 - Current time: $now");
        // Dynatrace.reportValueString("currentTime2", "reportString0", "Here!");
        // Dynatrace.reportValueInt("currentTime2", "reportInt2", 1337);
        // Dynatrace.reportValueDouble("currentTime2", "reportDouble2", 13.37);
        // Dynatrace.enterSubAction("currentTime2", "sub0", "Test Sub Action 0!");
        // Dynatrace.leaveSubAction("sub0");
        // Dynatrace.enterSubAction("currentTime2", "sub1", "Test Sub Action 1!");
        // Dynatrace.leaveSubAction("sub1");
        // Dynatrace.reportValueString("currentTime2", "reportString1", "Here!");
        // Dynatrace.reportValueInt("currentTime2", "reportInt2", 1337);
        // Dynatrace.reportValueDouble("currentTime2", "reportDouble2", 13.37);
        // Dynatrace.leaveAction("currentTime2");


        //   var now = new DateTime.now();
        //   var nowSub = new DateTime.now();
        //   Dynatrace.enterAction("currentTime", "Current time: $now");
        //   Dynatrace.enterSubAction("currentTime", parentActionName, subAction, subActionName)
        //   Dynatrace.leaveAction("currentTime");
      }
      break;
    // case 'Action with reportString': {
    //   Dynatrace.enterAction("reportStringTime", "Current time - report : $now");
    //   Dynatrace.leaveAction("reportStringTime");
    // }
    // break;
    // case 'Action with reportInt': {
    //   Dynatrace.enterAction("reportStringTime", "Current time - report : $now");
    //   Dynatrace.leaveAction("reportStringTime");
    // }
    // break;
    // case 'Action with reportDouble': {
    //   Dynatrace.enterAction("reportStringTime", "Current time - report : $now");
    //   Dynatrace.leaveAction("reportStringTime");
    // }
    // break;
    // case 'Action with reportEvent': {
    //   Dynatrace.enterAction("reportStringTime", "Current time - report : $now");
    //   Dynatrace.leaveAction("reportStringTime");
    // }
    // break;
      case 'Web Action': {
        String url = "https://jsonplaceholder.typicode.com/todos/1";
        Dynatrace.webUserAction(url, "GET");
      }
      break;
      case 'reportString': {
        Dynatrace.enterAction("reportString", "reportString!");
        //Dynatrace.reportValueString("reportString", "ReportStringAction", "We did it!");
        Dynatrace.leaveAction("reportString");
      }
      break;
      case 'reportInt': {
        Dynatrace.enterAction("reportInt", "reportInt!");
        //Dynatrace.reportValueInt("reportInt", "ReportIntAction", 10000);
        Dynatrace.leaveAction("reportInt");
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
        Dynatrace.getDataCollectionLevel();
      }
      break;
      case 'getCaptureStatus': {
        // Android only
        Dynatrace.getCaptureStatus();
      }
      break;
      case 'isCrashReportingOptedIn': {
        String crashReport = Dynatrace.isCrashReportingOptedIn().toString();
        print(crashReport);

      }
      break;
      default: {
        //statements;
      }
      break;
    }
  }
}
