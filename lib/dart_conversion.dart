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

  convert<To>(dynamic value, {Type? to}) {
    final transformer = transformers[to ?? To];
    if (transformer == null) {
      throw DartConversionException(
          "No transformer for Type ${to ?? To} found.");
    }
    late final res;
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
      (key, value) => MapEntry(key, reflection.invokeGetter(key)),
    );
  } catch (e, s) {
    myLogger.e(e, stackTrace: s, header: "DartConversion.objectToMap($object)");

    throw DartConversionException("Couldn't convert $object to Map");
  }
}
