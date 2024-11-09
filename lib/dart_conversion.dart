import 'package:dart_conversion/convertable.dart';
import 'package:dart_conversion/exception.dart';
import 'package:dart_conversion/instance_mirror_extension.dart';
import 'package:dart_conversion/my_logger.dart';
import 'package:dart_conversion/transformer/transformer.dart';

DartConversion get dartConversion => DartConversion();

class DartConversion {
  static DartConversion? _instance;
  const DartConversion._();

  factory DartConversion() => _instance ??= DartConversion._();

  To convert<To>(dynamic value, {Type? to}) {
    final transformer = transformers[to ?? To];
    if (transformer == null) {
      throw DartConversionException(
          "No transformer for Type ${to ?? To} found.");
    }
    late final To res;
    if (transformers[value.runtimeType] != null) {
      myLogger.d(
          "Converting Value of $value of type ${value.runtimeType} to ${to ?? To}",
          header: "DartConversion");
      res = transformer.transform(value);
    } else {
      myLogger.d(
          "Converting Object $value of type ${value.runtimeType} to ${to ?? To}",
          header: "DartConversion");

      final objectMap = objectToMap(value);

      res = transformer.transform(objectMap);
    }
    myLogger.i(
        "Converted $value of type ${value.runtimeType} to $res of type ${to ?? To}",
        header: "DartConversion");

    return res;
  }
}

Map<String, dynamic> objectToMap(Object object) {
  try {
    if (!convertable.canReflect(object)) {
      throw DartConversionException(
          "Object $object of Type ${object.runtimeType} is not anotated with @convertable");
    }

    final reflection = convertable.reflect(object);

    return reflection.instanceMemberDeclarationVariables.map(
      (key, value) {
        final reflectedValue = reflection.invokeGetter(key);
        late final dynamic convertedValue;
        final transformer = transformers[reflectedValue.runtimeType];
        try {
          myLogger.d(
              "Key Value pair --> $key:$value. Trasnformer: $transformer. ",
              header: "DartConversion.objectToMap");

          if (transformer != null) {
            convertedValue = reflectedValue;
          } else if (reflectedValue is List) {
            convertedValue = reflectedValue
                .map((e) => dartConversion.convert<Map<String, dynamic>>(
                      e,
                    ))
                .toList();
          } else if (reflectedValue is Map) {
            convertedValue = reflectedValue.map((key, value) => MapEntry(
                key,
                dartConversion.convert<Map<String, dynamic>>(
                  value,
                )));
          } else {
            convertedValue = dartConversion.convert<Map<String, dynamic>>(
              reflectedValue,
            );
          }
          myLogger.d("Conveted value: $convertedValue",
              header: "DartConversion.objectToMap");
          return MapEntry(key, convertedValue);
        } catch (e, s) {
          myLogger.e(e, stackTrace: s, header: "DartConversion.objectToMap");
        }
        throw DartConversionException(
            "Couldn't find appropiat format for value of $reflectedValue of type ${reflectedValue.runtimeType}");
      },
    );
  } catch (e, s) {
    myLogger.e(e, stackTrace: s, header: "DartConversion.objectToMap($object)");

    throw DartConversionException("Couldn't convert $object to Map");
  }
}
