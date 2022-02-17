import 'package:flutter/material.dart';

import '../main.dart';

class ComputerPage extends StatelessWidget {
  const ComputerPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      const Text("电脑游戏"),
      ElevatedButton(
          onPressed: () {
            Global.route.navigate("/home/game_player/ps5");
          },
          child: const Text("to ps5"))
    ]);
  }
}
