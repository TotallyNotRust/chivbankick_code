import 'package:chivbankick/pages/default.dart';
import 'package:chivbankick/utils/apistuff.dart';
import 'package:chivbankick/widgets/spinner.dart';
import 'package:flutter/material.dart';

class PlayersButton extends StatelessWidget {
  const PlayersButton(
      {super.key,
      required this.playerName,
      required this.playerID,
      required this.callBack});
  final String playerName;
  final String playerID;
  final void Function(String, {String? playerId, bool autoExecute}) callBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        NeumorphicContainer(
          child: GestureDetector(
            onTap: () async {
              await showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text(playerName),
                      content: FutureBuilder(
                        future: ApiStuff.fetchUser(playerID),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return SizedBox(
                              height: 20,
                              width: 100,
                              child: const Spinner(),
                            );
                          }

                          if (snapshot.data == null) return Text("Rate limit exceeded, please try again later");
                          
                          return SizedBox(
                            width: 100,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  "Known aliases:",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(snapshot.data!.aliasHistoryRaw),
                              ],
                            ),
                          );
                        },
                      ),
                      actions: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text("Ok"),
                        ),
                      ],
                    );
                  });
            },
            child: SizedBox(
              width: (MediaQuery.of(context).size.width / buttonWidth) - 25.0,
              child: Row(
                children: [
                  Expanded(child: Text(playerName)),
                  IconButton(
                      onPressed: () {
                        callBack('Ban', playerId: playerID);
                      },
                      icon: Icon(Icons.person_remove)),
                  IconButton(
                      onPressed: () {
                        callBack('Kick', playerId: playerID);
                      },
                      icon: Icon(Icons.sports_martial_arts))
                ],
              ),
            ),
          ),
        ),
        SizedBox(
          width: 5,
        )
      ],
    );
  }
}
