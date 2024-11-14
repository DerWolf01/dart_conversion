import 'class_mirror_extension.dart';
import 'constructor/constructor_service.dart';
import 'convertable.dart';
import 'exception.dart';
import 'instance_mirror_extension.dart';
import 'collection_of.dart';
import 'my_logger.dart';
import 'transformer/transformer.dart';
import 'package:reflectable/reflectable.dart';

export 'class_mirror_extension.dart';
export 'collection_of.dart';
export 'convertable.dart';

DartConversion get dartConversion => DartConversion();

class DartConversion {
  static DartConversion? _instance;
  const DartConversion._();

  factory DartConversion() => _instance ??= DartConversion._();

  /// This method aims to convert different type of objects or collections and also primtive datatypes to a chosen representation provided to the method head
  To convert<To>(dynamic value, {Type? to, CollectionOf? collectionOf}) {
    late final To res;
    final finalTo = to ?? To;
    if (finalTo == dynamic) {
      throw DartConversionException(
          "The value $value cannot be converted to dynamic. Provide a type using the generic type argument or method argument \"to\"");
    }

    final transformer = transformers[finalTo];
    final preDefinedValueTransformer = getTransformer(value);

    final valueTransformerIsPreDefined = preDefinedValueTransformer != null;

    /// If there is an available transformer for the provided value then the value isn't a dynamic class or model but rather one of the predefined classes in dart.
    if (valueTransformerIsPreDefined) {
      myLogger.d("Value transformer is predefined.");

      /// If the transformer isn't null also the provided value will be transformed into one of the predefined objects that were referred to in the comment above.
      if (transformer != null) {
        myLogger.d(
            "Converting Value of $value of type ${value.runtimeType} to $finalTo",
            header: "DartConversion.convert");
        res = transformer.transform(value);
      } else if (finalTo.toString().startsWith("List")) {
        if (value is! List) {
          throw DartConversionException(
              "The value provided $value was marked to be converted to an $finalTo but is not a List itsself");
        }

        if (collectionOf == null) {
          throw DartConversionException(
              "If the generic type arguments of the provided field with values $value are dynamically generated and not predefined it is required to be anotated with @CollectionOf(valueType: <Type>) in order to assure proper type conversion. This is due to an lack of ability to dynamically determine provided generic types in the dart programming language");
        }
        myLogger.i(
            "Converting the map $value to a $finalTo using @CollectionOf(${collectionOf.valueType})",
            header: "DartConversion.convert");

        return value
            .map(
              (e) => mapToObject(e, type: collectionOf.valueType),
            )
            .toList() as To;
      } else if (finalTo.toString().startsWith("Map")) {
        if (value is! Map) {
          throw DartConversionException(
              "The value provided $value was marked to be converted to an $finalTo but is not a Map itsself");
        }
        if (collectionOf == null) {
          throw DartConversionException(
              "If the generic type arguments of the provided field with values $value are dynamically generated and not predefined it is required to be anotated with @CollectionOf(valueType: <Type>) in order to assure proper type conversion. This is due to an lack of ability to dynamically determine provided generic types in the dart programming language");
        }

        myLogger.i(
            "Converting the map $value to a $finalTo using @CollectionOf(${collectionOf.valueType})",
            header: "DartConversion.convert");
        return value.map(
          (key, entry) => MapEntry(
              collectionOf.keyType != null
                  ? convert(key, to: collectionOf.keyType)
                  : key,
              mapToObject(entry, type: collectionOf.valueType)),
        ) as To;
      } else {
        myLogger.i("Converting the map $value to a $finalTo",
            header: "DartConversion.convert");
        return mapToObject(value, type: to);
      }
    } else {
      myLogger.d("Value transformer isn't predefined.");
      myLogger.d(
          "Converting Object $value of type ${value.runtimeType} to $finalTo",
          header: "DartConversion");

      final objectMap = objectToMap(value);
      if (transformer == null) {
        myLogger.i(
            "Converted $value of type ${value.runtimeType} to $objectMap of type $finalTo",
            header: "DartConversion");
        return objectMap as To;
      }
      res = transformer.transform(objectMap);
    }
    myLogger.i(
        "Converted $value of type ${value.runtimeType} to $res of type $finalTo",
        header: "DartConversion");

    return res;
  }

  Map<String, dynamic> objectToMap(Object object) {
    if (!convertable.canReflect(object)) {
      throw DartConversionException(
          "Object $object of Type ${object.runtimeType} is not anotated with @convertable");
    }
    try {
      final reflection = convertable.reflect(object);

      return reflection.variables.map(
        (String key, VariableMirror value) {
          final reflectedValue = reflection.invokeGetter(key);
          late final dynamic convertedValue;
          final preDefinedTransformer = getTransformer(reflectedValue);
          final hasCollectionOf =
              reflection.type.getCollectionOfUsingName(key) != null;
          try {
            myLogger.d("Key Value pair --> $key:$value.",
                header: "DartConversion.objectToMap");

            if (preDefinedTransformer != null && !hasCollectionOf) {
              convertedValue = preDefinedTransformer.transform(reflectedValue);
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
      myLogger.e(e,
          stackTrace: s, header: "DartConversion.objectToMap($object)");

      throw DartConversionException("Couldn't convert $object to Map");
    }
  }

  T mapToObject<T>(Map<String, dynamic> values,
      {Type? type, String constructorName = ""}) {
    try {
      Type finalType = type ?? T;
      if (finalType == dynamic) {
        throw DartConversionException(
            "Provide a type as generic type or method parameter in order to convert $values to an model object");
      }
      if (!convertable.canReflect(finalType)) {
        throw DartConversionException(
            "Type $finalType is not anotated with @convertable. Anotate it in order to assure compatibilty with this library");
      }
      final reflection = convertable.reflectType(finalType);

      if (reflection is! ClassMirror) {
        throw DartConversionException(
            "The type $finalType is not a class that acts as an model but rather a type.");
      }

      final constructorArguments = ConstructorService()
          .constructConstructorArguments(
              classMirror: reflection, values: values, name: "");
      return ConstructorService().callConstructorUsingClassMirror<T>(
          classMirror: reflection,
          constructorArguments: constructorArguments,
          name: constructorName);
    } on DartConversionException catch (e, s) {
      myLogger.e(e.toString(),
          header: "DartConversion.mapToObject", stackTrace: s);
    } catch (e, s) {
      myLogger.e(e, stackTrace: s);
    }

    throw DartConversionException("Couldn't convert $values to ${type ?? T}");
  }
}
