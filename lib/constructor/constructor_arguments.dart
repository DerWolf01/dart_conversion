import 'package:reflectable/reflectable.dart';

class ConstructorArguments {
  ConstructorArguments(
      {List<dynamic>? positionedArguments,
      Map<Symbol, dynamic>? namedArguments})
      : positionedArguments = positionedArguments ?? [],
        namedArguments = namedArguments ?? {};

  /// The name of the constructor to be called
  final List<dynamic> positionedArguments;

  /// The named constructor arguments
  final Map<Symbol, dynamic> namedArguments;
}

class ConstructorParameters {
  const ConstructorParameters({
    this.positionedParameters = const [],
    this.namedParameters = const {},
  });
  final List<ParameterMirror> positionedParameters;

  final Map<String, ParameterMirror> namedParameters;
}
