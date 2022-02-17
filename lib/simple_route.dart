library simple_route;

import 'package:flutter/widgets.dart';

export "routers/index.dart";
export "matcher/index.dart";
export "models/index.dart";

class ObservableList<T> extends ChangeNotifier {
  final List<T> list;
  ObservableList(this.list);

  void add(T item) {
    list.add(item);
    notifyListeners();
  }

  void remove(T item) {
    list.remove(item);
    notifyListeners();
  }

  void clear() {
    list.clear();
    notifyListeners();
  }

  int get length => list.length;
}
