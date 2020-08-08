import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:json_table/json_table.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'package:toast/toast.dart';
import '../bloc.navigation_bloc/navigation_bloc.dart';
import '../loginPage.dart';

class GameEntryPage extends StatefulWidget with NavigationStates {
  @override
  _GameEntryPageState createState() => _GameEntryPageState();
}

class _GameEntryPageState extends State<GameEntryPage> {
  ProgressDialog pr; //PROGRESS DIALOG INSTANCE
  bool _canShowSelectDate = true; //BOOL FOR SHOW/HIDE SELECTDATE LABEL
  var _selectedDate;
  dynamic _selectedGame;
  bool _autoValidate = false; // BOOL FOR AUTOVALIDATE THE FORM
  var _selectedPlayer;
  String playersImagePath = "http://192.168.64.2/BlackBookVs/images/utilities/";

////////////////////////COUNT SETS REGISTER FUNCTION////////////////////////////
  String urlCountSetstoRegisterFunction =
      "http://192.168.64.2/BlackBookVs/movil_countSetstoRegister_function.php";

  var countSets;

  Future<List> _countSetstoRegister() async {
    var sendEmail = await http.post(urlCountSetstoRegisterFunction, body: {
      "email": userMail,
    });
    var response = json.decode(sendEmail.body);

    setState(() {
      countSets = response[0]['count(*)'];
    });
    return null;
  }
///////////////////////////////////////////////////////////////////////////////

//////////////////////SELECT DATE CONTENT/////////////////////////////////////
  // DateTime selectedDate = DateTime.now();

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101),
        builder: (context, child) {
          return SingleChildScrollView(
            child: Theme(
              child: child,
              data: ThemeData.dark(),
            ),
          );
        });
    if (picked != null && picked != DateTime.now())
      setState(
        () {
          _selectedDate = picked;
        },
      );
    print(_selectedDate);
  }
///////////////////////////////////////////////////////////////////////////

////////////////////////FECTH SELECT PLAYER FUNCTION///////////////////////
  String urlSelectGameFunction =
      "http://192.168.64.2/BlackBookVs/movil_selectGame_function.php";

  List dataSelectGame = List();

  Future<List> _fetchSelectGame() async {
    var getGames = await http.post(urlSelectGameFunction, body: {
      // "email": userMail,
    });
    var response = json.decode(getGames.body);

    setState(() {
      dataSelectGame = response;
    });
    // print(dataSelectGame);
  }

////////////////////////////////////////////////////////////////////////////

///////////////////////////DATA ENTRY FUNCTION//////////////////////////////
  String urlDataEntryFunction =
      "http://192.168.64.2/BlackBookVs/movil_dataEntry_function.php";
  TextEditingController setsCountController = new TextEditingController();
  TextEditingController player1WinsController = new TextEditingController();
  String player2Wins = '0';

  void _dataEntryFunction() {
    setState(() {
      _autoValidate = true;
    });
    if (_selectedDate == null) {
      Toast.show('Please, select a Date', context,
          backgroundColor: Colors.red[800],
          backgroundRadius: 5,
          gravity: Toast.CENTER,
          duration: Toast.LENGTH_LONG);
    } else if (_selectedGame == null) {
      Toast.show('Please, select a Game', context,
          backgroundColor: Colors.red[800],
          backgroundRadius: 5,
          gravity: Toast.CENTER,
          duration: Toast.LENGTH_LONG);
    } else if (_selectedPlayer == null) {
      Toast.show('Please, select a Player', context,
          backgroundColor: Colors.red[800],
          backgroundRadius: 5,
          gravity: Toast.CENTER,
          duration: Toast.LENGTH_LONG);
    } else if (!_isEntriesValid(setsCountController.text)) {
      Toast.show('Fill the sets count', context,
          backgroundColor: Colors.red[800],
          backgroundRadius: 5,
          gravity: Toast.CENTER,
          duration: Toast.LENGTH_LONG);
    } else if (!_isEntriesValid2(player1WinsController.text)) {
      Toast.show('Fill the player 1 Wins', context,
          backgroundColor: Colors.red[800],
          backgroundRadius: 5,
          gravity: Toast.CENTER,
          duration: Toast.LENGTH_LONG);
    } else {
      setState(() {
        // _autoValidate == false;
      });
      http.post(urlDataEntryFunction, body: {
        "selectedDate": _selectedDate.toString(),
        "selectedGame": _selectedGame,
        "setsCount": setsCountController.text,
        "userMail": userMail,
        "selectedPlayer": _selectedPlayer,
        "player1Wins": player1WinsController.text,
        "player2Wins": player2Wins,
      }).then((response) {
        print(response.statusCode);
        print(response.body);
        if (response.body == "Sets registered!") {
          Toast.show(response.body, context,
              backgroundColor: Colors.green[800],
              backgroundRadius: 5,
              gravity: Toast.CENTER,
              duration: Toast.LENGTH_LONG);
          setState(() {
            setsCountController.text = '';
            player1WinsController.text = '';
          });
        } else if (response.body == "Sets count cannot be less than wins") {
          Toast.show(response.body, context,
              backgroundColor: Colors.red[800],
              backgroundRadius: 5,
              gravity: Toast.CENTER,
              duration: Toast.LENGTH_LONG);
        } else if (response.body == "Error! data not register") {
          Toast.show(response.body, context,
              backgroundColor: Colors.red[800],
              backgroundRadius: 5,
              gravity: Toast.CENTER,
              duration: Toast.LENGTH_LONG);
        }
      }).catchError((error) {
        var error;
        print(error);
        Toast.show(error.body, context,
            backgroundColor: Colors.red[800],
            backgroundRadius: 5,
            gravity: Toast.CENTER,
            duration: Toast.LENGTH_LONG);
      });
    }
  }
