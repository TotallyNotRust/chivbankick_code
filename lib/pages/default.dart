import 'dart:async';

import 'package:chivbankick/models/user.dart';
import 'package:chivbankick/utils/apistuff.dart';
import 'package:chivbankick/widgets/playerbutton.dart';
import 'package:chivbankick/widgets/reasonpicker.dart';
import 'package:chivbankick/widgets/spinner.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/utils.dart';

const int buttonWidth = 5;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<List<String>> playerList = [];

  static final Map<String, String> commandTemplates = {
    'Ban': 'BanById %id %tim "%msg"',
    'Unban': 'UnbanId %id %tim "%msg"',
    'Kick': 'KickByID %id "%msg"',
    'Serversay': 'ServerSay "%say"',
    'Adminsay': 'Adminsay "%say"',
  };

  String lastValidInput = "";

  /*
  "Execute" a command, will automatically format a command, tab into Chivalry, and paste it.
  Some commands that may be less dangorous, like Serversay, can be auto executed by setting `autoExecute` to true
  */
  void executeCommand(String commandId,
      {String? playerId, bool autoExecute = false}) {
    String command =
        commandTemplates[commandId]!.replaceAllMapped(RegExp(r"%\w*"), (match) {
      return {
            "%id": playerId,
            "%msg": reasonEditingController.text,
            "%tim": hoursEditingController.text,
            "%say": serverAdminSayEditingController.text,
          }[match.group(0)!] ??
          'ERROR UNDEFINED';
    });
    Clipboard.setData(ClipboardData(text: command));
    Utils.paste(run: autoExecute);
  }

  void calcPlayerList(String text) {
    List<List<String>> _playerList = [];
    var lines = text.split("\n");
    if (!lines.first.contains("ServerName")) {
      if (lastValidInput != "") {
        text = lastValidInput;
      } else {
        return; // Dont update if a playerlisit is not in the clipboard
      }
    }
    lastValidInput = text;
    for (String line in text.split("\n")) {
      // If not empty
      if (line != "") {
        List lineContents = line.split(" - ");
        if (lineContents.length == 6) {
          if (lineContents[0] != "ServerName" && lineContents[0] != "Name") {
            _playerList.add([lineContents[0], lineContents[1]]);
          }
        }
      }
    }
    if (_playerList.isNotEmpty) {
      playerList = _playerList;
      print("Updating playerlist, new count: ${playerList.length}");
    }
    updateSearch();
  }

  void updateSearch() {
    String searchText = searchFieldEditingController.text;
    print("Updating search to '$searchText'");

    setState(() {
      if (searchText.isNotEmpty) {
        playerList.removeWhere((element) {
          return !RegExp(".*$searchText.*", caseSensitive: false)
              .hasMatch(element[0]);
        });
      }
    });
  }

  void updateReason(String reason) {
    reasonEditingController.text = reason;
  }

  final TextEditingController reasonEditingController = TextEditingController();
  final TextEditingController hoursEditingController = TextEditingController();
  final TextEditingController serverAdminSayEditingController =
      TextEditingController();
  final TextEditingController unbanEditingController = TextEditingController();
  final TextEditingController searchFieldEditingController =
      TextEditingController();

  @override
  void initState() {
    searchFieldEditingController.addListener(updateSearch);

    Timer.periodic(Duration(seconds: 1), (timer) async {
      ClipboardData? data;
      try {
        data = await Clipboard.getData(Clipboard.kTextPlain);
      } catch(_) {
        return;
      }
      if (data == null || data.text == null) return;

      calcPlayerList(data.text!);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CustomScrollView(
          // mainAxisAlignment: MainAxisAlignment.center,
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: NeumorphicContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          SizedBox(
                            width: 600,
                            child: CupertinoTextField(
                              placeholder: "Search",
                              minLines: 1,
                              maxLines: 2,
                              onChanged: (text) {
                                if (text != "") {
                                  setState(
                                      () => searchFieldEditingController.text = text);
                                }
                              },
                              controller: searchFieldEditingController,
                            ),
                          ),
                          const Expanded(child: SizedBox()),
                          IconButton(onPressed: () {}, icon: Icon(Icons.settings))
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Row(
                        children: [
                          SizedBox(
                            width: 50,
                            child: Text("Hours"),
                          ),
                          SizedBox(width: 10),
                          SizedBox(
                            width: 500,
                            child: Text("Reason"),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 50,
                            child: CupertinoTextField(
                              controller: hoursEditingController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 500,
                            child: CupertinoTextField(
                              controller: reasonEditingController,
                            ),
                          ),
                          ReasonPicker(reasonCallback: updateReason),
                          const Expanded(child: SizedBox()),
                          if (ApiStuff.userFetchCount > 1) 
                            Text("${ApiStuff.userFetchCount}/20")
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
            for (int x = 0; x <= (playerList.length / buttonWidth).floor(); x++)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: Row(children: [
                    for (int y = 0; y < buttonWidth; y++)
                      if (playerList.asMap().containsKey((x * 5) + y))
                        PlayersButton(
                          playerName: playerList[x * 5 + y][0],
                          playerID: playerList[x * 5 + y][1],
                          callBack: executeCommand,
                        )
                  ]),
                ),
              ),
            const SliverToBoxAdapter(
              child: SizedBox(
                height: 40,
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: NeumorphicContainer(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
              height: 40,
              width: MediaQuery.of(context).size.width,
              child: Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 2 > 500
                        ? 500
                        : MediaQuery.of(context).size.width / 2,
                    child: CupertinoTextField(
                      placeholder: "Say",
                      minLines: 1,
                      onChanged: (text) {
                        if (text != "") {
                          setState(() =>
                              serverAdminSayEditingController.text = text);
                        }
                      },
                      controller: serverAdminSayEditingController,
                    ),
                  ),
                  Text("  As: "),
                  IconButton(
                    onPressed: () {
                      executeCommand("Adminsay", autoExecute: true);
                    },
                    icon: Icon(Icons.local_police),
                    tooltip: "Admin Say",
                  ),
                  IconButton(
                    onPressed: () {
                      executeCommand("Serversay", autoExecute: true);
                    },
                    icon: Icon(Icons.computer),
                    tooltip: "Server Say",
                  ),
                ],
              )),
          SizedBox(
              height: 40,
              width: MediaQuery.of(context).size.width,
              child: Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 2 > 500
                        ? 500
                        : MediaQuery.of(context).size.width / 2,
                    child: CupertinoTextField(
                      placeholder: "Id to unban",
                      minLines: 1,
                      onChanged: (text) {
                        if (text != "") {
                          setState(() => unbanEditingController.text = text);
                        }
                      },
                      controller: unbanEditingController,
                    ),
                  ),
                  SizedBox(
                    width: 30,
                  ),
                  IconButton(
                    onPressed: () {
                      executeCommand("Unban",
                          playerId: unbanEditingController.text);
                    },
                    icon: Icon(Icons.person_add),
                    tooltip: "Unban",
                  ),
                ],
              )),
          const SizedBox(
            height: 20,
            child: Center(
              child: Text("© GoonLord420"),
            ),
          ),
        ],
      )),
    );
  }
}

class NeumorphicContainer extends StatelessWidget {
  const NeumorphicContainer(
      {super.key, required this.child, this.borderRadius});

  final Widget child;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(borderRadius ?? 10.0)),
        color: Colors.grey.shade300,
        boxShadow: [
          //bottomRightShadowProperties
          BoxShadow(
            color: Colors.grey.shade500,
            offset: const Offset(2, 2),
            blurRadius: 15,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.grey.shade500,
            offset: const Offset(-2, -2),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: child,
      ),
    );
  }
}

