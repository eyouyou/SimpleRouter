import 'package:path/path.dart' as p;
import 'package:simple_route/simple_route.dart';

class DefaultQueryStringParser extends QueryStringParser {
  static const String intTag = "int!";
  static const String boolTag = "bool!";
  static const String stringTag = "string!";

  static RegExp search = RegExp('([^&=]+)=?([^&]*)');
  static decode(String s) => Uri.decodeComponent(s.replaceAll('+', ' '));

  @override
  Map<String, dynamic>? parseToQueries(String queryString) {
    var params = <String, dynamic>{};
    if (queryString.startsWith('?')) queryString = queryString.substring(1);
    for (Match match in search.allMatches(queryString)) {
      var matchKey = match.group(1);
      var matchValue = match.group(2);
      if (matchKey != null && matchValue != null) {
        String key = decode(matchKey);
        String value = decode(matchValue);
        if (value.startsWith(intTag)) {
          value = value.replaceFirst(RegExp(intTag), '');
          params[key] = int.parse(value);
        } else if (value.startsWith(boolTag)) {
          value = value.replaceFirst(RegExp(boolTag), '');
          params[key] = value.toLowerCase() == "true";
        } else {
          params[key] = value;
        }
      }
    }
    return params;
  }

  @override
  String parseToString(Map<String, dynamic> queries) {
    if (queries.isEmpty) return "";
    var queryString = "";
    if (queries.entries.isNotEmpty) {
      StringBuffer queryStringBuffer = StringBuffer();
      queries.forEach((key, value) {
        var temp = value;
        if (value is int) {
          temp = "$intTag$value";
        } else if (value is bool) {
          temp = "$boolTag$value";
        }
        queryStringBuffer
            .write("$key=${Uri.encodeComponent(temp.toString())}&");
      });
      queryString = queryStringBuffer.toString();
      var index = queryString.lastIndexOf("&");
      if (index > 0) {
        queryString = queryString.replaceRange(index, index + 1, "");
      }
    }
    return queryString;
  }
}

/// A [RouteTreeNote] type
enum RouteTreeNodeType {
  component,
  parameter,
}

/// A node on [RouteTree]
class RouteTreeNode {
  // constructors
  RouteTreeNode(this.part, this.type);

  // properties
  final String part;
  final RouteTreeNodeType type;

  /// 防止引用被修改
  final List<SimpleRoute> routes = <SimpleRoute>[];
  final ObservableList<RouteTreeNode> nodes = ObservableList(<RouteTreeNode>[]);
  RouteTreeNode? parent;

  bool isParameter() {
    return type == RouteTreeNodeType.parameter;
  }
}

/// A matched [RouteTreeNode]
class RouteTreeNodeMatch {
  // constructors
  RouteTreeNodeMatch(this.node);

  RouteTreeNodeMatch.fromMatch(RouteTreeNodeMatch? match, this.node) {
    parameters = <String, dynamic>{};
    if (match != null) {
      parameters.addAll(match.parameters);
    }
  }

  // properties
  RouteTreeNode node;
  Map<String, dynamic> parameters = <String, dynamic>{};
}

// /// route列表 替代
// class Routes {
//   final List<SimpleRoute> routes = <SimpleRoute>[];

//   RouteCollection.from
// }

/// /users/:id/story?qwe=1&w=12
class RouteTree extends RouteCollection with RouteMatcher {
  final QueryStringParser _queryStringParser = DefaultQueryStringParser();
  late final String _path;

  /// 为了方便根路由从构造函数中传入
  RouteTree(SimpleRoute root) {
    var path = p.normalize(root.path);
    // is root/default route, just add it
    assert(path == p.separator, "必须为根路径");

    var node = RouteTreeNode(path, RouteTreeNodeType.component);
    node.routes.add(root);
    _nodes.add(node);
    _path = path;
    _routes[root] = path;
  }

  @override
  QueryStringParser get queryStringParser => _queryStringParser;

  final ObservableList<RouteTreeNode> _nodes =
      ObservableList(<RouteTreeNode>[]);

