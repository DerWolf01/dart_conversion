import 'dart:async';
import 'dart:io';
import 'dart:mirrors';
import 'dart:typed_data';

import 'package:dart_conversion/dart_conversion.dart';

typedef OnParameterAnotations = List<OnParameterAnotation>;

MethodService get methodService => MethodService();

class MethodService {
  MethodService._();

  static MethodService? _instance;

  factory MethodService() => (_instance ??= MethodService._());

  InstanceMirror invoke(
      {required InstanceMirror holderMirror,
      required MethodMirror methodMirror,
      required Map<String, dynamic> argumentsMap,
      OnParameterAnotations? onParameterAnotation}) {
    final methodParameters = methodArgumentsByMap(
        methodMirror: methodMirror,
        argumentsMap: argumentsMap,
        onParameterAnotation: onParameterAnotation);

    return holderMirror.invoke(
        Symbol(methodMirror.name),
        methodParameters.args,
        methodParameters.namedArgs.map(
          (key, value) => MapEntry(Symbol(key), value),
        ));
  }

  Future<dynamic> invokeAsync(
      {required InstanceMirror holderMirror,
      required MethodMirror methodMirror,
      required Map<String, dynamic> argumentsMap,
      OnParameterAnotations? onParameterAnotation}) async {
    final methodParameters = methodArgumentsByMap(
        methodMirror: methodMirror,
        argumentsMap: argumentsMap,
        onParameterAnotation: onParameterAnotation);
    late final InstanceMirror res;
    try {
      res = holderMirror.invoke(
          Symbol(methodMirror.name),
          methodParameters.args,
          methodParameters.namedArgs.map(
            (key, value) => MapEntry(Symbol(key), value),
          ));
    } catch (e, s) {
      print('Error: $e');
      print('Stack: $s');
    }

    return await (res.reflectee as FutureOr<dynamic>);
  }

  MethodParameters methodArgumentsByMap(
      {required MethodMirror methodMirror,
      required Map<String, dynamic> argumentsMap,
      OnParameterAnotations? onParameterAnotation}) {
    List<dynamic> args = [];
    Map<String, dynamic> namedArgs = {};
    for (final param in methodMirror.parameters) {
      final type = param.type.reflectedType;
      final name = MirrorSystem.getName(param.simpleName);
      final anotation = onParameterAnotation
          ?.where(
            (element) => element.checkAnotation(param) != null,
          )
          .firstOrNull;
      print("anotation $anotation");
      if (anotation != null) {
        final anotationInstance = param.metadata
            .where(
              (element) =>
                  element.type.reflectedType == anotation.anotationType,
            )
            .first
            .reflectee;

        print("anotationInstance $anotationInstance");
        if (param.isNamed) {
          print('anotation $anotation $name $argumentsMap[name]');
          namedArgs[name] = anotation.generateValue(
              name, argumentsMap[name], anotationInstance);
          continue;
        }
        print('anotation $anotation $name ${argumentsMap[name]}');
        args.add(anotation.generateValue(
            name, argumentsMap[name], anotationInstance));
        continue;
      }
      if (argumentsMap.containsKey(name)) {
        if (param.isNamed) {
          namedArgs[name] =
              ConversionService.convert(type: type, value: argumentsMap[name]);

          continue;
        }

        args.add(
            ConversionService.convert(type: type, value: argumentsMap[name]));
      } else {
        if (ConversionService.isNullable(param.type)) {
          args.add(null);
          continue;
        } else {
          throw ArgumentError('Missing argument $name');
        }
      }
    }
    return MethodParameters(args, namedArgs);
  }
}

class MethodParameters {
  final List<dynamic> args;
  final Map<String, dynamic> namedArgs;

  MethodParameters(this.args, this.namedArgs);
}

class OnParameterAnotation<AnotationType> {
  const OnParameterAnotation(this.generateValue);

  Type get anotationType => AnotationType;
  final dynamic Function(String key, dynamic value, dynamic anotation)
      generateValue;
  AnotationType? checkAnotation(ParameterMirror parameterMirror) {
    return parameterMirror.metadata
        .where((element) =>
            element.type.isAssignableTo(reflectType(anotationType)) ||
            element.type.isSubtypeOf(reflectType(anotationType)))
        .firstOrNull
        ?.reflectee;
  }
}

extension MirrorName on DeclarationMirror {
  String get name => MirrorSystem.getName(simpleName);
}
