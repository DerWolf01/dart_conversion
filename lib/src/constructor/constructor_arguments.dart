import 'package:reflectable/reflectable.dart';

/// This class includes the raw arguments of the constructor to be invoked
class ConstructorArguments {
  ConstructorArguments(
      {List<dynamic>? positionedArguments,
      Map<Symbol, dynamic>? namedArguments,
      Map<String, dynamic>? nonConstructorFields})
      : positionedArguments = positionedArguments ?? [],
        namedArguments = namedArguments ?? {},
        nonConstructorFields = nonConstructorFields ?? {};

  /// The positioned constructor arguments
  final List<dynamic> positionedArguments;

  /// The named constructor arguments
  final Map<Symbol, dynamic> namedArguments;

  final Map<String, dynamic> nonConstructorFields;
}

/// This class display the parameters of the constructor to be invoked in form of ParameterMirrors
/// Divided by positioned and named parameters
class ConstructorParameters {
  const ConstructorParameters({
    this.positionedParameters = const [],
    this.namedParameters = const {},
  });

  /// The name of the constructor to be called
  final List<ParameterMirror> positionedParameters;

  /// The named constructor parameters
  final Map<String, ParameterMirror> namedParameters;
}
