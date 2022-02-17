import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _RefKey extends LocalKey {
  // ignore: prefer_const_constructors_in_immutables
  _RefKey();

  @override
  bool operator ==(Object other) {
    return identical(other, this);
  }

  @override
  int get hashCode => 1;
}

void main() {
  group('测试dart', () {
    test('测试identical', () {
      var key1 = _RefKey();
      var key2 = _RefKey();
      expect(key1 == key2, false);
    });
  });
}