  final Map<SimpleRoute, String> _routes = {};
  @override
  RouteMatch? match(String path) {
    var usePath = p.normalize(path);

    assert(p.isAbsolute(usePath));

    return _match(usePath, _nodes.list, untilFindRoute: true);
  }

  RouteMatch? matchAll(String path) {
    return _match(path, _nodes.list);
  }

  RouteMatch? _match(String path, List<RouteTreeNode> nodes,
      {bool untilFindRoute = false}) {
    var components = p.split(path);

    var nodeMatches = <RouteTreeNode, RouteTreeNodeMatch>{};
    var nodesToCheck = nodes;

    var nodePath = <String>[];

    for (final checkComponent in components) {
      final currentMatches = <RouteTreeNode, RouteTreeNodeMatch>{};
      final nextNodes = <RouteTreeNode>[];

      var pathPart = checkComponent;
      Map<String, dynamic>? queryMap;

      if (checkComponent.contains("?")) {
        var splitParam = checkComponent.split("?");
        pathPart = splitParam[0];
        queryMap = queryStringParser.parseToQueries(splitParam[1]);
      }

      for (final node in nodesToCheck) {
        final isMatch = (node.part == pathPart || node.isParameter());

        if (isMatch) {
          RouteTreeNodeMatch? parentMatch = nodeMatches[node.parent];
          final match = RouteTreeNodeMatch.fromMatch(parentMatch, node);
          if (node.isParameter()) {
            final paramKey = node.part.substring(1);
            match.parameters[paramKey] = pathPart;
          }
          if (queryMap != null) {
            assert(!match.parameters.keys.any((p) => queryMap!.containsKey(p)),
                "不能存在相同key");
            match.parameters.addAll(queryMap);
          }
          nodePath.add(checkComponent);
          currentMatches[node] = match;
          nextNodes.addAll(node.nodes.list);
        }
      }

      nodeMatches = currentMatches;
      nodesToCheck = nextNodes;

      // 如果已经匹配到route了 就不在匹配了 不包括根目录
      if (untilFindRoute &&
          currentMatches.keys.any((it) =>
              it.routes.isNotEmpty &&
              p.normalize(it.routes.first.path) != p.separator)) {
        break;
      }

      if (currentMatches.values.isEmpty) {
        return null;
      }
    }

    final matches = nodeMatches.values.toList();

    if (matches.isNotEmpty) {
      final match = matches.first;
      final nodeToUse = match.node;
      final routes = nodeToUse.routes;

      if (routes.isNotEmpty) {
        final routeMatch = RouteMatch(routes[0], p.joinAll(nodePath));
        routeMatch.parameters.addAll(match.parameters);
        return routeMatch;
      }
    }

    return null;
  }

  @override
  String add(SimpleRoute route) {
    return addNode(route, parentPath: _path);
  }

  String addNode(SimpleRoute route, {String parentPath = ""}) {
    String path = p.normalize(route.path);
    parentPath = p.normalize(parentPath);

    assert(p.isRelative(path) && p.isAbsolute(parentPath) || p.isAbsolute(path),
        "相对路径需要[parentPath]");

    if (p.isRelative(path)) {
      path = p.join(parentPath, path);
    }

    assert(path != p.separator, "不能多次添加根节点");

    final pathComponents = p.split(path);

    RouteTreeNode? parent;

    for (int i = 0; i < pathComponents.length; i++) {
      String? component = pathComponents[i];
      RouteTreeNode? node = _nodeForComponent(component, parent);

      if (node == null) {
        RouteTreeNodeType type = _typeForComponent(component);
        node = RouteTreeNode(component, type);
        node.parent = parent;

        if (parent == null) {
          _nodes.add(node);
        } else {
          parent.nodes.add(node);
        }
      }

      if (i == pathComponents.length - 1) {
        node.routes.add(route);
      }

      parent = node;
    }
    _routes[route] = path;

    return path;
  }

  RouteTreeNode? _nodeForComponent(String component, RouteTreeNode? parent) {
    var nodes = _nodes;

    if (parent != null) {
      // search parent for sub-node matches
      nodes = parent.nodes;
    }

    for (final node in nodes.list) {
      if (node.part == component) {
        return node;
      }
    }

    return null;
  }

