import 'dart:async';
import 'dart:mirrors';

import 'package:dart_conversion/dart_conversion.dart';
import 'package:dart_conversion/my_logger.dart';

MethodService get methodService => MethodService();

typedef OnParameterAnotations = List<OnParameterAnotation>;

class MethodParameters {
  final List<dynamic> args;
  final Map<String, dynamic> namedArgs;

  MethodParameters(this.args, this.namedArgs);
}

class MethodService {
  static MethodService? _instance;

  factory MethodService() => (_instance ??= MethodService._());

  MethodService._();

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
      myLogger.e(e, stackTrace: s, header: "Error while invoking method");
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

      if (anotation != null) {
        final anotationInstance = param.metadata
            .where(
              (element) =>
                  element.type.reflectedType == anotation.anotationType,
            )
            .first
            .reflectee;

        if (param.isNamed) {
          namedArgs[name] = anotation.generateValue(
              name, argumentsMap[name], anotationInstance);
          continue;
        }

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
        args.add(null);
        continue;
      }
    }
    return MethodParameters(args, namedArgs);
  }
}

class OnParameterAnotation<AnotationType> {
  final dynamic Function(String key, dynamic value, dynamic anotation)
      generateValue;

  const OnParameterAnotation(this.generateValue);
  Type get anotationType => AnotationType;
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
