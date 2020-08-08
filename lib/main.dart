import 'package:flutter/material.dart';
import 'package:sidebar_animation/loginPage.dart';
import 'package:sidebar_animation/pages/gameEntryPage.dart';
import 'package:sidebar_animation/registerPage.dart';

import 'sidebar/sidebar_layout.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: <String, WidgetBuilder>{
        '/LoginPage': (BuildContext context) => new LoginPage(),
        '/SideBarLayout': (BuildContext context) => new SideBarLayout(),
        '/RegisterPage': (BuildContext context) => new RegisterPage(),
        '/GameEntryPage': (BuildContext context) => new GameEntryPage(),
      },
      theme: ThemeData(
          scaffoldBackgroundColor: Colors.white, primaryColor: Colors.white),
      home: LoginPage(),
    );
  }
}

///////////////PROGRESS DIALOG SETTING/////////////////////////////////
// pr = ProgressDialog(
//   context,
//   type: ProgressDialogType.Normal,
//   isDismissible: false,
//   showLogs: false,
//   customBody: Column(
//     mainAxisSize: MainAxisSize.max,
//     children: <Widget>[
//       Center(
//         heightFactor: 15,
//         child: CircularProgressIndicator(
//           backgroundColor: Colors.yellow,
//           valueColor: AlwaysStoppedAnimation((Colors.redAccent)),
//         ),
//       ),
//     ],
//   ),
// );
// pr.style(
//   message: 'Please waitt...',
//   messageTextStyle: TextStyle(
//       color: Colors.white, fontSize: 15.0, fontWeight: FontWeight.w600),
//   borderRadius: 60.0,
//   backgroundColor: Colors.transparent,
//   progressWidget: CircularProgressIndicator(
//       backgroundColor: Colors.yellow,
//       valueColor: AlwaysStoppedAnimation((Colors.redAccent))),
//   elevation: 0.0,
//   insetAnimCurve: Curves.easeInOut,
//   progress: 0.0,
//   maxProgress: 100.0,
//   progressTextStyle: TextStyle(
//       color: Colors.white, fontSize: 13.0, fontWeight: FontWeight.w400),
// );
///////////////////////////////////////////////////////////////////////
