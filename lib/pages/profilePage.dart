import 'dart:io';
import 'dart:convert';
import 'package:toast/toast.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../loginPage.dart' show userMail;
import 'package:progress_dialog/progress_dialog.dart';
import '../bloc.navigation_bloc/navigation_bloc.dart';

class ProfilePage extends StatefulWidget with NavigationStates {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  ProgressDialog pr; //PROGRESS DIALOG INSTANCE
  final _formKey = GlobalKey<FormState>(); //KEY FORM VALIDATOR
  bool _autoValidate = false; //BOOL FOR AUTOVALIDATE THE FORM
  bool _autoValidate2 = false; //BOOL FOR AUTOVALIDATE THE FORM
  String userImagePath = 'http://192.168.64.2/BlackBookVs/images/avatar_users/';
  String urlUpdateDataProfileFunction =
      "http://192.168.64.2/BlackBookVs/movil_updateDataProfile_function.php";
  String urlChangePasswordFunction =
      "http://192.168.64.2/BlackBookVs/movil_changePasswordProfile_function.php";
  String urlChangeImageFunction =
      "http://192.168.64.2/BlackBookVs/movil_changeImageProfile_function.php";
  TextEditingController _userController = new TextEditingController();
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _cityController = new TextEditingController();
  TextEditingController _countryController = new TextEditingController();
  TextEditingController _phoneController = new TextEditingController();
  TextEditingController passController = new TextEditingController();
  TextEditingController pass2Controller = new TextEditingController();
  var userEmail = '';
  var userName = '';
  var userCity = '';
  var userCountry = '';
  var userPhone = '';

/////////////////////IMAGE PICKER///////////////////////////////////////
  File _image;
  Future _getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
      print('_image: $image');
    });
  }
///////////////////////////////////////////////////////////////////////

//////////////////////////////VALIDATES////////////////////////////////
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

///////////////////////////PASS VALIDATE/////////////////////////////
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

// ///////////////////////////BOOL VALIDATE EMAIL//////////////////////////
//   bool _isEmailValid(String email) {
//     return RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
//   }
// ////////////////////////////////////////////////////////////////////////

////////////////////////////SHOW HIDE OBSCURE TEXT///////////////////////
  bool _obscureText = true;
  showHidePassword() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }
/////////////////////////////////////////////////////////////////////////

//////////////////////////FETCH PROFILE FUNCTION//////////////////////////
  String urlFetchProfileFunction =
      "http://192.168.64.2/BlackBookVs/movil_fetchProfile_function.php";

  Future<List> _fetchProfileFunction() async {
    // await Future.delayed(Duration(seconds: 2));
    final dataProfilePage = await http.post(urlFetchProfileFunction, body: {
      "email": userMail,
    });
    var dataUser = json.decode(dataProfilePage.body);
    if (userMail != null) {
      setState(() {
        userName = dataUser[0]['name'];
        userEmail = dataUser[0]['email'];
        userCity = dataUser[0]['city'];
        userCountry = dataUser[0]['country'];
        userPhone = dataUser[0]['phone'];
        ///////////////////////////////////
        _userController.text = '$userName';
        _emailController.text = '$userEmail';
        _cityController.text = '$userCity';
        _countryController.text = '$userCountry';
        _phoneController.text = '$userPhone';
      });
    }
    return null;
  }
//////////////////////////////////////////////////////////////////////////

