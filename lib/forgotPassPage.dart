import 'dart:async';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:toast/toast.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:sidebar_animation/loginPage.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
  const ForgotPasswordPage();
}

final GlobalKey<State> keyLoader = GlobalKey<State>(); // Key for progress bar

String urlForgotPassword =
    "http://192.168.64.2/BlackBookVs/movil_forgot_password_function.php";
String email;

bool _isEmailValid(String email) {
  return RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
}

bool _autoValidate = false; //bool for autovalidate the form

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  ProgressDialog pr;
  final TextEditingController emailController = TextEditingController();
  // String email = "";

//////////////////////////////VALIDATES//////////////////////////////
  String _validateEmail(String value) {
    // The form is empty
    if (value.length == 0) {
      return "Please enter your email";
    }
    String p = "[a-zA-Z0-9\+\.\_\%\-\+]{1,256}" +
        "\\@" +
        "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}" +
        "(" +
        "\\." +
        "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25}" +
        ")+";
    RegExp regExp = new RegExp(p);

    if (regExp.hasMatch(value)) {
      return null;
    }
    return 'Email is not valid';
  }
////////////////////////////////////////////////////////////////////

///////////////////////////FORGOT PASS FUNCTION////////////////////////////////
  void _forgotPassFunction() {
    setState(() {
      _autoValidate = true;
    });
    email = emailController.text;
    if (_isEmailValid(email)) {
      http.post(urlForgotPassword, body: {
        "email": email,
      }).then((response) {
        print(response.statusCode);
        if (response.body ==
            "Please check your mailbox, login and change your password in profile") {
          Toast.show(response.body, context,
              backgroundColor: Colors.green[800],
              backgroundRadius: 5,
              gravity: Toast.CENTER,
              duration: Toast.LENGTH_LONG);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => LoginPage()));
        } else {
          setState(() {
            _autoValidate = true;
          });
          Toast.show(response.body, context,
              backgroundColor: Colors.red[800],
              backgroundRadius: 5,
              gravity: Toast.CENTER,
              duration: Toast.LENGTH_LONG);
        }
      }).catchError((error) {
        setState(() {
          _autoValidate = true;
        });
        print(error);
      });
    } else {
      setState(() {
        _autoValidate = true;
      });
      Toast.show("Please enter a correct email", context,
          backgroundColor: Colors.red[800],
          backgroundRadius: 5,
          gravity: Toast.CENTER,
          duration: Toast.LENGTH_LONG);
    }
  }
///////////////////////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
/////////////////////PROGRESS DIALOG SETTING/////////////////////////
    pr = ProgressDialog(
      context,
      type: ProgressDialogType.Normal,
      isDismissible: false,
      showLogs: false,
      customBody: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Center(
            heightFactor: 15,
            child: CircularProgressIndicator(
              backgroundColor: Colors.yellow,
              valueColor: AlwaysStoppedAnimation((Colors.redAccent)),
            ),
          ),
        ],
      ),
    );
    pr.style(
      backgroundColor: Colors.transparent,
      elevation: 0.0,
    );
///////////////////////////////////////////////////////////////////////
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: Container(
        decoration: BoxDecoration(
          gradient: new LinearGradient(
            colors: [const Color(0xFFE4E1E1), const Color(0xFF858484)],
            begin: FractionalOffset.topLeft,
            end: FractionalOffset.bottomRight,
            tileMode: TileMode.clamp,
          ),
        ),
        child: ListView(children: <Widget>[
          Container(
            child: Stack(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.fromLTRB(15.0, 30.0, 0.0, 0.0),
                  child: Text(
                    'Black',
                    style: TextStyle(
                      fontSize: 80.0,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: <Shadow>[
                        Shadow(
                          offset: Offset(10.0, 10.0),
                          blurRadius: 3.0,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(15.0, 100.0, 0.0, 0.0),
                  child: Text(
                    'Book',
                    style: TextStyle(
                      fontSize: 80.0,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: <Shadow>[
                        Shadow(
                          offset: Offset(10.0, 10.0),
                          blurRadius: 3.0,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(230.0, 20.0, 0.0, 0.0),
                  child: Image.asset(
                    'assets/BlackBookVsSombra 324x277.png',
                    width: 200.0,
                    height: 200.0,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 20, left: 20.0, right: 20.0),
            child: Column(
              children: <Widget>[
                Text(
                  "Forgot Password?",
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Monserrat',
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Please enter your registered email",
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Monserrat',
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: emailController,
                  autovalidate: _autoValidate,
                  validator: _validateEmail,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(left: 0, right: 10),
                        child: Icon(Icons.mail, color: Colors.white),
                      ),
                      labelText: 'EMAIL',
                      labelStyle: TextStyle(
                          fontFamily: 'Monserrat',
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white))),
                ),
                SizedBox(
                  height: 40,
                ),
                Container(
                  child: RaisedButton(
                    onPressed: () {
                      _forgotPassFunction();
                      pr.show();
                      Future.delayed(Duration(seconds: 3)).then((value) {
                        pr.hide().whenComplete(() {});
                      });
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(80.0)),
                    padding: EdgeInsets.all(0.0),
                    child: Ink(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.yellow[400],
                              Colors.red[500],
                              Colors.red[900],
                              Colors.black
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: [0.1, 0.3, 0.4, 1.0],
                          ),
                          borderRadius: BorderRadius.circular(30.0)),
                      child: Container(
                        constraints:
                            BoxConstraints(maxWidth: 500.0, minHeight: 50.0),
                        alignment: Alignment.center,
                        child: Text(
                          "Submit",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Monserrat'),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                Container(
                  height: 50.0,
                  color: Colors.transparent,
                  child: FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(80.0)),
                    padding: EdgeInsets.all(0.0),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: Colors.white,
                            style: BorderStyle.solid,
                            width: 1.0),
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      child: Container(
                        constraints:
                            BoxConstraints(maxWidth: 500.0, minHeight: 50.0),
                        alignment: Alignment.center,
                        child: Text(
                          "Go Back",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Monserrat'),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
