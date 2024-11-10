import 'package:dart_conversion/class_mirror_extension.dart';
import 'package:dart_conversion/constructor/constructor.dart';
import 'package:dart_conversion/constructor/constructor_arguments.dart';
import 'package:dart_conversion/constructor/constructor_extension.dart';
import 'package:dart_conversion/constructor/exception.dart';
import 'package:dart_conversion/convertable.dart';
import 'package:dart_conversion/dart_conversion.dart';
import 'package:dart_conversion/my_logger.dart';
import 'package:reflectable/reflectable.dart';

class ConstructorService {
  static ConstructorService? _instance;
  const ConstructorService._();

  factory ConstructorService() => _instance ??= ConstructorService._();

  T callConstructorUsingClassMirror<T>(
      {required ClassMirror classMirror,
      String name = "",
      ConstructorArguments? constructorArguments}) {
    final finalConstructorArguments =
        constructorArguments ?? ConstructorArguments();

    myLogger.d(
        "Calling ${classMirror.simpleName}${name.isEmpty ? "(${finalConstructorArguments.positionedArguments.map(
              (e) => "${e.type.reflectedType} ${e.simpleName} ",
            ).join(", ")}, {${finalConstructorArguments.namedArguments.values.map(
              (e) => "${e.type.reflectedType} ${e.simpleName} ",
            ).join(", ")}})" : ".$name()"}",
        header: "ConstructorService().callConstructorUsingClassMirror");
    final instance = classMirror.newInstance(
        name,
        finalConstructorArguments.positionedArguments,
        finalConstructorArguments.namedArguments);
    myLogger.d("Successfully instanciated ${classMirror.simpleName}: $instance",
        header: "ConstructorService().callConstructorUsingClassMirror");
    if (constructorArguments?.nonConstructorFields.isNotEmpty == true) {
      final instanceReflection = convertable.reflect(instance);
      for (final field in constructorArguments!.nonConstructorFields.entries) {
        try {
          final declaration = classMirror.findField([field.key]);

          if (declaration == null) {
            throw ConstructorServiceException(
                "No field with name of \"${field.key}\" was found in class ${classMirror.simpleName} ",
                StackTrace.current);
          }
          instanceReflection.invokeSetter(
              field.key,
              dartConversion.convert(field.value,
                  to: declaration.reflectedType));
        } catch (e, s) {
          myLogger.e("""
Error: Couldnt't invoke setter for ${field.key}. Make sure the field is marked as late. 

$e""",
              header: "ConstructorService().callConstructorUsingClassMirror",
              stackTrace: s);

          throw ConstructorServiceException(e.toString(), s);
        }
      }
    }
    return instance as T;
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

    final nonConstructorAttributes = Map.fromEntries(map.entries.where(
      (rawArgument) =>
          !constructorParameters.namedParameters.containsKey(rawArgument.key) &&
          !constructorParameters.positionedParameters.any(
            (element) => element.simpleName == rawArgument.key,
          ),
    ));
    if (nonConstructorAttributes.isNotEmpty) {
      final attributesWithSameNames =
          classMirror.findFields(nonConstructorAttributes.keys.toList());

      myLogger.w("""
Following Non constructor fields were provided --> $nonConstructorAttributes. 
Attempting to make use of them by instanciating follwing fields of the class "${classMirror.simpleName}" --> $attributesWithSameNames.
dangling fields--> ${nonConstructorAttributes..removeWhere(
              (key, value) => !attributesWithSameNames.containsKey(key),
            )}
If they aren't marked as late the library will trow an exception.
""", header: "ConstructorService.constructConstructorArguments");
    }

    for (final positionedArgument
        in constructorParameters.positionedParameters) {
      final argument = map[positionedArgument.simpleName];

      if (argument == null) {
        throw ConstructorParameterException(
            "No argument found for positioned constructor parameter ”${positionedArgument.simpleName}” found in provided map $map",
            positionedArgument.simpleName);
      }

      myLogger.d(
          "Found positioned constructor argument with name \"${positionedArgument.simpleName}” of value $argument");

      myLogger.d(
          "Attempting to convert $argument of type ${argument.runtimeType} to positioned parameter type ${positionedArgument.type.reflectedType}");

      constructorArguments.positionedArguments.add(dartConversion
          .convert(argument, to: positionedArgument.type.reflectedType));
    }

    for (final namedArgumentEntry
        in constructorParameters.namedParameters.entries) {
      final namedArgument = namedArgumentEntry.value;
      final name = namedArgumentEntry.key;
      final argument = map[name];

      if (argument == null) {
        throw ConstructorParameterException(
            "No argument for positioned contructor parameter ”${namedArgument.simpleName}” found in provided map $map",
            namedArgument.simpleName);
      }
      myLogger.d(
          "Found named constructor argument with name \"${namedArgument.simpleName}” of value $argument",
          header: "ConstructorService.constructConstructorArguments");

      myLogger.d(
          "Attempting to convert $argument of type ${argument.runtimeType} to named parameter type ${namedArgument.type.reflectedType}",
          header: "ConstructorService.constructConstructorArguments");
      constructorArguments.namedArguments[Symbol(name)] = dartConversion
          .convert(argument, to: namedArgument.type.reflectedType);
    }
  }
}