///////////////////////////UPDATE DATA FUNCTION/////////////////////////////
  void _updateDataProfileFunction() {
    setState(() {
      _autoValidate = true;
    });
    http.post(urlUpdateDataProfileFunction, body: {
      "name": _userController.text,
      "email": _emailController.text,
      "city": _cityController.text,
      "country": _countryController.text,
      "phone": _phoneController.text,
    }).then((response) {
      print(response.statusCode);
      if (response.body == "Data updated!") {
        Toast.show(response.body, context,
            backgroundColor: Colors.green[800],
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
      }
    }).catchError((error) {
      setState(() {
        _autoValidate = true;
      });
      var error;
      Toast.show(error.body, context,
          backgroundColor: Colors.red[800],
          backgroundRadius: 5,
          gravity: Toast.CENTER,
          duration: Toast.LENGTH_LONG);
    });
  }
///////////////////////////////////////////////////////////////////////////

//////////////////////////CHANGE PASS FUNCTION/////////////////////////////
  void _changePasswordFunction() {
    setState(() {
      _autoValidate2 = true;
    });
    if (passController.text.length > 5) {
      http.post(urlChangePasswordFunction, body: {
        "email": userMail,
        "password": passController.text,
      }).then((response) {
        print(response.statusCode);
        if (response.body == "Password changed!") {
          passController.text = '';
          pass2Controller.text = '';
          Toast.show(response.body, context,
              backgroundColor: Colors.green[800],
              backgroundRadius: 5,
              gravity: Toast.CENTER,
              duration: Toast.LENGTH_LONG);
        } else if (response.body == "Error!, pass not change") {
          setState(() {
            _autoValidate2 = true;
          });
          Toast.show(response.body, context,
              backgroundColor: Colors.red[800],
              backgroundRadius: 5,
              gravity: Toast.CENTER,
              duration: Toast.LENGTH_LONG);
        }
      }).catchError((error) {
        setState(() {
          _autoValidate2 = true;
        });
        var error;
        Toast.show(error.body, context,
            backgroundColor: Colors.red[800],
            backgroundRadius: 5,
            gravity: Toast.CENTER,
            duration: Toast.LENGTH_LONG);
      });
    }
  }
///////////////////////////////////////////////////////////////////////////

///////////////////////////CHANGE IMAGE FUNCTION/////////////////////////////
  void _updateImageProfileFunction() {
    String base64Image = base64Encode(_image.readAsBytesSync());
    http.post(urlChangeImageFunction, body: {
      "email": userMail,
      "encoded_string": base64Image,
    }).then((response) {
      print(response.statusCode);
      if (response.body == "Image updated!") {
        // Navigator.pushReplacementNamed(context, '/SideBarLayout');
        Toast.show(response.body, context,
            backgroundColor: Colors.green[800],
            backgroundRadius: 5,
            gravity: Toast.CENTER,
            duration: Toast.LENGTH_LONG);
      } else if (response.body == "Error! image not changed") {
        Toast.show(response.body, context,
            backgroundColor: Colors.red[800],
            backgroundRadius: 5,
            gravity: Toast.CENTER,
            duration: Toast.LENGTH_LONG);
      }
    }).catchError((error) {
      var error;
      Toast.show(error.body, context,
          backgroundColor: Colors.red[800],
          backgroundRadius: 5,
          gravity: Toast.CENTER,
          duration: Toast.LENGTH_LONG);
    });
  }
///////////////////////////////////////////////////////////////////////////

  @override
  void initState() {
    _fetchProfileFunction();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
/////////////////////PROGRESS DIALOG SETTING//////////////////////////////
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
    return Container(
      decoration: BoxDecoration(
        gradient: new LinearGradient(
          colors: [const Color(0xFFE4E1E1), const Color(0xFF858484)],
          begin: FractionalOffset.topLeft,
          end: FractionalOffset.bottomRight,
          tileMode: TileMode.clamp,
        ),
      ),
      padding: const EdgeInsets.only(left: 16, right: 16, top: 48),
      child: ListView(
        children: <Widget>[
          Center(
            child: Text(
              "Profile",
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
          ),
          Divider(color: Colors.white),
          Container(
            padding: EdgeInsets.only(top: 50, left: 20.0, right: 20.0),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    _image == null
                        ? Container(
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
                                    "Choose Image",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Monserrat'),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Container(
                            height: 30.0,
                            child: FlatButton(
                              onPressed: () {
                                pr.show();
                                Future.delayed(Duration(seconds: 3))
                                    .then((value) {
                                  pr.hide().whenComplete(() {});
                                });
                                _updateImageProfileFunction();
                                setState(() {});
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
                                    "Update Image",
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
                        ? Container(
                            height: 100.0,
                            width: 100.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                fit: BoxFit.fill,
                                image: NetworkImage(
                                  userImagePath + userMail + '.jpg', //USER PIC
                                ),
                              ),
                            ),
                          )
                        : ClipOval(
                            child: Image.file(
                              _image,
                              height: 100,
                              width: 100,
                            ),
                          ),
                  ],
                ),
                SizedBox(height: 30),
                Divider(color: Colors.white),
                SizedBox(height: 20.0),
                Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        controller: _emailController,
                        autovalidate: _autoValidate,
                        validator: _validateEmail,
                        enabled: false,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                            prefixIcon: Padding(
                              padding: EdgeInsets.only(left: 0, right: 10),
                              child: Icon(Icons.mail, color: Colors.white),
                            ),
                            // border: InputBorder.none,
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
                        controller: _userController,
                        autovalidate: _autoValidate,
                        validator: _validateName,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                            prefixIcon: Padding(
                              padding: EdgeInsets.only(left: 0, right: 10),
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                            labelText: 'USER ',
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
                        controller: _cityController,
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
                        controller: _countryController,
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
                        controller: _phoneController,
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
                      SizedBox(height: 20),
                      Container(
                        height: 50.0,
                        width: 140,
                        color: Colors.transparent,
                        child: FlatButton(
                          onPressed: () {
                            _updateDataProfileFunction();
                            pr.show();
                            Future.delayed(Duration(seconds: 3)).then((value) {
                              pr.hide().whenComplete(() {});
                            });
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
                                "Update Data",
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
                      SizedBox(height: 30.0),
                      Divider(color: Colors.white),
                      TextFormField(
                        controller: passController,
                        autovalidate: _autoValidate2,
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
                        autovalidate: _autoValidate2,
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
                      SizedBox(height: 20),
                      Container(
                        height: 50.0,
                        width: 140,
                        color: Colors.transparent,
                        child: FlatButton(
                          onPressed: () {
                            _changePasswordFunction();
                            pr.show();
                            Future.delayed(Duration(seconds: 3)).then((value) {
                              pr.hide().whenComplete(() {});
                            });
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
                                "Change Password",
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
                SizedBox(height: 30.0),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
