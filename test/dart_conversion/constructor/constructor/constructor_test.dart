import '../../../../lib/src/constructor/constructor.dart';
import '../../../../lib/src/constructor/constructor_extension.dart';

import '../../../../lib/src/convertable.dart';
import 'package:reflectable/reflectable.dart';
import 'package:test/test.dart';

import 'constructor_test.reflectable.dart';

@convertable
class TestClass {
  TestClass(String name, {String? lastName});
}

void main() {
  initializeReflectable();
  group("Constructor", () {
    test("constructorParameters", () {
      final constructorParameters = Constructor(
              (convertable.reflectType(TestClass) as ClassMirror)
                  .findConstructor("")!)
          .constructorParameters;
      expect(constructorParameters.positionedParameters.first,
          isA<ParameterMirror>());

      expect(
          constructorParameters.namedParameters.keys.first, equals("lastName"));
      expect(constructorParameters.namedParameters.values.first,
          isA<VariableMirror>());

      expect(constructorParameters.namedParameters.values.length, 1);

      expect(constructorParameters.namedParameters,
          isA<Map<String, VariableMirror>>());

      expect(constructorParameters.positionedParameters.length, 1);
    });
  });
}
