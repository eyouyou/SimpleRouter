import 'package:simple_route/simple_route.dart';

class ExampleRoute extends RouteComponent {
  ExampleRoute(String path, Handler handler, {this.text = ""})
      : super(path, handler);

  final String text;
}

extension ExampleRouteEx on SimpleRoute {
  ExampleRoute asAppRoute() {
    return this as ExampleRoute;
  }
}
