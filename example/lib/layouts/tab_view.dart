import 'package:example/index.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_route/routers/simple_router.dart';
import 'package:simple_route/simple_route.dart';

class TabViewRouter extends RouterWidget {
  final RouteComponent component;
  const TabViewRouter(this.component, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TabViewRouterState();
}

class _TabViewRouterState extends State<TabViewRouter>
    with RouterMixin<TabViewRouter>, TickerProviderStateMixin {
  late TabRouter _router;
  TabController? _controller;
  @override
  void didChangeDependencies() {
    _controller?.dispose();
    var collection = getCollection(context, widget.component);
    var tabController = TabController(
        length: collection.length,
        vsync: this,
        animationDuration: const Duration(milliseconds: 100));
    _controller = tabController;
    _router = TabRouter(collection, widget.component, tabController);
    super.didChangeDependencies();
  }

  @override
  Widget buildRouter(BuildContext context) {
    var themeData = Theme.of(context);
    var tab = Column(children: [
      ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 32, minHeight: 30),
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  //   child: Container(
                  // alignment: Alignment.centerLeft,
                  child: TabBar(
                      controller: _controller,
                      tabs: _buildTabs(context),
                      indicatorSize: TabBarIndicatorSize.tab,
                      // indicatorPadding: EdgeInsets.only(left: 30, right: 30),
                      isScrollable: true,
                      indicator: BoxDecoration(
                          border: Border(
                        top:
                            BorderSide(width: 2, color: themeData.primaryColor),
                        right:
                            BorderSide(width: 1, color: themeData.dividerColor),
                        // left: BorderSide(),
                      ))),
                ),
              ])),
      const Divider(height: 1, thickness: 1),
      Expanded(
        child: TabBarView(
            physics: const NeverScrollableScrollPhysics(),
            controller: _controller,
            children: _buildTabChildren(context)),
      ),
    ]);

    return Row(children: [
      Expanded(child: tab),
    ]);
  }

  List<Widget> _buildTabs(BuildContext context) {
    return _router.layerCollection.routes
        .asMap()
        .entries
        .map((e) => getHeaderText(e.value.asAppRoute(), e.key))
        .toList();
  }

  Widget getHeaderText(ExampleRoute? route, int index) {
    return ChangeNotifierProvider<TabController>.value(
        value: _controller!,
        builder: (ctx, _) {
          var style = Theme.of(ctx).textTheme.subtitle2;
          if (ctx.watch<TabController>().index == index) {
            style = style!.copyWith(color: Theme.of(ctx).primaryColor);
          }

          return Container(
              constraints: const BoxConstraints(maxWidth: 130, minWidth: 60),
              child: Align(
                  alignment: Alignment.center,
                  child: Text(route!.text, style: style)));
        });
  }

  List<Widget> _buildTabChildren(BuildContext context) {
    return _router.layerCollection.routes.map((e) {
      var route = e.asAppRoute();
      return route.build(context, RouteData.fromRoute(route));
    }).toList();
  }

  @override
  SimpleRouter get router => _router;
}
