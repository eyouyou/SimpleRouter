export 'tab.dart';

import 'package:flutter/material.dart';
import 'package:simple_route/routers/simple_router.dart';

import '../matcher/index.dart';
import '../models/index.dart';
import 'root.dart';

abstract class RouterWidget extends StatefulWidget {
  const RouterWidget({Key? key}) : super(key: key);
}

/// 提供给子路由器进行注册等操作
/// 从上一个路由器获得当前的路径
class RouterControllerScope extends InheritedWidget {
  final SimpleRouter router;
  const RouterControllerScope(this.router, {required Widget child, Key? key})
      : super(key: key, child: child);

  static RouterControllerScope? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<RouterControllerScope>();
  }

  @override
  bool updateShouldNotify(RouterControllerScope oldWidget) {
    /// 如果router中的孩子或者他本身发生变化 则进行重绘
    return oldWidget.router != router;
  }
}

mixin RouterMixin<T extends RouterWidget> on State<T> {
  SimpleRouter get router;
  RouterControllerScope? parent;

  /// 必须在router准备好之后进行调用
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    parent = RouterControllerScope.of(context);
    try {
      /// 试错
      var _ = router;
    } catch (e) {
      throw Exception("调用 [didChangeDependencies] 之前 router 必须初始化");
    }

    parent?.router.lazyLoad(router);
    parent?.router.detachSubController(router);
    parent?.router.attachSubController(router);
  }

  /// router生成
  Widget buildRouter(BuildContext context);

  RouterLayerCollection getCollection(
      BuildContext context, RouteComponent component) {
    var scope = RootRouterScope.of(context);
    assert(scope != null, "[RootRouterScope] not found");
    var root = scope!.root;

    var parent = RouterControllerScope.of(context);
    var path = root.collection.path;
    if (parent != null) {
      var absolutePath = parent.router.collection.getAbsolutePath(component);
      assert(absolutePath != null, "route not found in parent collection");
      path = absolutePath!;
    }

    return root.getLayerCollection(path);
  }

  @override
  Widget build(BuildContext context) {
    return RouterControllerScope(router,
        child: Material(child: buildRouter(context)));
  }

  @override
  void dispose() {
    super.dispose();
    parent?.router.detachSubController(router);
  }
}
