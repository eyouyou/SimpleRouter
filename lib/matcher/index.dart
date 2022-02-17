import 'match.dart';
export 'match.dart';
export 'default.dart';

/// 没有基础匹配逻辑
mixin RouteMatcher {
  QueryStringParser get queryStringParser;

  /// 匹配当前层包含的route
  RouteMatch? match(String path);
}

abstract class QueryStringParser {
  String parseToString(Map<String, dynamic> queries);
  Map<String, dynamic>? parseToQueries(String queryString);
}
