import 'dart:async';

import 'package:dart_conversion/constructor/constructor.dart';
import 'package:dart_conversion/constructor/constructor_arguments.dart';
import 'package:dart_conversion/constructor/constructor_extension.dart';
import 'package:dart_conversion/constructor/exception.dart';
import 'package:dart_conversion/my_logger.dart';
import 'package:reflectable/reflectable.dart';

class ConstructorService {
  static ConstructorService? _instance;
  const ConstructorService._();

  factory ConstructorService() => _instance ??= ConstructorService._();

  callConstructorUsingClassMirror(
      {required ClassMirror classMirror,
      String name = "",
      ConstructorArguments? constructorArguments}) {
    final finalConstructorArguments =
        constructorArguments ?? ConstructorArguments();
    classMirror.newInstance(name, finalConstructorArguments.positionedArguments,
        finalConstructorArguments.namedArguments);
  }

  constructConstructorArguments(
      {required ClassMirror classMirror,
      String name = "",
      Map<String, dynamic> map = const {}}) {
    myLogger.d(
        "Constructing constructor arguments for ${classMirror.simpleName}${name.isEmpty ? "" : ".$name"}",
        header: "ConstructorService.constructConstructorArguments");
    final constructorMethodMirror = classMirror.findConstructor(name);
    if (constructorMethodMirror == null) {
      throw ConstructorServiceException(
          "No constructor with name \"\" found in class ${classMirror.simpleName}",
          StackTrace.current);
    }
    final constructor = Constructor(constructorMethodMirror);
    final ConstructorParameters constructorParameters =
        constructor.constructorParameters;
    myLogger.d(
        "Found cosntructor method mirror for ${classMirror.simpleName}${name.isEmpty ? "(${constructorParameters.positionedParameters.map(
              (e) => "${e.type.reflectedType} ${e.simpleName} ",
            ).join(", ")}, {${constructorParameters.namedParameters.values.map(
              (e) => "${e.type.reflectedType} ${e.simpleName} ",
            ).join(", ")}})" : ".$name()"}",
        header: "ConstructorService.constructConstructorArguments");
    final ConstructorArguments constructorArguments = ConstructorArguments();
    for (final positionedArgument
        in constructorParameters.positionedParameters) {
      final argument = map[positionedArgument.simpleName];

      if (argument == null) {
        throw ConstructorParameterException(
            "No argument found for positioned contructor parameter ”${positionedArgument.simpleName}” found in provided map $map",
            positionedArgument.simpleName);
      }

      constructorArguments.positionedArguments.add(argument);
    }
  }
}
