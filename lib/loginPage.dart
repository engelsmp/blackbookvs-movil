import 'dart:convert';
import 'forgotPassPage.dart';
import 'package:toast/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'bloc.navigation_bloc/navigation_bloc.dart';
import 'package:progress_dialog/progress_dialog.dart';

var idUser = '';
var userName = '';
var userMail = '';
// var userCity = '';
// var userCountry = '';
// var userPhone = '';

class LoginPage extends StatefulWidget with NavigationStates {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  ProgressDialog pr;
  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false; // bool for autovalidate formTextField

//////////////////////////LOGIN FUNCTION////////////////////////////
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  String urlLoginFunction =
      "http://192.168.64.2/BlackBookVs/movil_login_function.php";

  Future<List> _loginFunction() async {
    final dataLogin = await http.post(urlLoginFunction, body: {
      "password": passController.text,
      "email": emailController.text,
    });
    var dataUser = json.decode(dataLogin.body);
    if (dataUser.length == 0) {
      Toast.show('Wrong Mail or Password', context,
          backgroundColor: Colors.red[800],
          backgroundRadius: 5,
          gravity: Toast.CENTER,
          duration: Toast.LENGTH_LONG);
      // pr.hide();
      setState(() {
        _autoValidate = true;
      });
    } else {
      if (dataUser[0]['verify'] == '0') {
        Toast.show('Email still not verify', context,
            backgroundColor: Colors.red[800],
            backgroundRadius: 5,
            gravity: Toast.CENTER,
            duration: Toast.LENGTH_LONG);
        // pr.hide();
        setState(() {
          _autoValidate = true;
        });
      } else if (dataUser[0]['verify'] == '1') {
        Navigator.pushReplacementNamed(context, '/SideBarLayout');
        Toast.show('Login successful', context,
            backgroundColor: Colors.green[800],
            backgroundRadius: 5,
            gravity: Toast.CENTER,
            duration: Toast.LENGTH_LONG);
      }
      idUser = dataUser[0]['id_user'];
      userName = dataUser[0]['name'];
      userMail = dataUser[0]['email'];
      if (userName != null) {
      } else {
        Toast.show('Wrong Mail or Password', context,
            backgroundColor: Colors.red[800],
            backgroundRadius: 5,
            gravity: Toast.CENTER,
            duration: Toast.LENGTH_LONG);
        // pr.hide();
        setState(() {
          _autoValidate = true;
        });
      }
    }
    return dataUser;
  }
///////////////////////////////////////////////////////////////////

////////////////////////VALIDATES////////////////////////////
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

  String _validatePassword(String value) {
    if (value.length == 0) {
      return "Cannot be empty";
    } else if (value.length < 6) {
      return "Password must at least 6 characters";
    } else {
      return null;
    }
  }
///////////////////////////////////////////////////////////////

///////////////////SHOW HIDE OBSCURE TEXT///////////////////////////
  bool _obscureText = true;
  showHidePassword() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }
/////////////////////////////////////////////////////////////////////

////////////////////////////FORGOT PASSWORD/////////////////////////
  void _onForgotPassword() {
    print('Forgot password');
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => ForgotPasswordPage()));
  }
////////////////////////////////////////////////////////////////////

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
      // backgroundColor: backgroundColor,
      resizeToAvoidBottomPadding: false,
      body: Container(
        decoration: BoxDecoration(
          gradient: new LinearGradient(
            colors: [const Color(0xFFE4E1E1), const Color(0xFF858484)],
            begin: FractionalOffset.topRight,
            end: FractionalOffset.bottomLeft,
            tileMode: TileMode.clamp,
          ),
        ),
        child: ListView(
          children: <Widget>[
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
                    )),
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
                    )),
                Container(
                    padding: EdgeInsets.fromLTRB(230.0, 20.0, 0.0, 0.0),
                    child: Image.asset(
                      'assets/BlackBookVsSombra 324x277.png',
                      width: 200.0,
                      height: 200.0,
                    )),
              ],
            )),
            Container(
              padding: EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      autovalidate: _autoValidate,
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(left: 0, right: 10),
                            child: Icon(Icons.mail, color: Colors.white),
                          ),
                          labelText: 'EMAIL',
                          labelStyle: TextStyle(
                              fontFamily: 'Monserrat', color: Colors.white),
                          errorStyle: TextStyle(color: Colors.white),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white))),
                    ),
                    SizedBox(height: 20.0),
                    TextFormField(
                      autovalidate: _autoValidate,
                      controller: passController,
                      validator: _validatePassword,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(left: 0, right: 10),
                            child: Icon(Icons.lock, color: Colors.white),
                          ),
                          labelText: 'PASSWORD',
                          labelStyle: TextStyle(
                              fontFamily: 'Monserrat', color: Colors.white),
                          errorStyle: TextStyle(color: Colors.white),
                          suffixIcon: IconButton(
                            onPressed: showHidePassword,
                            icon: Icon(
                                _obscureText
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.white70),
                          ),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white))),
                      obscureText: _obscureText,
                    ),
                    SizedBox(height: 5.0),
                    Container(
                      alignment: Alignment(1.0, 0.0),
                      padding: EdgeInsets.only(top: 15.0, left: 20.0),
                      child: GestureDetector(
                          onTap: _onForgotPassword,
                          child: Text(
                            'Forgot Password',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Monserrat',
                                decoration: TextDecoration.underline),
                          )),
                    ),
                    SizedBox(height: 40.0),
                    Container(
                      height: 50.0,
                      child: RaisedButton(
                        elevation: 8,
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            _loginFunction();
                            pr.show();
                            Future.delayed(Duration(seconds: 3)).then((value) {
                              pr.hide().whenComplete(() {});
                            });
                            // connectionCheck();
                          }
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
                            constraints: BoxConstraints(
                                maxWidth: 500.0, minHeight: 50.0),
                            alignment: Alignment.center,
                            child: Text(
                              "Login",
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
                          SystemNavigator.pop();
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
                            constraints: BoxConstraints(
                                maxWidth: 500.0, minHeight: 50.0),
                            alignment: Alignment.center,
                            child: Text(
                              "Exit",
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
            ),
            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'New in BlackBookVS?',
                  style: TextStyle(
                    fontFamily: 'Monserrat',
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 5.0),
                InkWell(
                  onTap: () {
                    Navigator.of(context).pushNamed('/RegisterPage');
                  },
                  child: Text(
                    'Register',
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Monserrat',
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }
}
