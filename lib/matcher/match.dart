import 'package:simple_route/models/simple_route.dart';

class RouteMatch {
  // constructors
  RouteMatch(this.route, this.path);

  /// 干啥用比较好？
  final String path;

  /// 当前路由配置
  final SimpleRoute route;

  final Map<String, dynamic> parameters = <String, dynamic>{};

  RouteMatch copyWith(
      {SimpleRoute? route, String? path, Map<String, dynamic>? parameters}) {
    var match = RouteMatch(route ?? this.route, path ?? this.path);
    match.parameters.addAll(parameters ?? this.parameters);
    return match;
  }
}
