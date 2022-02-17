import 'package:flutter/material.dart';
import 'package:simple_route/routers/proxy.dart';
import 'package:simple_route/routers/simple_router.dart';
import 'package:simple_route/simple_route.dart';

/// 根节点
class RouterRoot extends RouterWidget {
  final RootRouter router;
  const RouterRoot({required this.router, Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RouterRootState();
}

class _RouterRootState extends State<RouterRoot> with RouterMixin<RouterRoot> {
  @override
  Widget buildRouter(BuildContext context) {
    return RootRouterScope(widget.router,
        child: Material(
            child: RouteProxyWidget(
          controller: widget.router.controller,
        )));
  }

  @override
  SimpleRouter get router => widget.router;
}

class RootRouterScope extends RouterControllerScope {
  final RootRouter root;

  const RootRouterScope(RootRouter router, {required Widget child, Key? key})
      : root = router,
        super(router, key: key, child: child);

  static RootRouterScope? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<RootRouterScope>();
  }
}

// class RouterCollectionProvider extends InheritedWidget {
//   final RouteCollection collection;
//   final RouteMatcher matcher;
//   const RouterCollectionProvider(this.collection, this.matcher,
//       {required Widget child, Key? key})
//       : super(key: key, child: child);

//   static RouterCollectionProvider? of(BuildContext context) {
//     return context
//         .dependOnInheritedWidgetOfExactType<RouterCollectionProvider>();
//   }

//   @override
//   bool updateShouldNotify(RouterCollectionProvider oldWidget) {
//     /// 如果引用变化 则重新绘制
//     return !identical(collection, oldWidget.collection);
//   }
// }
