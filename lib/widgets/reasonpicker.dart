import 'package:flutter/material.dart';

class ReasonPicker extends StatelessWidget {
  const ReasonPicker({super.key, required this.reasonCallback});

  final Function(String) reasonCallback;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: PopupMenuButton<String>(
        icon: const Icon(Icons.menu), // Use the same icon as DropdownButton
        onSelected: (value) {
          reasonCallback(value);
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value:
                "FFA is not allowed. Flourish to start a duel. Get more info at discord.gg/sakclan.",
            child: Text("FFA"),
          ),
          const PopupMenuItem(
            value:
                "Cheating is not allowed. Get more info at discord.gg/sakclan.",
            child: Text("Cheating"),
          ),
          const PopupMenuItem(
            value:
                "Suspected affiliate of a banned group. Get more info at discord.gg/sakclan.",
            child: Text("Banned group"),
          ),
        ],
      ),
    );
  }
}
