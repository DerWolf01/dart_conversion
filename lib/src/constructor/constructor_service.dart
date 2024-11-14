import '../class_mirror_extension.dart';
import 'constructor.dart';
import 'constructor_arguments.dart';
import 'constructor_extension.dart';
import 'exception.dart';
import '../convertable.dart';
import '../dart_conversion.dart';
import '../collection_of.dart';
import '../my_logger.dart';
import 'package:reflectable/reflectable.dart';

class ConstructorService {
  static ConstructorService? _instance;
  const ConstructorService._();

  factory ConstructorService() => _instance ??= ConstructorService._();

  /// Invokes a constructor of an class using it's class mirror and constructor name and optional constructor arguments
  T callConstructorUsingClassMirror<T>(
      {required ClassMirror classMirror,
      String name = "",
      ConstructorArguments? constructorArguments}) {
    final finalConstructorArguments =
        constructorArguments ?? ConstructorArguments();

    // TODO: nest ConstructorParameters instance in ConstructorArguments
    // myLogger.i(
    //     "Calling ${classMirror.simpleName}${name.isEmpty ? "(${finalConstructorArguments.positionedArguments.map(
    //           (e) => convertable.reflect(e),
    //         ).map(
    //           (e) => "${e.type.reflectedType} ${e.type.simpleName} ",
    //         ).join(", ")}, {${finalConstructorArguments.namedArguments.values.map(
    //           (e) => convertable.reflect(e),
    //         ).map(
    //           (e) => "${e.type.reflectedType} ${e.type.simpleName} ",
    //         ).join(", ")}})" : ".$name()"}",
    //     header: "ConstructorService().callConstructorUsingClassMirror");
    final instance = classMirror.newInstance(
        name,
        finalConstructorArguments.positionedArguments,
        finalConstructorArguments.namedArguments);
    myLogger.i("Successfully instanciated ${classMirror.simpleName}: $instance",
        header: "ConstructorService().callConstructorUsingClassMirror");

    /// if there are dangling fields that were provided in the map that simultaniously exist as attributes in the class, the library will try to invoke the setters of these fields successfully using these values expecting them to be marked as late.
    if (constructorArguments?.nonConstructorFields.isNotEmpty == true) {
      myLogger.w("Non constructor values aren't empty",
          header: "ConstructorService().callConstructorUsingClassMirror");
      final instanceReflection = convertable.reflect(instance);
      for (final field in constructorArguments!.nonConstructorFields.entries) {
        try {
          final declaration = classMirror.findField(field.key);

          if (declaration == null) {
            throw ConstructorServiceException(
                "No field with name of \"${field.key}\" was found in class ${classMirror.simpleName} ",
                StackTrace.current);
          }
          myLogger.w("Found field ${field.key} and attempting setter invoking.",
              header: "ConstructorService().callConstructorUsingClassMirror");
          instanceReflection.invokeSetter(
              field.key,
              dartConversion.convert(field.value,
                  to: declaration.type.originalDeclaration.reflectedType,
                  collectionOf:
                      classMirror.getCollectionOfUsingName(field.key) ??
                          declaration.type.metadata
                              .whereType<CollectionOf>()
                              .firstOrNull));
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

  ConstructorArguments constructConstructorArguments(
      {required ClassMirror classMirror,
      String name = "",
      Map<String, dynamic> values = const {}}) {
    myLogger.i(
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
    myLogger.i(
        "Found constructor method mirror for ${classMirror.simpleName}${name.isEmpty ? "(${constructorParameters.positionedParameters.map(
              (e) => "${e.type.reflectedType} ${e.simpleName} ",
            ).join(", ")}, {${constructorParameters.namedParameters.values.map(
              (e) => "${e.type.reflectedType} ${e.simpleName} ",
            ).join(", ")}})" : ".$name()"}",
        header: "ConstructorService.constructConstructorArguments");
    final ConstructorArguments constructorArguments = ConstructorArguments();

    final nonConstructorAttributes = Map.fromEntries(values.entries.where(
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

      constructorArguments.nonConstructorFields.addEntries(
          (nonConstructorAttributes.entries.where(
              (element) => attributesWithSameNames.containsKey(element.key))));
    }

    for (final positionedArgument
        in constructorParameters.positionedParameters) {
      final argument = values[positionedArgument.simpleName];

      if (argument == null) {
        throw ConstructorParameterException(
            "No argument found for positioned constructor parameter ”${positionedArgument.simpleName}” found in provided map $values",
            positionedArgument.simpleName);
      }

      myLogger.i(
          "Found positioned constructor argument with name \"${positionedArgument.simpleName}” of value $argument");

      myLogger.i(
          "Attempting to convert $argument of type ${argument.runtimeType} to positioned parameter type ${positionedArgument.type.reflectedType}");

      constructorArguments.positionedArguments.add(dartConversion.convert(
          argument,
          to: positionedArgument.type.originalDeclaration.reflectedType,
          collectionOf: classMirror
                  .getCollectionOfUsingName(positionedArgument.simpleName) ??
              positionedArgument.type.metadata
                  .whereType<CollectionOf>()
                  .firstOrNull));
    }

    for (final namedArgumentEntry
        in constructorParameters.namedParameters.entries) {
      final namedArgument = namedArgumentEntry.value;
      final name = namedArgumentEntry.key;
      final argument = values[name];

      if (argument == null) {
        throw ConstructorParameterException(
            "No argument for positioned contructor parameter ”${namedArgument.simpleName}” found in provided map $values",
            namedArgument.simpleName);
      }
      myLogger.i(
          "Found named constructor argument with name \"${namedArgument.simpleName}” of value $argument",
          header: "ConstructorService.constructConstructorArguments");

      myLogger.i(
          "Attempting to convert $argument of type ${classMirror.getCollectionOfUsingName(namedArgument.simpleName) ?? argument.runtimeType} to named parameter type ${namedArgument.type.reflectedType} with name ${namedArgument.simpleName}",
          header: "ConstructorService.constructConstructorArguments");
      constructorArguments.namedArguments[Symbol(name)] =
          dartConversion.convert(argument,
              to: namedArgument.reflectedType,
              collectionOf: classMirror
                      .getCollectionOfUsingName(namedArgument.simpleName) ??
                  namedArgument.type.metadata
                      .whereType<CollectionOf>()
                      .firstOrNull);
    }
    return constructorArguments;
  }
}
