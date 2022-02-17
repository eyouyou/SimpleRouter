import 'package:example/index.dart';
import 'package:example/pages/game_player.dart';
import 'package:example/pages/switch.dart';
import 'package:example/pages/home.dart';
import 'package:example/pages/pc.dart';
import 'package:example/pages/ps5.dart';
import 'package:flutter/material.dart';
import 'package:simple_route/models/index.dart';
import 'package:simple_route/routers/simple_router.dart';

void main() {
  runApp(const MyApp());
}

class Global {
  static final RootRouter route = RootRouter();
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AppState();
}

class _AppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Global.route.addRoute(RouteComponent(
          "users/:userId",
          Handler((ctx, routeData) =>
              Text(routeData.paramsAs<String>("userId") ?? ""))));

      Global.route.addRoute(RouteComponent(
          "home", Handler((ctx, routeData) => HomePage(data: routeData))));

      Global.route.addRoute(ExampleRoute(
        "home/game_player",
        Handler((ctx, routeData) => GamePlayerPage(data: routeData)),
        text: "主机游戏",
      ));

      Global.route.addRoute(ExampleRoute(
        "home/game_player/switch",
        Handler((ctx, routeData) => const SwitchPage()),
        text: "Switch",
      ));

      Global.route.addRoute(ExampleRoute(
        "home/game_player/ps5",
        Handler((ctx, routeData) => const Ps5Page()),
        text: "PS5",
      ));

      Global.route.addRoute(ExampleRoute(
        "home/computer",
        Handler((ctx, routeData) => const ComputerPage()),
        text: "电脑",
      ));

      Global.route.navigate("/home/game_player/ps5");
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerDelegate: Global.route.routerDelegate,
      routeInformationParser: Global.route.routingInformationParser,
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
    );
  }
}
