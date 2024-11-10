import 'dart:math';

import 'package:dart_conversion/constructor/constructor_extension.dart';

import 'package:dart_conversion/convertable.dart';
import 'package:reflectable/reflectable.dart';
import 'package:test/test.dart';

import 'constructor_extension_test.reflectable.dart';

@convertable
class TestClass {
  TestClass();
  TestClass.name1();
  TestClass.name2();
}

void main() {
  initializeReflectable();
  group("ConstructorExtension", () {
    test("constructors", () {
      final constructors =
          (convertable.reflectType(TestClass) as ClassMirror).constructors;
      print(constructors.keys);
      expect(constructors.keys.toList(),
          containsAllInOrder(["", "name1", "name2"]));
    });

    test("findConstructor", () {
      expect(
          (convertable.reflectType(TestClass) as ClassMirror)
              .findConstructor(""),
          isNotNull);
      expect(
          (convertable.reflectType(TestClass) as ClassMirror)
              .findConstructor("name1"),
          isNotNull);
      expect(
          (convertable.reflectType(TestClass) as ClassMirror)
              .findConstructor("name2"),
          isNotNull);
    });
  });
}
