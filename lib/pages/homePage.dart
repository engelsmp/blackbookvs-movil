import 'dart:convert';
import 'package:toast/toast.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../loginPage.dart' show userMail;
import 'package:pie_chart/pie_chart.dart';
import 'package:json_table/json_table.dart';
import 'package:progress_dialog/progress_dialog.dart';
import '../bloc.navigation_bloc/navigation_bloc.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;

class HomePage extends StatefulWidget with NavigationStates {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ProgressDialog pr; //PROGRESS DIALOG INSTANCE
  bool _canShowSelectDate = true; //BOOL FOR SHOW/HIDE SELECTDATE LABEL
  var userWins;
  var userLosses;
  var userEfficiency;
  var _selectedPlayer;
  var _firstDateSelected;
  var _lastDateSelected;

  String urlFetchGraphFunction =
      "http://192.168.64.2/BlackBookVs/movil_fetchGraph_function.php";

///////////////////////FETCH MENUPAGE FUNCTION////////////////////////////
  Future<List> _fetchGraphFunction() async {
    await Future.delayed(Duration(seconds: 2));
    final dataMenuPage = await http.post(urlFetchGraphFunction, body: {
      "email": userMail,
    });
    var dataUser = json.decode(dataMenuPage.body);
    if (userMail != null) {
      setState(() {
        userWins = dataUser[0]['value_sum1'] is String
            ? double.parse(dataUser[0]['value_sum1'])
            : dataUser[1]['value_sum1'];
        userLosses = dataUser[1]['value_sum2'] is String
            ? double.parse(dataUser[1]['value_sum2'])
            : dataUser[1]['value_sum2'];
        userEfficiency = dataUser[2]['efficiency'];
////////////////////PIE CHART DATA////////////////////////////////////////////
        dataMap1.putIfAbsent("Wins", () => userWins == null ? 0 : userWins);
        dataMap1.putIfAbsent(
            "Losses", () => userLosses == null ? 0 : userLosses);
        dataMap1.putIfAbsent("Efficiency", () => 0);
//////////////////////////////////////////////////////////////////////////////
      });
      print(userWins);
      print(userLosses);
      print(userEfficiency);
    }
    return dataUser;
  }
////////////////////////////////////////////////////////////////////////////

////////////////////////FECTH TABLE PLAYER FUNCTION////////////////////////////
  String urlFetchTableFunction =
      "http://192.168.64.2/BlackBookVs/movil_fetchDashboardTable_function.php";
  var jsonDataVs;

  void _fetchTable() async {
    if (_selectedPlayer == null) {
      Toast.show('Choose a player', context,
          backgroundColor: Colors.red[800],
          backgroundRadius: 5,
          gravity: Toast.CENTER,
          duration: Toast.LENGTH_LONG);
    } else if (_firstDateSelected == null) {
      Toast.show('Pick a date', context,
          backgroundColor: Colors.red[800],
          backgroundRadius: 5,
          gravity: Toast.CENTER,
          duration: Toast.LENGTH_LONG);
    } else {
      var sendData = await http.post(urlFetchTableFunction, body: {
        "player1": userMail,
        "player2": _selectedPlayer,
        "date_start": _firstDateSelected.toString(),
        "date_end": _lastDateSelected.toString(),
      });
      var response = json.decode(sendData.body);
      if (response.length == 0) {
        Toast.show('No records with this player on those dates', context,
            backgroundColor: Colors.red[800],
            backgroundRadius: 5,
            gravity: Toast.CENTER,
            duration: Toast.LENGTH_LONG);
      } else {
        setState(() {
          jsonDataVs = response;
        });
        Toast.show('Loading Table', context,
            backgroundColor: Colors.green[800],
            backgroundRadius: 5,
            gravity: Toast.CENTER,
            duration: Toast.LENGTH_LONG);
        // print(response);
      }
    }
  }

//////////////////////////////////////////////////////////////////////////

////////////////////////PIE CHARTS BAR COLORS///////////////////////////////
  Map<String, double> dataMap = new Map();
  List<Color> colorList = [
    Colors.green[800],
    Colors.red[800],
    Colors.blue[800],
  ];
////////////////////////////////////////////////////////////////////////////

  Map<String, double> dataMap1 = new Map();
  List<Color> colorList1 = [
    Colors.green[800],
    Colors.red[800],
    Colors.blue[800],
  ];

////////////////////////FECTH SELECT PLAYER FUNCTION////////////////////////////
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
    return null;
  }
//////////////////////////////////////////////////////////////////////////

/////////////////////////////VAR FOR TABLE COLUMNS/////////////////////////////
  var columns1 = [
    JsonTableColumn("fecha", label: "Date"),
    JsonTableColumn("player1", label: "Player1"),
    JsonTableColumn("wins", label: "Wins"),
    JsonTableColumn("player2", label: "Player2"),
    JsonTableColumn("loses", label: "Wins"),
    JsonTableColumn("game", label: "Game"),
  ];
