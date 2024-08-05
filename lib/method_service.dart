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

  Future<InstanceMirror> invokeAsync(
      {required InstanceMirror holderMirror,
      required MethodMirror methodMirror,
      required Map<String, dynamic> argumentsMap,
      OnParameterAnotations? onParameterAnotation}) async {
    final methodParameters = methodArgumentsByMap(
        methodMirror: methodMirror,
        argumentsMap: argumentsMap,
        onParameterAnotation: onParameterAnotation);

    final res = await (holderMirror.invoke(
        Symbol(methodMirror.name),
        methodParameters.args,
        methodParameters.namedArgs.map(
          (key, value) => MapEntry(Symbol(key), value),
        )) as FutureOr<InstanceMirror>);
    print('res: $res');
    return res;
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
      if (argumentsMap.containsKey(name)) {
        final anotation = onParameterAnotation
            ?.where(
              (element) => element.checkAnotation(param),
            )
            .firstOrNull;
        if (param.isNamed) {
          if (anotation != null) {
            namedArgs[name] =
                anotation.generateValue(name, argumentsMap[name], anotation);
          } else {
            namedArgs[name] = ConversionService.convert(
                type: type, value: argumentsMap[name]);
          }
          continue;
        }

        if (anotation != null) {
          args.add(
              anotation.generateValue(name, argumentsMap[name], anotation));
        } else {
          args.add(
              ConversionService.convert(type: type, value: argumentsMap[name]));
        }
      } else {
        args.add(null);
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
  final dynamic Function(String key, dynamic value, AnotationType anotation)
      generateValue;

  bool checkAnotation(ParameterMirror parameterMirror) {
    return parameterMirror.metadata
        .any((element) => element.type.reflectedType == anotationType);
  }
}

extension MirrorName on DeclarationMirror {
  String get name => MirrorSystem.getName(simpleName);
}
