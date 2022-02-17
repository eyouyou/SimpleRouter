import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:simple_route/models/index.dart';
import 'package:simple_route/routers/proxy.dart';
import 'package:simple_route/routes/simple_route_delegate.dart';
import '../matcher/index.dart';

typedef Switcher = void Function(RouteSettings setttings);

/// 控制增加路由 跳转逻辑
/// 添加路由： 需要支持任意一个节点中增加路由 进行路由器刷新（不能用独立tree进行）
/// 根可以直接添加树
///   1. 如果新增路由与当前路由不匹配 例如增加了绝对路径的路由节点 则报错
/// 切换路由： 通过matcher得到匹配 切换当前 得到对应的子路由 进行切换
/// 孩子怎么给子路由？如果子路由器 还没有生成怎么办
/// root 中存在一棵大树 后续router都从这颗大树中同步 如果大树或者孩子发生变化 则互相通知
abstract class SimpleRouter extends ChangeNotifier {
  // /// 子路由器节点
  final List<SimpleRouter> subControllers = [];
  final RouteComponent component;
  RouteMatcher get routeMatcher;
  RouteCollection get collection;
  SimpleRouter(this.component);
  String? _currentPath;

  ///在当前路由器中添加路由
  void addRoute(SimpleRoute route, {SimpleRoute? parent}) {
    collection.add(route);
    notifyListeners();
  }

  /// 如果孩子没有加入当前路由器中 在孩子进行加载的时候进行跳转逻辑
  /// 如果孩子要保存状态 则自己保存 而不是通过该方式每次都进行跳转
  void lazyLoad(SimpleRouter subRouter) {
    var currentPath = _currentPath;
    if (currentPath != null) {
      subRouter.navigate(currentPath);
    }
    _currentPath = null;
  }

  void navigate(String path, {Object? arguments}) {
    var match = routeMatcher.match(path);
    if (match != null) {
      switchRoute(match, arguments: arguments);
      var currentPath = collection.getRelativePath(path, match.path);
      for (var item in subControllers) {
        item.navigate(currentPath);
      }
      // 没有通知到的孩子 自己来拿
      _currentPath = currentPath;
    }
  }

  void attachSubController(SimpleRouter router) {
    subControllers.add(router);
  }

  void detachSubController(SimpleRouter router) {
    subControllers.remove(router);
  }

  /// 各个类型的
  void switchRoute(RouteMatch match, {Object? arguments});

  @override
  bool operator ==(Object other) {
    if (!identical(other, this)) {
      return false;
    }
    return other is SimpleRouter &&
        other.component == component &&
        listEquals(other.component.children, component.children);
  }

  @override
  int get hashCode => component.hashCode;
}

abstract class ProxyRouter extends SimpleRouter {
  final RouteProxyController controller = RouteProxyController();

  ProxyRouter({
    required RouteComponent route,
  }) : super(route);

  @override
  void switchRoute(RouteMatch match, {Object? arguments}) {
    controller.routeData = RouteData.fromMatch(
        match, RouteSettings(name: match.path, arguments: arguments));
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }
}

mixin LayerRouter on SimpleRouter {
  RouterLayerCollection get layerCollection =>
      collection as RouterLayerCollection;
}

/// 最上层需要跳转接口
/// 下面的每一层都可以控制添加或者删除节点
class RootRouter extends ProxyRouter {
  late RouteTree tree;
  RootRouter()
      : super(
            route:
                RouteComponent("/", Handler((ctx, routeData) => Container()))) {
    tree = RouteTree(component);
  }

  @override
  RouteCollection get collection => tree;

  @override
  RouteMatcher get routeMatcher => tree;

  RouterDelegate<Object> get routerDelegate => SimpleRouterDelegate(this);

  RouteInformationParser<Object> get routingInformationParser =>
      SimpleRouteInformationParser(this);

  RouterLayerCollection getLayerCollection(String path) {
    var collection = tree.getRoutesFromPath(path);
    assert(collection != null, "没有找到当前路由层, 请先添加");
    return collection!;
  }
}
