import 'package:flutter/widgets.dart';
import 'package:simple_route/models/component.dart';

import '../layouts/tab_view.dart';

class GamePlayerPage extends StatelessWidget {
  final RouteData data;
  const GamePlayerPage({Key? key, required this.data}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return TabViewRouter(data.component);
  }
}
