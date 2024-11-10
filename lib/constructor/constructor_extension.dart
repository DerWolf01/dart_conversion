import 'package:reflectable/reflectable.dart';

extension ConstructorExtension on ClassMirror {
  /// Extracts all constructors from the class mirror instance
  Map<String, MethodMirror> get constructors {
    final Map<String, MethodMirror> found = {};

    for (final declaration in declarations.entries) {
      if (declaration.value is MethodMirror &&
          (declaration.value as MethodMirror).isConstructor) {
        final constructor = declaration.value as MethodMirror;
        final constructorName = constructor.simpleName == simpleName
            ? ""
            : constructor.simpleName.replaceAll("$simpleName.", "");
        found[constructorName] = constructor;
      }
    }
    return found;
  }

  /// finds a constructor that is included in the class mirror by name
  MethodMirror? findConstructor(String name) => constructors[name];
}
