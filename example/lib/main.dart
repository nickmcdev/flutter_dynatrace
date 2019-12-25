import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:flutter_dynatrace/flutter_dynatrace.dart';
import 'dart:io' show Platform;
import 'dart:convert';

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

  String textWidgetStr = 'Nothing triggered yet!';
 
  changeText(String newText) {
    setState(() {
     textWidgetStr = newText; 
    });
    
  }


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

  reportValueStringAndWebAction() async {
    Dynatrace.enterAction(parentAction: actions[6], parentActionName: "Touch on Web Action + reportString");
        // This is used for web requests of application/json and will automatically tag and time the request and return of response body if you want to use it.
        // I will add more functionality to this in upcoming releases/updates
        // requestType can be "POST" or "GET" - if others are used, the web request will not occur
        // set response to String of JSON
    String reportValueMessage = await Dynatrace.dynaWebRequest(parentAction: actions[6], url: "https://dog.ceo/api/breeds/image/random", requestType: "GET");
        // decode response
    var jsonResp = json.decode(reportValueMessage);
        // set new String to grab the key title's value
    var message = jsonResp["message"];
        // use the reportValue(string) SDK to put it in the waterfall
    Dynatrace.reportValue(parentAction: actions[6], key: "Message", stringValue: message);
        // leave action
    Dynatrace.leaveAction(parentAction: actions[6]);
    changeText("Touch on " + options[4]);
  }

  String dropdownValue = 'Start Agent';
  static const List<String> options = ['Start Agent', 'Single Action', 'Sub Action', 'Web Action', 'Web Action + reportString', 'Action with reportString', 'Action with reportInt', 'Action with reportDouble', 'Action with reportEvent', 'Action with reportError', 'Action with reportValues', 'Flush data', 'Tag user', 'End Session', 'Shutdown Agent', 'Collection level: OFF', 'Collection level: PERFORMANCE', 'Collection level: USER_BEHAVIOR', 'setCrashReportingOptedIn: true', 'setCrashReportingOptedIn: false', 'getDataCollectionLevel', 'getCaptureStatus', 'isCrashReportingOptedIn'];
  static const List<String> actions = ['singleAction', 'parentSubAction', 'subAction', 'subAction2', 'subAction3', 'webAction', 'webActionString', 'reportString', 'reportInt', 'reportDouble', 'reportError', 'reportEvent', 'reportValues'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('$textWidgetStr'),
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
                    changeText("Touch on $dropdownValue");
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
          changeText("Touch on $options[0]");
        }
      }
      break;
      case 'Single Action': {
        Dynatrace.enterAction(parentAction: actions[0], parentActionName: "Touch on " + options[1]);
        // do something
        Dynatrace.leaveAction(parentAction: actions[0]);
        changeText("Touch on $options[1]");
      }
      break;

      case 'Sub Action': {
        Dynatrace.enterAction(parentAction: actions[1], parentActionName: "Touch on " + options[2]);
        // do something
        Dynatrace.enterAction(subAction: actions[2], subActionName: "First Sub Action", parentAction: actions[1]);
        // do something
        Dynatrace.enterAction(subAction: actions[3], subActionName: "Second Sub Action", parentAction: actions[1]);
        // do something
        Dynatrace.enterAction(subAction: actions[4], subActionName: "Third Sub Action", parentAction: actions[1]);
        // do something
        Dynatrace.leaveAction(subAction: actions[4]);
        Dynatrace.leaveAction(subAction: actions[3]);
        Dynatrace.leaveAction(subAction: actions[2]);
        Dynatrace.leaveAction(parentAction: actions[1]);
        changeText("Touch on $options[2]");
      }
      break;

      case 'Web Action': {
        List<String> urls = ["https://dog.ceo/api/breed/husky/images/random", "https://dog.ceo/api/breed/labrador/images/random", "https://dog.ceo/api/breed/retriever/images/random", "https://dog.ceo/api/breed/sheepdog/images/random", "https://dog.ceo/api/breed/chow/images/random"];
        Dynatrace.enterAction(parentAction: actions[5], parentActionName: "Touch on " + options[3]);
        Dynatrace.enterAction(subAction: "testSub", subActionName: "Test on " + options[3], parentAction: actions[5]);
        // This is used for web requests of application/json and will automatically tag and time the request and return of response body if you want to use it.
        // I will add more functionality to this in upcoming releases/updates
        // requestType can be "POST" or "GET" - if others are used, the web request will not occur
        Dynatrace.dynaWebRequest(parentAction: actions[5], url: urls[0], requestType: "GET");
        Dynatrace.dynaWebRequest(parentAction: actions[5], url: urls[0], requestType: "GET");
        Dynatrace.dynaWebRequest(parentAction: actions[5], url: urls[0], requestType: "GET");
        Dynatrace.dynaWebRequest(parentAction: actions[5], url: urls[0], requestType: "GET");
        Dynatrace.dynaWebRequest(parentAction: actions[5], url: urls[0], requestType: "GET");

        Dynatrace.dynaWebRequest(subAction: "testSub", url: urls[0], requestType: "GET");
        Dynatrace.dynaWebRequest(subAction: "testSub", url: urls[0], requestType: "GET");
        Dynatrace.dynaWebRequest(subAction: "testSub", url: urls[0], requestType: "GET");
        Dynatrace.dynaWebRequest(subAction: "testSub", url: urls[0], requestType: "GET");
        Dynatrace.dynaWebRequest(subAction: "testSub", url: urls[0], requestType: "GET");
        Dynatrace.leaveAction(subAction: "testSub");
        Dynatrace.leaveAction(parentAction: actions[5]);
        changeText("Touch on " + options[3]);

      }
      break;

      case 'Web Action + reportString': {
        reportValueStringAndWebAction();
        }
      break;

      case 'Action with reportString': {
        Dynatrace.enterAction(parentAction: actions[7], parentActionName: "Touch on " + options[5]);
        Dynatrace.reportValue(parentAction: actions[7], key: "Dynatrace", stringValue: "All-in-one, all you need");
        Dynatrace.leaveAction(parentAction: actions[7]);
        changeText("Touch on $options[5]");
      }
      break;

      case 'Action with reportInt': {
        Dynatrace.enterAction(parentAction: actions[8], parentActionName: "Touch on " + options[6]);
        Dynatrace.reportValue(parentAction: actions[8], key: "Jenny", intValue: 8675309);
        Dynatrace.leaveAction(parentAction: actions[8]);
        changeText("Touch on $options[6]");
      }
      break;

      case 'Action with reportDouble': {
        Dynatrace.enterAction(parentAction: actions[9], parentActionName: "Touch on " + options[7]);
        Dynatrace.reportValue(parentAction: actions[9], key: "Mobile", doubleValue: 1.337);
        Dynatrace.leaveAction(parentAction: actions[9]);
        changeText("Touch on $options[7]");
      }
      break;

      case 'Action with reportEvent': {
        Dynatrace.enterAction(parentAction: actions[10], parentActionName: "Touch on " + options[8]);
        Dynatrace.reportEvent(parentAction: actions[10], event: "Data has been received!");
        Dynatrace.leaveAction(parentAction: actions[10]);
        changeText("Touch on $options[8]");
      }
      break;

      case 'Action with reportError': {
        int a = 100; 
        int b = 0; 
        int result;  
        Dynatrace.enterAction(parentAction: actions[11], parentActionName: "Touch on " + options[9]);
        try {  
          result = a ~/ b; 
        } catch(e) { 
          Dynatrace.reportError(parentAction: actions[11], error: e.toString()); 
        } 
        Dynatrace.leaveAction(parentAction: actions[11]);
        changeText("Touch on $options[9]");
      }
      break;

      case 'Action with reportValues': {
        int a = 100; 
        int b = 0; 
        int result;

        Dynatrace.enterAction(parentAction: actions[12], parentActionName: "Touch on + " + options[10]);
        Dynatrace.reportValue(parentAction: actions[12], key: "Dynatrace", stringValue: "All-in-one, all you need");
        Dynatrace.reportValue(parentAction: actions[12], key: "Jenny", intValue: 8675309);
        Dynatrace.reportValue(parentAction: actions[12], key: "Mobile", doubleValue: 1.337);
        Dynatrace.reportEvent(parentAction: actions[12], event: "Data has been received!");
        try {  
          result = a ~/ b; 
        } catch(e) { 
          Dynatrace.reportError(parentAction: actions[12], error: e.toString()); 
        } 
        Dynatrace.leaveAction(parentAction: actions[12]);
        changeText("Touch on $options[10]");
      }
      break;

      case 'Flush data': {
        Dynatrace.flushEvents();
        changeText("Touch on $options[11]");
      }
      break;

      case 'Tag user': {
        Dynatrace.identifyUser("flutter@dynatrace.com");
        changeText("Touch on $options[12]");
      }
      break;

      case 'End Session': {
        Dynatrace.endVisit();
        changeText("Touch on $options[13]");
      }
      break;

      case 'Shutdown Agent': {
        Dynatrace.shutdown();
        changeText("Touch on $options[14]");
      }
      break;

      case 'Collection level: OFF': {
        Dynatrace.setDataCollectionLevel("OFF");
        changeText("Touch on $options[15]");
      }
      break;

      case 'Collection level: PERFORMANCE': {
        Dynatrace.setDataCollectionLevel("PERFORMANCE");
        changeText("Touch on $options[16]");
      }
      break;

      case 'Collection level: USER_BEHAVIOR': {
        Dynatrace.setDataCollectionLevel("USER_BEHAVIOR");
        changeText("Touch on $options[17]");
      }
      break;

      case 'setCrashReportingOptedIn: true': {
        Dynatrace.setCrashReportingOptedIn(true);
        changeText("Touch on $options[18]");
      }
      break;

      case 'setCrashReportingOptedIn: false': {
        Dynatrace.setCrashReportingOptedIn(false);
        changeText("Touch on $options[19]");
      }
      break;

      case 'getDataCollectionLevel': {
        dataCollectionLevel();
        changeText("Touch on $options[20]");
      }
      break;

      case 'getCaptureStatus': {
        // Android only
        isCaptureStatus();
        changeText("Touch on $options[21]");
      }
      break;

      case 'isCrashReportingOptedIn': {
        crashReportCapture();
        changeText("Touch on $options[22]");
      }
      break;

      default: {
        //statements;
      }
      break;
    }
    
  }
}
