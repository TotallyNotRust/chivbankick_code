import 'package:clay_containers/clay_containers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:neumorphic_button/neumorphic_button.dart';
import 'package:radio_group_v2/radio_group_v2.dart';
import 'package:sprintf/sprintf.dart';

const int buttonWidth = 5;
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<List<String>> playerList = [];

  static final Map<String, String> commandTemplates = {
    'Ban': 'BanById %id %tim "%msg"',
    'Kick': 'KickByID %id "%msg"',
  };

  String chosenPlayerID = "";

  void calcBanString() {
    if (chosenPlayerID != "") {
      commandEditingController.text = commandTemplates[commandController.value]!
          .replaceAllMapped(RegExp(r"%\w*"), (match) {
        return {
              "%id": chosenPlayerID,
              "%msg": reasonEditingController.text,
              "%tim": hoursEditingController.text,
            }[match.group(0)!] ??
            'ERROR UNDEFINED';
      });
    } else {
      commandEditingController.text = "Please choose a player";
    }
  }

  void calcPlayerList() {
    playerList = [];
    for (String line in playersEditingController.text.split("\n")) {
      // If not empty
      if (line != "") {
        List lineContents = line.split(" - ");
        if (lineContents[0] == "ServerName" || lineContents[0] == "Name")
          continue;
        playerList.add([lineContents[0], lineContents[1]]);
      }
    }
    updateSearch();
  }

  void updateSearch() {
    String searchText = searchFieldEditingController.text;

    setState(() {
      if (searchText.isNotEmpty) {
        playerList.removeWhere((element) {
          return !RegExp(".*$searchText.*", caseSensitive: false)
              .hasMatch(element[0]);
        });
      }
    });
  }

  final TextEditingController commandEditingController =
      TextEditingController();
  final TextEditingController reasonEditingController = TextEditingController();
  final TextEditingController hoursEditingController = TextEditingController();
  final TextEditingController playersEditingController = TextEditingController();
  final TextEditingController searchFieldEditingController =
      TextEditingController();

  final RadioGroupController commandController = RadioGroupController();

  @override
  void initState() {
    commandEditingController.addListener(calcBanString);
    reasonEditingController.addListener(calcBanString);
    hoursEditingController.addListener(calcBanString);
    playersEditingController.addListener(calcPlayerList);
    searchFieldEditingController.addListener(updateSearch);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    calcBanString();
    calcPlayerList();
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
                    children: [
                      CupertinoTextField(
                        minLines: 1,
                        maxLines: 2,
                        placeholder: "listPlayers list",
                        onChanged: (text) {
                          if (text != "") {
                            setState(
                                () => playersEditingController.text = text);
                          }
                        },
                        controller: playersEditingController,
                      ),
                      const SizedBox(height: 10),
                      CupertinoTextField(
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
                      const SizedBox(height: 10),
                      const Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 8.0),
                            child: Text("Command"),
                          ),
                          Expanded(child: SizedBox()),
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          RadioGroup(
                            indexOfDefault: 0,
                            controller: commandController,
                            orientation: RadioGroupOrientation.horizontal,
                            onChanged: (choice) {
                              calcBanString();
                            },
                            values: const [
                              "Ban",
                              "Kick",
                            ],
                          ),
                          Expanded(child: Container()),
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
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
            for (int x = 0; x <= (playerList.length / buttonWidth).floor(); x++)
              SliverToBoxAdapter(
                child: Row(children: [
                  for (int y = 0; y < buttonWidth; y++)
                    if (playerList.asMap().containsKey((x * 5) + y))
                      NeumorphicButton(
                        topLeftShadowColor: Colors.grey.shade500,
                        bottomRightShadowColor: Colors.grey.shade500,
                        backgroundColor: Colors.grey.shade300,
                        height: 50,
                        width:
                            (MediaQuery.of(context).size.width / buttonWidth) -
                                10,
                        child: Center(child: Text(playerList[x * 5 + y][0])),
                        onTap: () => setState(
                            () => chosenPlayerID = playerList[x * 5 + y][1]),
                      ),
                ]),
              ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 40,
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: NeumorphicContainer(
        child: SizedBox(
          height: 80,
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 150,
                    child: CupertinoTextField(
                      controller: commandEditingController,
                      readOnly: true,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  Expanded(
                    child: SizedBox(),
                  ),
                  NeumorphicButton(
                      width: 120,
                      height: 50,
                      child: Center(child: Text("Copy")),
                      backgroundColor: Colors.grey.shade500,
                      bottomRightShadowColor: Colors.grey.shade500,
                      topLeftShadowColor: Colors.grey.shade300,
                      onTap: () {
                        Clipboard.setData(
                            ClipboardData(text: commandEditingController.text));
                      },
                    ),
                ],
              ),
              Center(child: Text("© GoonLord420"),)
            ],
          ),
        ),
      ),
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
