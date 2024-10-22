import 'dart:convert';

import 'package:dart_conversion/dart_conversion.dart';
import 'package:dart_conversion/my_logger.dart';

final listTransformer = <Type, ListTransformer>{
  List<int>: ListTransformer<int>(IntTransformer()),
  List<String>: ListTransformer<String>(StringTransformer()),
  List<double>: ListTransformer<double>(DoubleTransformer()),
  List<bool>: ListTransformer<bool>(BoolTransformer()),
};

final mapTransformers = <Type, MapTransformer>{
  Map<String, dynamic>: MapTransformer<String, dynamic>(),
  Map<String, String>: MapTransformer<String, String>(),
  Map<String, int>: MapTransformer<String, int>(),
  Map<String, double>: MapTransformer<String, double>(),
  Map<String, bool>: MapTransformer<String, bool>(),
  Map<int, dynamic>: MapTransformer<int, dynamic>(),
  Map<int, String>: MapTransformer<int, String>(),
  Map<int, int>: MapTransformer<int, int>(),
  Map<int, double>: MapTransformer<int, double>(),
  Map<int, bool>: MapTransformer<int, bool>(),
  Map<double, dynamic>: MapTransformer<double, dynamic>(),
  Map<double, String>: MapTransformer<double, String>(),
  Map<double, int>: MapTransformer<double, int>(),
  Map<double, double>: MapTransformer<double, double>(),
  Map<double, bool>: MapTransformer<double, bool>(),
  Map<bool, dynamic>: MapTransformer<bool, dynamic>(),
  Map<bool, String>: MapTransformer<bool, String>(),
  Map<bool, int>: MapTransformer<bool, int>(),
  Map<bool, double>: MapTransformer<bool, double>(),
  Map<bool, bool>: MapTransformer<bool, bool>(),
};
final transformers = <Type, Transformer>{
  bool: BoolTransformer(),
  int: IntTransformer(),
  String: StringTransformer(),
  double: DoubleTransformer(),
  ...listTransformer,
  ...mapTransformers
};

class BoolTransformer extends Transformer<bool> {
  @override
  bool transformValue(dynamic value) {
    if (value is bool) {
      return value;
    } else if (value is num) {
      if (value.toInt() > 1 || value.toInt() < 0) {
        throw TransformerException(
            "Value $value of type ${value.runtimeType} is not a valid boolean representation as it is not 1 or 0",
            value);
      }
      return value.toInt() == 1;
    } else if (value is String) {
      return value.toLowerCase() == 'true';
    }
    throw TransformerException(
        "Value $value of type ${value.runtimeType} cannot be transformed to an bool",
        value);
  }
}

class DoubleTransformer extends Transformer<double> {
  @override
  double transformValue(dynamic value) {
    if (value is double) {
      return value;
    } else if (value is num) {
      return value.toDouble();
    } else if (value is String) {
      return double.parse(value);
    }
    throw TransformerException(
        "Value $value of type ${value.runtimeType} cannot be transformed to an double",
        value);
  }
}

class IntTransformer extends Transformer<int> {
  @override
  int transformValue(dynamic value) {
    if (value is int) {
      return value;
    } else if (value is num) {
      return value.toInt();
    } else if (value is bool) {
      return value ? 1 : 0;
    } else if (value is String) {
      return int.parse(value);
    }
    throw TransformerException(
        "Value $value of type ${value.runtimeType} cannot be transformed to an int",
        value);
  }
}

class ListTransformer<T> extends Transformer<List<T>> {
  final Transformer<T> transformer;

  ListTransformer(this.transformer);

  @override
  List<T> transformValue(dynamic value) {
    if (value is List) {
      return value.map((e) => transformer.transform(e)).toList();
    }
    return value;
  }
}

class MapTransformer<KeyType, ValueType>
    extends Transformer<Map<KeyType, ValueType>> {
  @override
  Map<KeyType, ValueType> transformValue(dynamic value) {
    if (value is String) {
      myLogger.d(
          "Value $value of type ${value.runtimeType} will be interpreted as an json map",
          header: "MapTransformer<$KeyType, $ValueType>");

      final map = jsonDecode(value);
      if (map is Map) {
        return transformValue(map);
      } else {
        throw TransformerException(
            "Value $value of type ${value.runtimeType} cannot be transformed to an Map<$KeyType, $ValueType>",
            value);
      }
    }
    if (value is Map) {
      if (value.runtimeType == Map<KeyType, ValueType>) {
        return value.cast<KeyType, ValueType>();
      }
      if (KeyType != dynamic) {
        final keyTransformer = transformers[KeyType];
        if (keyTransformer == null) {
          throw TransformerException(
              "No transformer found for key type $KeyType", value);
        }
        if (ValueType != dynamic) {
          final valueTransformer = transformers[ValueType];
          if (valueTransformer == null) {
            throw TransformerException(
                "No transformer found for value type $ValueType", value);
          }
          return value.map((key, value) => MapEntry(
              keyTransformer.transform(key),
              valueTransformer.transform(value)));
        } else {
          return value.map(
              (key, value) => MapEntry(keyTransformer.transform(key), value));
        }
      } else if (ValueType != dynamic) {
        final valueTransformer = transformers[ValueType];
        if (valueTransformer == null) {
          throw TransformerException(
              "No transformer found for value type $ValueType", value);
        }
        return value.map(
            (key, value) => MapEntry(key, valueTransformer.transform(value)));
      } else {
        myLogger.w(
            "No KeyType and ValueType found for MapTransformer. Returning value $value of type ${value.runtimeType} as it is.",
            header: "MapTransformer<$KeyType, $ValueType>");
        return value.cast<KeyType, ValueType>();
      }
    }

    throw TransformerException(
        "Value $value of type ${value.runtimeType} cannot be transformed to an Map<$KeyType, $ValueType>",
        value);
  }
}

class StringTransformer extends Transformer<String> {
  @override
  String transformValue(dynamic value) {
    if (value is String) {
      return value;
    } else if (value is Map || value is List) {
      return jsonEncode(value);
    }
    return value.toString();
  }
}

abstract class Transformer<TransformTo> {
  TransformTo transform(dynamic value) {
    final transformation = transformValue(value);
    ConversionService.logger.i(
        'Transformed $value of type ${value.runtimeType} to $transformation of type ${transformation.runtimeType}',
        header: runtimeType.toString());
    return transformation;
  }

  TransformTo transformValue(dynamic value);
}

class TransformerException extends FormatException {
  TransformerException(super.message, super.source);
  @override
  String toString() => message;
}
