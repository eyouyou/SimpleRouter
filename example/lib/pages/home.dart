import 'package:flutter/material.dart';
import 'package:simple_route/models/component.dart';

import '../layouts/tab_view.dart';

class HomePage extends StatelessWidget {
  final RouteData data;
  const HomePage({Key? key, required this.data}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return TabViewRouter(data.component);
  }
}
