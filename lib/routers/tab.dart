import 'package:flutter/material.dart';
import 'package:simple_route/models/index.dart';
import 'package:simple_route/matcher/index.dart';
import 'package:simple_route/routers/simple_router.dart';

/// 可以通过改router 自定义tabwidget
class TabRouter extends SimpleRouter with LayerRouter {
  /// 外部给入
  final TabController controller;
  final RouterLayerCollection _collection;
  TabRouter(RouterLayerCollection collection, RouteComponent component,
      this.controller)
      : _collection = collection,
        super(component);

  @override
  RouteCollection get collection => _collection;

  @override
  RouteMatcher get routeMatcher => _collection;

  @override
  void switchRoute(RouteMatch match, {Object? arguments}) {
    var index = _collection.indexOf(match.route);
    if (index >= 0) {
      controller.index = index;
    }
  }
}
