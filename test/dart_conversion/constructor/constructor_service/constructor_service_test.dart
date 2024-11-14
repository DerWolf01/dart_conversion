import 'dart:math';

import '../../../../lib/src/constructor/constructor_service.dart';
import '../../../../lib/src/convertable.dart';
import '../../../../lib/src/my_logger.dart';
import 'package:reflectable/reflectable.dart';
import 'package:test/test.dart';

import 'constructor_service_test.reflectable.dart';

@convertable
class TestClass {
  TestClass(this.id, this.name, {this.lastName});
  final int id;

  final String name;

  final String? lastName;

  late final bool registered;
}

void main() {
  initializeReflectable();
  MyLogger.init(enabled: true);
  group("ConstructorService", () {
    test("constructConstructorArguments", () {
      final testMap = {
        "id": 0,
        "name": "name",
        "lastName": "alfred",
        "registered": false
      };

      final constructorArguments = ConstructorService()
          .constructConstructorArguments(
              classMirror: convertable.reflectType(TestClass) as ClassMirror,
              values: testMap);

      expect(constructorArguments.positionedArguments, [0, "name"]);
      expect(
          constructorArguments.namedArguments, {Symbol("lastName"): "alfred"});
    });

    test("callConstructorUsingClassMirror", () {
      final testMap = {
        "id": 0,
        "name": "name",
        "lastName": "alfred",
        "registered": false
      };

      final reflection = convertable.reflectType(TestClass) as ClassMirror;
      final constructorArguments = ConstructorService()
          .constructConstructorArguments(
              classMirror: reflection, values: testMap);

      final TestClass testClass = ConstructorService()
          .callConstructorUsingClassMirror(
              classMirror: reflection,
              constructorArguments: constructorArguments);

      expect(testClass, isA<TestClass>());

      expect(testClass.registered, isA<bool>());
    });
  });
}
