import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:json_table/json_table.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';
import '../bloc.navigation_bloc/navigation_bloc.dart';

class StatisticsPage extends StatefulWidget with NavigationStates {
  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  ProgressDialog pr; //PROGRESS DIALOG INSTANCE
  dynamic _selectedGame;

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
    return null;
    // print(dataSelectGame);
  }

////////////////////////////////////////////////////////////////////////////

////////////////////////FECTH TABLE PLAYER FUNCTION////////////////////////////
  String urlFetchStatisticsTableFunction =
      "http://192.168.64.2/BlackBookVs/movil_fetchStatisticsTable_function.php";
  var jsonDataVs;

  void _fetchTable() async {
    var sendData = await http.post(urlFetchStatisticsTableFunction, body: {
      "game": _selectedGame,
    });
    var response = json.decode(sendData.body);
    if (response.length == 0) {
      Toast.show('No records for this game', context,
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

//////////////////////////////////////////////////////////////////////////

/////////////////////////////VAR FOR TABLE COLUMNS/////////////////////////////
  var columns = [
    JsonTableColumn("rownum", label: "Position"),
    JsonTableColumn("email", label: "Player"),
    JsonTableColumn("efficiency", label: "Efficiency"),
    JsonTableColumn("total_partidas", label: "Total Plays"),
  ];
//////////////////////////////////////////////////////////////////////////////

  @override
  void initState() {
    _fetchSelectGame();
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Text(
              "Standings",
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
          ),
          Divider(color: Colors.white),
          SizedBox(height: 20),
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
                    style: new TextStyle(fontSize: 11, color: Colors.white),
                  ),
                  onChanged: (value) {
                    setState(
                      () {
                        _selectedGame = value;
                        print(_selectedGame);
                        _fetchTable();
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 30),
          Column(
            children: [
              if (jsonDataVs != null)
                JsonTable(
                  jsonDataVs,
                  tableHeaderBuilder: (String header) {
                    return Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                      decoration: BoxDecoration(
                          border: Border.all(width: 0.1),
                          color: Colors.transparent),
                      child: Text(
                        header,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headline1.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 11.0,
                            color: Colors.white),
                      ),
                    );
                  },
                  tableCellBuilder: (value) {
                    return Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                      decoration: BoxDecoration(
                          border: Border.all(
                              width: 0.2, color: Colors.grey.withOpacity(0.5))),
                      child: Text(
                        value,
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headline2
                            .copyWith(fontSize: 11.0, color: Colors.white),
                      ),
                    );
                  },
                  columns: columns,
                  showColumnToggle: false,
                  allowRowHighlight: true,
                  rowHighlightColor: Colors.grey[400].withOpacity(0.7),
                  paginationRowCount: 25,
                  onRowSelect: (index, map) {
                    print(index);
                    print(map);
                  },
                )
              else
                SizedBox(height: 30),
              Container(
                child: Center(
                  child: Text(
                    'Select a game for view standings',
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
    );
  }
}
