import 'package:flutter/material.dart';
import 'package:simple_route/routers/root.dart';
import 'package:simple_route/routers/simple_router.dart';

class SimpleRouterDelegate extends RouterDelegate<String>
    with PopNavigatorRouterDelegateMixin<String>, ChangeNotifier {
  final RootRouter router;
  SimpleRouterDelegate(this.router);
  @override
  Widget build(BuildContext context) {
    return RouterRoot(router: router);
  }

  @override
  GlobalKey<NavigatorState>? get navigatorKey => GlobalKey<NavigatorState>();

  @override
  Future<void> setNewRoutePath(String configuration) async {
    await Future.delayed(const Duration(milliseconds: 1000));
  }
}

class SimpleRouteInformationParser extends RouteInformationParser<String> {
  final RootRouter router;
  SimpleRouteInformationParser(this.router);

  @override
  Future<String> parseRouteInformation(
      RouteInformation routeInformation) async {
    return router.collection.path;
  }
}
