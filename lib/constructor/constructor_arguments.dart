import 'package:reflectable/reflectable.dart';

class ConstructorArguments {
  ConstructorArguments(
      {List<dynamic>? positionedArguments,
      Map<Symbol, dynamic>? namedArguments,
      Map<String, dynamic>? nonConstructorFields})
      : positionedArguments = positionedArguments ?? [],
        namedArguments = namedArguments ?? {},
        nonConstructorFields = nonConstructorFields ?? {};

  /// The name of the constructor to be called
  final List<dynamic> positionedArguments;

  /// The named constructor arguments
  final Map<Symbol, dynamic> namedArguments;

  final Map<String, dynamic> nonConstructorFields;
}

class ConstructorParameters {
  const ConstructorParameters({
    this.positionedParameters = const [],
    this.namedParameters = const {},
  });
  final List<ParameterMirror> positionedParameters;

  final Map<String, ParameterMirror> namedParameters;
}