//////////////////////////////////////////////////////////////////////////

  @override
  void initState() {
    _fetchSelectPlayer();
    _fetchGraphFunction();
    // print(countSets);
    // _fetchSetsRegistrationTable();
    super.initState();
    print(userWins);
    print(userLosses);
    print(userEfficiency);
////////////////////PIE CHART DATA////////////////////////////////////////////
    dataMap.putIfAbsent("Wins", () => 0);
    dataMap.putIfAbsent("Losses", () => 0);
    dataMap.putIfAbsent("Efficiency", () => 0);
//////////////////////////////////////////////////////////////////////////////
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Text(
              "Home Page",
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
          ),

          Divider(color: Colors.white),
          Container(
            height: 250,
            child: Center(
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      child: Stack(
                        children: <Widget>[
                          Align(
                            // left: 112,
                            alignment: Alignment.center,
                            child: Container(
                              // height: 0,
                              width: 170,
                              child: Text(
                                userEfficiency == null
                                    ? 'O %'
                                    : '${userEfficiency.toString()}'
                                            .split('.')[0] +
                                        '%',
                                style: TextStyle(
                                  fontSize: 40,
                                  color: Colors.blue[800],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            child: PieChart(
                              dataMap: dataMap1.isNotEmpty ? dataMap1 : dataMap,
                              animationDuration: Duration(milliseconds: 5000),
                              chartLegendSpacing: 30.0,
                              chartRadius:
                                  MediaQuery.of(context).size.width / 0.5,
                              showChartValuesInPercentage: false,
                              showChartValues: true,
                              showChartValuesOutside: false,
                              chartValueBackgroundColor: Colors.transparent,
                              colorList: colorList,
                              showLegends: true,
                              legendPosition: LegendPosition.right,
                              legendStyle: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              decimalPlaces: 0,
                              showChartValueLabel: true,
                              initialAngle: 100,
                              chartValueStyle: defaultChartValueStyle.copyWith(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 20,
                              ),
                              chartType: ChartType.ring,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 40),
          Divider(
            color: Colors.white,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                "Recent Games",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              IconButton(
                icon: Icon(Icons.search, color: Colors.white),
                tooltip: 'Search recent games',
                onPressed: () {
                  _fetchTable();
                  pr.show();
                  Future.delayed(Duration(seconds: 3)).then((value) {
                    pr.hide().whenComplete(() {});
                  });
                },
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(width: 18),
              Expanded(
                child: SearchableDropdown(
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
                            Icons.person,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                        TextSpan(
                          text: " Player",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  items: dataSelectPlayer.map((item) {
                    return DropdownMenuItem(
                      child: Text(
                        item['email'],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      // value: item);
                      value: item['email'],
                    );
                  }).toList(),
                  menuBackgroundColor: Colors.grey[800],
                  isExpanded: true,
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: Colors.transparent,
                  ),
                  underline: SizedBox(),
                  value: _selectedPlayer,
                  isCaseSensitiveSearch: false,
                  searchHint: new Text(
                    'SELECT PLAYER',
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
              _canShowSelectDate
                  ? Expanded(
                      child: Theme(
                      data: ThemeData.dark(),
                      child: Builder(
                        builder: (context) => FlatButton(
                          onPressed: () async {
                            _canShowSelectDate = !_canShowSelectDate;
                            final List<DateTime> picked =
                                await DateRagePicker.showDatePicker(
                              context: context,
                              initialFirstDate: new DateTime.now(),
                              initialLastDate: (new DateTime.now())
                                  .add(new Duration(days: 1)),
                              firstDate: new DateTime(2020),
                              lastDate: new DateTime(2099),
                            );
                            if (picked != null && picked.length == 2) {
                              setState(() {
                                _firstDateSelected = picked.first;
                                _lastDateSelected = picked.last;
                              });
                            }
                            print(_firstDateSelected);
                            print(_lastDateSelected);
                          },
                          child: RichText(
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
                                  text: " Dates",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ))
                  : Expanded(
                      child: Theme(
                        data: ThemeData.dark(),
                        child: Builder(
                          builder: (context) => FlatButton(
                            onPressed: () async {
                              // _canShowSelectDate = !_canShowSelectDate;
                              final List<DateTime> picked =
                                  await DateRagePicker.showDatePicker(
                                context: context,
                                initialFirstDate: new DateTime.now(),
                                initialLastDate: (new DateTime.now())
                                    .add(new Duration(days: 7)),
                                firstDate: new DateTime(2020),
                                lastDate: new DateTime(2099),
                              );
                              if (picked != null && picked.length == 2) {
                                setState(() {
                                  _firstDateSelected = picked.first;
                                  _lastDateSelected = picked.last;
                                });
                              }
                              print(_firstDateSelected);
                              print(_lastDateSelected);
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  _firstDateSelected == null
                                      ? 'No Date'
                                      : '${_firstDateSelected.toString()}'
                                          .split(' ')[0],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                  ),
                                ),
                                Text(
                                  _lastDateSelected == null
                                      ? 'No Date'
                                      : '${_lastDateSelected.toString()}'
                                          .split(' ')[0],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
            ],
          ),
          Column(
            children: <Widget>[
              Column(
                children: [
                  jsonDataVs != null
                      ? JsonTable(
                          jsonDataVs,
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
                          columns: columns1,
                          showColumnToggle: false,
                          allowRowHighlight: true,
                          rowHighlightColor: Colors.grey[400].withOpacity(0.7),
                          paginationRowCount: 6,
                          onRowSelect: (index, map) {
                            print(index);
                            print(map);
                          },
                        )
                      : SizedBox(
                          height: 20,
                        ),
                  Container(
                    child: Center(
                      child: Text(
                        'Select Player and Dates to search your recent games',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
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
          // ),
          SizedBox(height: 20.0),
        ],
      ),
    );
  }
}
