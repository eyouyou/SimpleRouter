import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:simple_route/matcher/match.dart';
import 'index.dart';

/// 通过组件 进行build 由此派生各个
class RouteData {
  final RouteComponent component;

  /// 包含/:id 和&
  final Map<String, dynamic>? params;
  final Object? args;

  RouteData({
    required this.component,
    this.params,
    this.args,
  });

  Widget build() {
    return Builder(
      builder: (BuildContext context) {
        //通过该上下文  用户可以直接获取最近的路由信息
        return RouteDataProvider(this, child: component.build(context, this));
      },
    );
  }

  /// 从path出来的match 不应该有builder信息
  RouteData.fromMatch(RouteMatch match, RouteSettings settings)
      : component = match.route as RouteComponent,
        params = match.parameters,
        args = settings.arguments;

  RouteData.fromRoute(this.component, {this.params, this.args});

  T? argsAs<T>() {
    return args as T;
  }

  T? paramsAs<T>(String key) {
    var p = params;
    return p != null ? p[key] as T : null;
  }

  RouteData copyWith(
      {RouteComponent? component,
      SimpleRoute? route,
      Map<String, dynamic>? params,
      Object? args}) {
    return RouteData(
        component: component ?? this.component,
        params: params ?? this.params,
        args: this.args ?? args);
  }

  /// 如果 [component] 一样 则代表组件一样
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is RouteData && other.component == component;
  }

  /// 如果 [params] 变化 则内部不同
  bool equals(RouteData? other) {
    return other != null &&
        other == this &&
        mapEquals(other.params, params) &&
        other.args == args;
  }

  @override
  int get hashCode => component.hashCode;
}

/// 可以通过该provider 直接获取当前组件对应的route数据 或者在
class RouteDataProvider extends InheritedWidget {
  final RouteData data;

  static RouteDataProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<RouteDataProvider>();
  }

  const RouteDataProvider(this.data, {Key? key, required Widget child})
      : super(key: key, child: child);

  @override
  bool updateShouldNotify(RouteDataProvider oldWidget) {
    return !oldWidget.data.equals(data);
  }
}