///////////////////////////////////////////////////////////////////

////////////////////////FECTH SELECT PLAYER FUNCTION////////////////////////
  String urlSelectPlayerFunction =
      "http://192.168.64.2/BlackBookVs/movil_selectPlayer_function.php";

  List dataSelectPlayer = List();

  Future<List> _fetchSelectPlayer() async {
    var sendEmail = await http.post(urlSelectPlayerFunction, body: {
      "email": userMail,
    });
    var response = json.decode(sendEmail.body);

    setState(() {
      dataSelectPlayer = response;
    });
    print(_selectedPlayer);
    return null;
  }
//////////////////////////////////////////////////////////////////////////

//////////////////////////VALIDATES///////////////////////////////////////

////////////////////////////BOOL VALIDATE ENTRIES/////////////////////////
  bool _isEntriesValid(String setsCountController) {
    return RegExp(r"^[0-9]").hasMatch(setsCountController);
  }

  bool _isEntriesValid2(String player1WinsController) {
    return RegExp(r"^[0-9]").hasMatch(player1WinsController);
  }
////////////////////////////////////////////////////////////////////////

  String _validateEntries(String value) {
    String p = r'(^[0-9]*$)';
    RegExp regExp = new RegExp(p);
    if (value.length == 0) {
      return "Please enter a number";
      // } else if (setsCountController.text <
      //    player1WinsController.text) {
      //   return "Sets count cannot be less than wins";
    } else if (!regExp.hasMatch(value)) {
      return "Invalid format number";
    } else {
      return null;
    }
  }
  ////////////////////////////////////////////////////////////////////////

  @override
  void initState() {
    _countSetstoRegister();
    _fetchSelectGame();
    _fetchSelectPlayer();
    super.initState();
  }

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

    return Card(
      child: Container(
        decoration: BoxDecoration(
          gradient: new LinearGradient(
            colors: [const Color(0xFFE4E1E1), const Color(0xFF858484)],
            begin: FractionalOffset.topRight,
            end: FractionalOffset.bottomLeft,
            tileMode: TileMode.clamp,
          ),
        ),
        padding: const EdgeInsets.only(left: 16, right: 16, top: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Text(
                "Game Entry",
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
            Divider(color: Colors.white),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FlatButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => SetstoRegister(),
                      ),
                    );
                  },
                  child: Container(
                    height: 40,
                    width: 130,
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(5))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "Sets registration  ",
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        countSets == null
                            ? Text('')
                            : Container(
                                padding: EdgeInsets.all(3),
                                decoration: new BoxDecoration(
                                  color: Colors.yellow,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  countSets,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 25),
                  _canShowSelectDate
                      ? FlatButton(
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2.0,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5))),
                            width: 195,
                            height: 48,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "Select ",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      WidgetSpan(
                                        child: Icon(
                                          Icons.date_range,
                                          size: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                      TextSpan(
                                        text: " Date",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          onPressed: () {
                            _selectDate(context);
                            setState(
                                () => _canShowSelectDate = !_canShowSelectDate);
                          },
                        )
                      : FlatButton(
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2.0,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5))),
                            // color: Colors.blue,
                            width: 195,
                            height: 48,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  '$_selectedDate'.split(' ')[0],
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          onPressed: () {
                            _selectDate(context);
                          },
                        ),
                  SizedBox(height: 4),
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(5))),
                    // color: Colors.blue,
                    width: 195,
                    height: 48,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(width: 25, height: 50),
                        SearchableDropdown(
                          hint: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "Select ",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                WidgetSpan(
                                  child: Icon(
                                    Icons.gamepad,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                                TextSpan(
                                  text: " Game",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          items: dataSelectGame.map((item) {
                            return DropdownMenuItem(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 25),
                                child: Text(
                                  item['game_name'],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              value: item['game_name'],
                            );
                          }).toList(),
                          menuBackgroundColor: Colors.grey[800],
                          isExpanded: false,
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: Colors.transparent,
                          ),
                          underline: SizedBox(),
                          value: _selectedGame,
                          isCaseSensitiveSearch: false,
                          searchHint: new Text(
                            'Select Game',
                            style: new TextStyle(
                                fontSize: 11, color: Colors.white),
                          ),
                          onChanged: (value) {
                            setState(
                              () {
                                _selectedGame = value;
                                print(_selectedGame);
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 4),
                  Container(
                    height: 50,
                    width: 195,
                    child: TextFormField(
                      onChanged: (value) {
                        setState(() {
                          int deduct = int.parse(setsCountController.text) -
                              int.parse(player1WinsController.text);
                          player2Wins = deduct.toString();
                          print(setsCountController.text);
                          print(player1WinsController.text);
                          print(player2Wins);
                        });
                      },
                      textAlign: TextAlign.center,
                      autovalidate: _autoValidate,
                      controller: setsCountController,
                      validator: _validateEntries,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Sets Count',
                        hintStyle: TextStyle(
                          // fontFamily: 'Monserrat',
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white, width: 2.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white, width: 2.0),
                        ),
                        errorStyle: TextStyle(color: Colors.white, fontSize: 9),
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                  Stack(
                    children: [
                      Container(
                        // color: Colors.blue,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              width: 60.0,
                              height: 20.0,
                              decoration: BoxDecoration(
                                // color: Colors.blue,
                                shape: BoxShape.rectangle,
                                image: DecorationImage(
                                  fit: BoxFit.fill,
                                  image: NetworkImage(
                                    playersImagePath +
                                        'Player1.png', //PLAYER1 PIC
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: 60.0,
                              height: 22.0,
                              decoration: BoxDecoration(
                                // color: Colors.blue,
                                shape: BoxShape.rectangle,
                                image: DecorationImage(
                                  fit: BoxFit.fill,
                                  image: NetworkImage(
                                    playersImagePath +
                                        'Player2.png', //PLAYER2 PIC
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white,
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                  // color: Colors.blue,
                  width: 147,
                  height: 48,
                  child: Center(
                    child: Text(
                      userMail,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 30.0,
                  height: 30.0,
                  decoration: BoxDecoration(
                    // color: Colors.blue,
                    shape: BoxShape.rectangle,
                    image: DecorationImage(
                      fit: BoxFit.fill,
                      image: NetworkImage(
                        playersImagePath + 'vsBlackBook 324x277.png', //VS PIC
                      ),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white,
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                  // color: Colors.blue,
                  width: 147,
                  height: 48,
                  child: SearchableDropdown(
                    hint: Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Select ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                            WidgetSpan(
                              child: Icon(
                                Icons.person,
                                size: 11,
                                color: Colors.white,
                              ),
                            ),
                            TextSpan(
                              text: " Player",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    items: dataSelectPlayer.map((item) {
                      return DropdownMenuItem(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 25, left: 10),
                          child: Text(
                            item['email'],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        value: item['email'],
                      );
                    }).toList(),
                    menuBackgroundColor: Colors.grey[800],
                    isExpanded: false,
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: Colors.transparent,
                    ),
                    underline: SizedBox(),
                    value: _selectedPlayer,
                    isCaseSensitiveSearch: false,
                    searchHint: new Text(
                      'Select Game',
                      style: new TextStyle(fontSize: 11, color: Colors.white),
                    ),
                    onChanged: (value) {
                      setState(
                        () {
                          _selectedPlayer = value;
                          print(_selectedPlayer);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Container(
                  height: 40,
                  width: 100,
                  child: TextFormField(
                    onChanged: (value) {
                      setState(() {
                        int deduct = int.parse(setsCountController.text) -
                            int.parse(player1WinsController.text);
                        player2Wins = deduct.toString();
                        print(setsCountController.text);
                        print(player1WinsController.text);
                        print(player2Wins);
                      });
                    },
                    textAlign: TextAlign.center,
                    autovalidate: _autoValidate,
                    controller: player1WinsController,
                    validator: _validateEntries,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Wins',
                      hintStyle: TextStyle(
                        // fontFamily: 'Monserrat',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 2.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 2.0),
                      ),
                      errorStyle: TextStyle(color: Colors.white, fontSize: 9),
                    ),
                  ),
                ),
                SizedBox(width: 40),
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white,
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                  height: 40,
                  width: 100,
                  child: Center(
                    child: Text(
                      player2Wins == '0' ? 'Wins' : player2Wins,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 40),
            Container(
              height: 40.0,
              color: Colors.transparent,
              child: FlatButton(
                onPressed: () {
                  _autoValidate = true;
                  _dataEntryFunction();
                  pr.show();
                  Future.delayed(Duration(seconds: 3)).then((value) {
                    pr.hide().whenComplete(() {});
                  });
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0)),
                padding: EdgeInsets.all(0.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Colors.white,
                        style: BorderStyle.solid,
                        width: 2.0),
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: Container(
                    constraints:
                        BoxConstraints(maxWidth: 500.0, minHeight: 50.0),
                    alignment: Alignment.center,
                    child: Text(
                      "Send",
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
    );
  }
}

//////////////////////////////SETS TO REGISTER MODAL////////////////////////////
class SetstoRegister extends StatefulWidget {
  @override
  _SetstoRegisterState createState() => _SetstoRegisterState();
}

/////////////////////////////VAR FOR TABLE COLUMNS/////////////////////////////
var columns2 = [
  JsonTableColumn("fecha", label: "Date"),
  JsonTableColumn("player1", label: "Player1"),
  JsonTableColumn("wins", label: "Wins"),
  JsonTableColumn("player2", label: "Player2"),
  JsonTableColumn("loses", label: "Wins"),
  JsonTableColumn("game", label: "Game"),
];
/////////////////////////////////////////////////////////////////////////////

var singleReg;

class _SetstoRegisterState extends State<SetstoRegister> {
//////////////////////////FETCH SETS TABLE FUNCTION//////////////////////////
  String urlFetchRegistrationTable =
      "http://192.168.64.2/BlackBookVs/movil_fetchSetsRegistrationTable_function.php";

  var jsonDataVsTemp;

  void _fetchSetsRegistrationTable() async {
    var sendData = await http.post(urlFetchRegistrationTable, body: {
      "email": userMail,
    });
    var response = json.decode(sendData.body);
    if (response.length == 0) {
      jsonDataVsTemp = null;
    } else {
      setState(() {
        jsonDataVsTemp = response;
      });
    }
    // print(jsonDataVsTemp);
  }
///////////////////////////////////////////////////////////////////////////////

////////////////////////SETS INSERT FUNCTION//////////////////////////////////
  String urlSetInsertFunction =
      "http://192.168.64.2/BlackBookVs/movil_setsInsertRegistration_function.php";

  void _setsInsertRegistration() async {
    http.post(urlSetInsertFunction, body: {
      "id_reg": singleReg['id_reg'],
      "fecha": singleReg['fecha'],
      "wins": singleReg['wins'],
      "loses": singleReg['loses'],
      "player1": singleReg['player1'],
      "player2": singleReg['player2'],
      "game": singleReg['game'],
    }).then((response) {
      print(response.statusCode);
      if (response.body == "Set registered!") {
        setState(() {});
        Toast.show(response.body, context,
            backgroundColor: Colors.green[800],
            backgroundRadius: 5,
            gravity: Toast.CENTER,
            duration: Toast.LENGTH_LONG);
      } else {
        Toast.show('Set not registered', context,
            backgroundColor: Colors.red[800],
            backgroundRadius: 5,
            gravity: Toast.CENTER,
            duration: Toast.LENGTH_LONG);
      }
    }).catchError((error) {});
  }
///////////////////////////////////////////////////////////////////////////////

////////////////////////SETS INSERT FUNCTION//////////////////////////////////
  String urlSetDeleteFunction =
      "http://192.168.64.2/BlackBookVs/movil_setsDeleteRegistration_function.php";

  void _setsDeleteRegistration() async {
    http.post(urlSetDeleteFunction, body: {
      "id_reg": singleReg['id_reg'],
    }).then((response) {
      print(response.statusCode);
      if (response.body == "Set eliminated!") {
        setState(() {});
        Toast.show(response.body, context,
            backgroundColor: Colors.green[800],
            backgroundRadius: 5,
            gravity: Toast.CENTER,
            duration: Toast.LENGTH_LONG);
      } else {
        setState(() {});
        Toast.show('Set not eliminated', context,
            backgroundColor: Colors.red[800],
            backgroundRadius: 5,
            gravity: Toast.CENTER,
            duration: Toast.LENGTH_LONG);
      }
    }).catchError((error) {});
  }
///////////////////////////////////////////////////////////////////////////////

  @override
  void initState() {
    _fetchSetsRegistrationTable();
    super.initState();
  }

  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          gradient: new LinearGradient(
            colors: [const Color(0xFFE4E1E1), const Color(0xFF585656)],
            begin: FractionalOffset.topRight,
            end: FractionalOffset.bottomLeft,
            tileMode: TileMode.clamp,
          ),
        ),
        child: Column(
          children: <Widget>[
            Column(
              children: [
                SizedBox(height: 90),
                Center(
                  child: Text(
                    'Sets to register',
                    style: TextStyle(
                      fontFamily: 'Monserrat',
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
                SizedBox(height: 70),
                SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  physics: ClampingScrollPhysics(),
                  child: Container(
                    padding:
                        const EdgeInsets.only(left: 16, right: 16, top: 20),
                    child: jsonDataVsTemp != null
                        ? JsonTable(
                            jsonDataVsTemp,
                            tableHeaderBuilder: (String header) {
                              return Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 4.0, vertical: 2.0),
                                decoration: BoxDecoration(
                                    border: Border.all(width: 0.1),
                                    color: Colors.transparent),
                                child: Text(
                                  header,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline1
                                      .copyWith(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 11.0,
                                          color: Colors.white),
                                ),
                              );
                            },
                            tableCellBuilder: (value) {
                              return Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 4.0, vertical: 2.0),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 0.2,
                                        color: Colors.grey.withOpacity(0.5))),
                                child: Text(
                                  value,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline2
                                      .copyWith(
                                          fontSize: 11.0, color: Colors.white),
                                ),
                              );
                            },
                            columns: columns2,
                            showColumnToggle: false,
                            allowRowHighlight: true,
                            rowHighlightColor:
                                Colors.grey[400].withOpacity(0.7),
                            // paginationRowCount: 6,
                            onRowSelect: (index, map) {
                              print(index);
                              print(map);
                              showDialogAcceptDeleteSet(context);
                              setState(() {
                                singleReg = map;
                              });
                            },
                          )
                        : Container(
                            child: Center(
                              child: Text(
                                'No sets to register',
                                style: TextStyle(
                                  fontFamily: 'Monserrat',
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 60),
                FlatButton(
                  onPressed: () {
                    // Navigator.of(context).pop();
                    // Navigator.of(context).pushReplacement(
                    //   MaterialPageRoute(
                    //     builder: (context) => GameEntryPage(),
                    //   ),
                    // );
                    // Navigator.pushReplacementNamed(context, '/GameEntryPage');
                    Navigator.pushReplacementNamed(context, '/SideBarLayout');
                  },
                  child: Container(
                    height: 40,
                    width: 130,
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(5))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "Close",
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
              ],
            )
          ],
        ),
      );

  //////////////////////////////DIALOG FOR ACCEPT/DELETE SETS/////////////////////////
  void showDialogAcceptDeleteSet(BuildContext context) {
    Dialog acceptDeleteDialog = Dialog(
      backgroundColor: Colors.grey[500],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Container(
        // color: Colors.transparent,
        height: 100.0,
        width: 100.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(5.0),
              child: Text(
                'Accept?',
                style: TextStyle(color: Colors.white),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 5, right: 5, top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  FlatButton(
                    color: Colors.green,
                    onPressed: () {
                      _setsInsertRegistration();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => SetstoRegister(),
                        ),
                      );
                    },
                    child: Text(
                      'Register',
                      style: TextStyle(fontSize: 12.0, color: Colors.white),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  FlatButton(
                    color: Colors.red,
                    onPressed: () {
                      _setsDeleteRegistration();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => SetstoRegister(),
                        ),
                      );
                    },
                    child: Text(
                      'Delete',
                      style: TextStyle(fontSize: 12.0, color: Colors.white),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
    showDialog(
        context: context,
        builder: (BuildContext context) => acceptDeleteDialog);
  }
}
///////////////////////////////////////////////////////////////////////
