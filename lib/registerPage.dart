import 'dart:io';
// import 'dart:async';
import 'dart:convert';
// import 'dart:html' as file;
import 'package:toast/toast.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:sidebar_animation/loginPage.dart';
import 'bloc.navigation_bloc/navigation_bloc.dart';
import 'package:progress_dialog/progress_dialog.dart';

class RegisterPage extends StatefulWidget with NavigationStates {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  ProgressDialog pr; //PROGRESS DIALOG INSTANCE
  final _formKey = GlobalKey<FormState>(); //KEY FORM VALIDATOR
  bool _autoValidate = false; //BOOL FOR AUTOVALIDATE THE FORM

/////////////////////IMAGE PICKER/////////////////////////////////
  File _image;
  Future _getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
      print('_image: $image');
    });
  }
//////////////////////////////////////////////////////////////////

///////////////////////////PASS VALIDATE/////////////////////////
  String _validatePassword(String value) {
    // print("valorrr $value passsword ${passController.text}");
    if (value != passController.text) {
      return "Passwords do not match";
    } else if (value.length == 0) {
      return "Please enter your password";
    } else if (value.length < 6) {
      return "Password must at least 6 characters";
    } else {
      return null;
    }
  }
////////////////////////////////////////////////////////////////////////

////////////////////////////SHOW HIDE OBSCURE TEXT///////////////////////
  bool _obscureText = true;
  showHidePassword() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }
/////////////////////////////////////////////////////////////////////////

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

  String _validateName(String value) {
    if (value.length == 0) {
      return "Please enter your name";
    } else {
      return null;
    }
  }

  String _validatePhone(String value) {
    String p = r'(^[0-9]*$)';
    RegExp regExp = new RegExp(p);
    if (value.length == 0) {
      return "Please enter your phone number";
    } else if (value.length < 9 || value.length > 11) {
      return "Phone number must 10-11 digits";
    } else if (!regExp.hasMatch(value)) {
      return "Please enter correct phone number";
    } else {
      return null;
    }
  }
/////////////////////////////////////////////////////////////////////

///////////////////////////BOOL VALIDATE EMAIL///////////////////////
  bool _isEmailValid(String email) {
    return RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
  }
////////////////////////////////////////////////////////////////////////

///////////////////////////REGISTER FUNCTION///////////////////////////////
  String urlRegisterFunction =
      "http://192.168.64.2/BlackBookVs/movil_register_function.php";
  TextEditingController userController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController pass2Controller = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  void _registerFunction() {
    setState(() {
      _autoValidate = true;
    });
    if ((_isEmailValid(emailController.text)) &&
        (passController.text.length > 5)) {
      String base64Image = base64Encode(_image.readAsBytesSync());
      http.post(urlRegisterFunction, body: {
        "name": userController.text,
        "email": emailController.text,
        "password": passController.text,
        "city": cityController.text,
        "country": countryController.text,
        "phone": phoneController.text,
        "encoded_string": base64Image,
      }).then((response) {
        print(response.statusCode);
        if (response.body == "Registered!, please check your mailbox") {
          setState(() {
            // _autoValidate = true;
          });
          Toast.show(response.body, context,
              backgroundColor: Colors.green[800],
              backgroundRadius: 5,
              gravity: Toast.CENTER,
              duration: Toast.LENGTH_LONG);
          _image = null;
          emailController.text = '';
          userController.text = '';
          passController.text = '';
          cityController.text = '';
          countryController.text = '';
          phoneController.text = '';
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => LoginPage()));
        } else if (response.body == "Email already in use, try another") {
          setState(() {
            _autoValidate = true;
          });
          Toast.show(response.body, context,
              backgroundColor: Colors.red[800],
              backgroundRadius: 5,
              gravity: Toast.CENTER,
              duration: Toast.LENGTH_LONG);
        } else if (response.body == "Invalid phone format") {
          setState(() {
            _autoValidate = true;
          });
          Toast.show(response.body, context,
              backgroundColor: Colors.red[800],
              backgroundRadius: 5,
              gravity: Toast.CENTER,
              duration: Toast.LENGTH_LONG);
        } else if (response.body == "Error! user failed to register") {
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
        var error;
        print(error);
        Toast.show(error.body, context,
            backgroundColor: Colors.red[800],
            backgroundRadius: 5,
            gravity: Toast.CENTER,
            duration: Toast.LENGTH_LONG);
      });
    } else {
      setState(() {
        _autoValidate = true;
      });
    }
  }
