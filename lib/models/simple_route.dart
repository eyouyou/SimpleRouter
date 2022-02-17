import 'dart:math';

import 'package:flutter/material.dart';

/// 可以通过该类进行派生 增加一些属性
/// 通过key来确定确保是否一致
class SimpleRoute {
  /// 控制是否一致
  final Key key;

  /// 路径 支持相对路径和绝对路径
  final String path;

  /// 需要根据当前children进行是否绘制操作
  final List<SimpleRoute> _children;
  List<SimpleRoute> get children => _children.toList();

  SimpleRoute(this.path, {List<SimpleRoute>? initialChildren, Key? key})
      : key = key ?? _RefKey(),
        _children = initialChildren ?? const [];

  void addChild(SimpleRoute child) {
    _children.add(child);
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) {
      return true;
    }
    return other is SimpleRoute && other.key == key;
  }

  @override
  int get hashCode => key.hashCode;
}

// ignore: must_be_immutable
class _RefKey extends LocalKey {
  static final Random _r = Random();
  late int _hash = -1;
  // ignore: prefer_const_constructors_in_immutables
  _RefKey();

  @override
  bool operator ==(Object other) {
    return identical(other, this);
  }

  @override
  int get hashCode => _hash != -1 ? _hash = _r.nextInt(10000) : _hash;
}
