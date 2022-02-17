import 'package:flutter_test/flutter_test.dart';
import 'package:simple_route/matcher/default.dart';
import 'package:simple_route/models/simple_route.dart';

void main() {
  group('测试默认路由匹配规则', () {
    var matcher = RouteTree(SimpleRoute("/"));
    matcher.add(SimpleRoute("users/:userId"));
    matcher.addNode(SimpleRoute("notes"), parentPath: "/users/:userId/");
    matcher.addNode(SimpleRoute("books"), parentPath: "/users/:userId/");

    test('测试匹配', () {
      var match = matcher.match("/users/1/notes?id=2");
      expect(match, isNotNull);
    });

    var layer = matcher.getRoutesFromPath("/users/:userId");

    test('层集合获取', () {
      expect(layer != null, true);
      expect(layer!.routes.isNotEmpty, true);
    });

    test('层集合添加路由', () {
      layer!.add(SimpleRoute("info"));
      var match = layer.match("info?test=1");
      expect(match, isNotNull);
    });

    test('层集合测试清理', () {
      layer!.clearChildren("info");
      var match = layer.match("info?test=1");
      expect(match, isNull);
    });

    test('测试清理', () {
      matcher.clearChildren("/users/:userId");
      var match2 = matcher.matchAll("/users/1/notes?id=2");
      expect(match2, isNull);
    });

    test('通过相对路径获取层集合的层匹配，不继续向下检索', () {
      var path = layer!.add(SimpleRoute("info/:id"));
      var layer2 = matcher.getRoutesFromPath(path!);
      layer2!.add(SimpleRoute("item"));
      var match = layer.match("info/12/item");

      /// 以上match出来的 需要是上面一个route
      expect(match, isNotNull);
      expect(match!.parameters.containsKey("id"), true);
      expect(match.route.path, "info/:id");
    });

    test('通过绝对路径匹配层集合', () {
      layer!.add(SimpleRoute("info/:id"));
      var match = matcher.match("/users/123/info/111");

      /// match出info/:id
      expect(match, isNotNull);
    });
  });
}