///////////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    ///////////////PROGRESS DIALOG SETTING/////////////////////////////////
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
      // body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
      body: Container(
        decoration: BoxDecoration(
          // borderRadius: BorderRadius.all(Radius.circular(40)),
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
            padding: EdgeInsets.only(top: 50, left: 20.0, right: 20.0),
            child: Column(
              children: <Widget>[
                Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
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
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                            errorStyle: TextStyle(color: Colors.white),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white))),
                      ),
                      SizedBox(height: 10.0),
                      TextFormField(
                        controller: userController,
                        autovalidate: _autoValidate,
                        validator: _validateName,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                            prefixIcon: Padding(
                              padding: EdgeInsets.only(left: 0, right: 10),
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                            labelText: 'USER',
                            labelStyle: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                            errorStyle: TextStyle(color: Colors.white),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white))),
                      ),
                      SizedBox(height: 10.0),
                      TextFormField(
                        controller: passController,
                        autovalidate: _autoValidate,
                        validator: _validatePassword,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                            prefixIcon: Padding(
                              padding: EdgeInsets.only(left: 0, right: 10),
                              child: Icon(Icons.lock, color: Colors.white),
                            ),
                            labelText: 'PASSWORD ',
                            labelStyle: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
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
                      SizedBox(height: 10.0),
                      TextFormField(
                        controller: pass2Controller,
                        autovalidate: _autoValidate,
                        validator: _validatePassword,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                            prefixIcon: Padding(
                              padding: EdgeInsets.only(left: 0, right: 10),
                              child: Icon(Icons.lock, color: Colors.white),
                            ),
                            labelText: 'REPEAT PASSWORD ',
                            labelStyle: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
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
                      SizedBox(height: 10.0),
                      TextFormField(
                        controller: cityController,
                        // autovalidate: _autoValidate,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                            prefixIcon: Padding(
                              padding: EdgeInsets.only(left: 0, right: 10),
                              child: Icon(Icons.location_city,
                                  color: Colors.white),
                            ),
                            labelText: 'CITY',
                            labelStyle: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                            errorStyle: TextStyle(color: Colors.white),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white))),
                      ),
                      SizedBox(height: 10.0),
                      TextFormField(
                        controller: countryController,
                        // autovalidate: _autoValidate,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                            prefixIcon: Padding(
                              padding: EdgeInsets.only(left: 0, right: 10),
                              child: Icon(Icons.location_city,
                                  color: Colors.white),
                            ),
                            labelText: 'COUNTRY',
                            labelStyle: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                            errorStyle: TextStyle(color: Colors.white),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white))),
                      ),
                      SizedBox(height: 10.0),
                      TextFormField(
                        controller: phoneController,
                        autovalidate: _autoValidate,
                        validator: _validatePhone,
                        keyboardType: TextInputType.phone,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                            prefixIcon: Padding(
                              padding: EdgeInsets.only(left: 0, right: 10),
                              child: Icon(Icons.phone, color: Colors.white),
                            ),
                            labelText: 'PHONE',
                            labelStyle: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                            errorStyle: TextStyle(color: Colors.white),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white))),
                      ),
                      SizedBox(height: 20.0),
                      Row(
                        children: <Widget>[
                          Container(
                            height: 30.0,
                            child: FlatButton(
                              onPressed: () {
                                _getImage();
                              },
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0)),
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
                                      maxWidth: 120.0, minHeight: 100.0),
                                  alignment: Alignment.center,
                                  child: Text(
                                    "CHOOSE IMAGE",
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
                          SizedBox(width: 10.0),
                          _image == null
                              ? Text(
                                  'NO IMAGE SELECTED',
                                  style: TextStyle(
                                    color: Colors.yellow,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : Image.file(
                                  _image,
                                  height: 70,
                                  width: 70,
                                ),
                        ],
                      ),
                      SizedBox(height: 20.0),
                      Container(
                        height: 50.0,
                        child: RaisedButton(
                          onPressed: () {
                            _registerFunction();
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
                              constraints: BoxConstraints(
                                  maxWidth: 500.0, minHeight: 50.0),
                              alignment: Alignment.center,
                              child: Text(
                                "Register",
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
                              constraints: BoxConstraints(
                                  maxWidth: 500.0, minHeight: 50.0),
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
                SizedBox(height: 20.0),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
