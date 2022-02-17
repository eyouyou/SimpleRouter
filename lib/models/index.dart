import 'package:flutter/material.dart';
import 'package:simple_route/models/simple_route.dart';
import 'component.dart';
export 'simple_route.dart';
export "component.dart";

typedef ComponentBuilder = Widget Function(BuildContext, RouteData);

/// 这里的path可能是相对路径或者绝对路径 配置层
class RouteComponent extends SimpleRoute {
  final Handler handler;
  RouteComponent(String path, this.handler,
      {List<RouteComponent>? initialChildren, Key? key})
      : super(path, initialChildren: initialChildren, key: key);

  /// 直接通过lambda获取当当前route
  Widget build(BuildContext context, RouteData data) {
    return handler.build(context, data);
  }
}

/// 后续handler需要处理认证相关逻辑
class Handler {
  final ComponentBuilder handlerFunc;
  Handler(this.handlerFunc);

  Widget build(BuildContext ctx, RouteData routeData) {
    return handlerFunc(ctx, routeData);
  }
}

extension SimpleRouteExtension on SimpleRoute {
  RouteComponent? toComponent() {
    return this as RouteComponent;
  }
}

abstract class RouteCollection {
  /// 获取当前集合的绝对路径
  String get path;
  int get length;

  /// 增加 [route] 到 [path] 下
  String? add(SimpleRoute route);

  /// 删除 [path] 下子节点
  void clearChildren(String path);

  List<SimpleRoute> get routes;

  /// 获得当前route的绝对路径
  String? getAbsolutePath(SimpleRoute route);

  /// 获得当前相对路径 [path] 对于 [prefix] 的相对路径
  String getRelativePath(String path, String prefix);
}
