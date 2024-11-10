import 'package:dart_conversion/constructor/constructor_arguments.dart';
import 'package:reflectable/reflectable.dart';

class Constructor {
  const Constructor(this.methodMirror);
  final MethodMirror methodMirror;

  ConstructorParameters get constructorParameters => ConstructorParameters(
      positionedParameters: methodMirror.parameters
          .where(
            (element) => !element.isNamed,
          )
          .toList(),
      namedParameters: Map.fromEntries(methodMirror.parameters
          .where(
            (element) => element.isNamed,
          )
          .map(
            (e) => MapEntry(e.simpleName, e),
          )));
}
