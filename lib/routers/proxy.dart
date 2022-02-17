import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:simple_route/models/index.dart';

class RouteProxyWidget extends StatefulWidget {
  final RouteProxyController controller;
  final Widget? fallback;
  const RouteProxyWidget({Key? key, required this.controller, this.fallback})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _RouteProxyWidgetState();
}

class _RouteProxyWidgetState extends State<RouteProxyWidget> {
  final Map<SimpleRoute, Widget> _widgets = <SimpleRoute, Widget>{};

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RouteProxyController>.value(
      value: widget.controller,
      builder: (ctx1, _) {
        var controller = ctx1.watch<RouteProxyController>();
        return ChangeNotifierProvider<IndexedController>.value(
          value: controller._indexedController,
          builder: (ctx2, _) {
            var index = ctx2.watch<IndexedController>().currentIndex;
            var component = controller.currentComponent;
            if (component != null) {
              _widgets[component.component] = component.build();
            } else {
              return widget.fallback ?? Container();
            }
            var list = _widgets.values.toList();
            return IndexedStack(children: list, index: index);
          },
        );
      },
    );
  }
}

class RouteProxyController extends ChangeNotifier {
  final IndexedController _indexedController;
  final Map<RouteComponent, int> _routes = <RouteComponent, int>{};

  RouteProxyController({int? initial})
      : _indexedController = IndexedController(initial);

  RouteData? _current;
  RouteData? get currentComponent => _current;

  set routeData(RouteData value) {
    if (!value.equals(_current)) {
      _current = value;
      var currentRoute = value.component;
      if (_routes.containsKey(currentRoute)) {
        _indexedController.index = _routes[currentRoute]!;
      } else {
        var index = _routes.length;
        _routes[value.component] = index;
        _indexedController.index = index;

        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _indexedController.dispose();
  }
}

class IndexedController extends ChangeNotifier {
  final int? initial;
  IndexedController(this.initial) : _currentIndex = initial ?? 0;

  int _currentIndex;

  int get currentIndex => _currentIndex;

  set index(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      notifyListeners();
    }
  }
}