  RouteTreeNodeType _typeForComponent(String component) {
    var type = RouteTreeNodeType.component;

    if (_isParameterComponent(component)) {
      type = RouteTreeNodeType.parameter;
    }

    return type;
  }

  /// Is the path component a parameter
  bool _isParameterComponent(String component) {
    return component.startsWith(":");
  }

  @override
  void clearChildren(String path) {
    path = p.normalize(path);
    assert(p.isAbsolute(path), "[path] 必须要绝对路径");

    final pathComponents = p.split(path);

    RouteTreeNode? parent;

    for (int i = 0; i < pathComponents.length; i++) {
      String? component = pathComponents[i];
      RouteTreeNode? node = _nodeForComponent(component, parent);

      if (i == pathComponents.length - 1) {
        if (node != null) {
          node.nodes.clear();
          for (int j = 0; j < node.routes.length; j++) {
            _routes.remove(node.routes[j]);
          }
          node.routes.clear();
        }
      }

      parent = node;
    }
  }

  RouterLayerCollection? getRoutesFromPath(String path) {
    path = p.normalize(path);
    assert(p.isAbsolute(path), "[path] 必须要绝对路径");

    final pathComponents = p.split(path);

    RouteTreeNode? parent;

    for (int i = 0; i < pathComponents.length; i++) {
      String? component = pathComponents[i];
      RouteTreeNode? node = _nodeForComponent(component, parent);

      if (i == pathComponents.length - 1) {
        if (node != null) {
          return RouterLayerCollection(path, this, node.nodes);
        }
      }

      parent = node;
    }
    return null;
  }

  @override
  String get path => _path;

  @override
  int get length => _nodes.length;

  @override
  List<SimpleRoute> get routes => List.unmodifiable(
      _nodes.list.fold<List>([], (pre, e) => pre..addAll(e.routes)));

  @override
  String? getAbsolutePath(SimpleRoute route) {
    return _routes[route];
  }

  @override
  String getRelativePath(String path, String prefix) {
    path = p.normalize(path);
    prefix = p.normalize(prefix);

    var pathPart = p.split(path);
    var prefixPart = p.split(prefix);
    var matched = 0;
    for (var i = 0; i < prefixPart.length; i++) {
      // 如果相等 则继续匹配
      if (prefixPart[i] != pathPart[i]) {
        break;
      }
      matched++;
    }

    return p.joinAll(pathPart.skip(matched));
  }
}

/// 必须是相对路径
class RouterLayerCollection extends RouteCollection with RouteMatcher {
  @override
  List<SimpleRoute> get routes => List.unmodifiable(
      _nodes.list.fold<List>([], (pre, e) => pre..addAll(e.routes)));
  final String _path;
  final ObservableList<RouteTreeNode> _nodes;
  final RouteTree _tree;
  RouterLayerCollection(
      String path, this._tree, ObservableList<RouteTreeNode> nodes)
      : _nodes = nodes,
        _path = path;

  @override
  int get length => _nodes.length;

  @override
  String? add(SimpleRoute route) {
    assert(p.isRelative(route.path));
    return _tree.addNode(route, parentPath: _path);
  }

  @override
  void clearChildren(String path) {
    assert(p.isRelative(path));
    path = p.join(_path, path);
    _tree.clearChildren(path);
  }

  /// 根据当前nodes 匹配孩子
  @override
  RouteMatch? match(String path) {
    var usePath = p.normalize(path);
    assert(p.isRelative(usePath));
    return _tree._match(usePath, _nodes.list, untilFindRoute: true);
  }

  int indexOf(SimpleRoute route) {
    return routes.indexOf(route);
  }

  @override
  QueryStringParser get queryStringParser => throw UnimplementedError();

  @override
  String get path => _path;

  @override
  String? getAbsolutePath(SimpleRoute route) {
    return _tree.getAbsolutePath(route);
  }

  @override
  String getRelativePath(String path, String prefix) {
    return _tree.getRelativePath(path, prefix);
  }
}
