import 'dart:convert';

import 'package:dart_conversion/dart_conversion.old.dart';
import 'package:dart_conversion/my_logger.dart';

/// A list of transformers for List instances
const listTransformer = <Type, ListTransformer>{
  List<int>: ListTransformer<int>(IntTransformer()),
  List<String>: ListTransformer<String>(StringTransformer()),
  List<double>: ListTransformer<double>(DoubleTransformer()),
  List<bool>: ListTransformer<bool>(BoolTransformer()),
};

/// A list of constant map transformers which aims to provide transformation ability from different Key and Value types to a specific and different one
const mapTransformers = <Type, MapTransformer>{
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
  // List transformers
  Map<String, List<dynamic>>: MapTransformer<String, List<dynamic>>(),
  Map<String, List<String>>: MapTransformer<String, List<String>>(),
  Map<String, List<int>>: MapTransformer<String, List<int>>(),
  Map<String, List<double>>: MapTransformer<String, List<double>>(),
  Map<String, List<bool>>: MapTransformer<String, List<bool>>(),
  Map<int, List<dynamic>>: MapTransformer<int, List<dynamic>>(),
  Map<int, List<String>>: MapTransformer<int, List<String>>(),
  Map<int, List<int>>: MapTransformer<int, List<int>>(),
  Map<int, List<double>>: MapTransformer<int, List<double>>(),
  Map<int, List<bool>>: MapTransformer<int, List<bool>>(),
  Map<double, List<dynamic>>: MapTransformer<double, List<dynamic>>(),
  Map<double, List<String>>: MapTransformer<double, List<String>>(),
  Map<double, List<int>>: MapTransformer<double, List<int>>(),
  Map<double, List<double>>: MapTransformer<double, List<double>>(),
  Map<double, List<bool>>: MapTransformer<double, List<bool>>(),
  Map<bool, List<dynamic>>: MapTransformer<bool, List<dynamic>>(),
  Map<bool, List<String>>: MapTransformer<bool, List<String>>(),
  Map<bool, List<int>>: MapTransformer<bool, List<int>>(),
  Map<bool, List<double>>: MapTransformer<bool, List<double>>(),
  Map<bool, List<bool>>: MapTransformer<bool, List<bool>>(),
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
  const BoolTransformer();
  @override
  bool transformValue(dynamic value) {
    try {
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
        if (value[0] == "1" || value[0] == "0") {
          return int.parse(value[0]) == 1;
        }

        if (value.toLowerCase() == 'true') {
          return true;
        } else if (value.toLowerCase() == 'false') {
          return false;
        }
        throw TransformerException(
            "Value $value of type String is not a valid bool representation.",
            value);
      }
    } catch (e, s) {
      myLogger.e(e, stackTrace: s, header: "Transformer.transform");
      throw TransformerException(
          "Value $value of type ${value.runtimeType} cannot be transformed to an bool",
          value);
    }
    throw TransformerException(
        "Value $value of type ${value.runtimeType} cannot be transformed to an bool",
        value);
  }
}

class DoubleTransformer extends Transformer<double> {
  const DoubleTransformer();
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
  const IntTransformer();
  @override
  int transformValue(dynamic value) {
    try {
      if (value is int) {
        return value;
      } else if (value is num) {
        return value.toInt();
      } else if (value is bool) {
        return value ? 1 : 0;
      } else if (value is String) {
        final isBool = value == "true" || value == "false";

        if (isBool) {
          return BoolTransformer().transform(value) ? 1 : 0;
        }
        return int.parse(value);
      }
    } catch (e, s) {
      myLogger.e(e, stackTrace: s, header: "Transformer.transform");
      throw TransformerException(
          "Value $value of type ${value.runtimeType} cannot be transformed to an double",
          value);
    }
    throw TransformerException(
        "Value $value of type ${value.runtimeType} cannot be transformed to an int",
        value);
  }
}

class ListTransformer<T> extends Transformer<List<T>> {
  final Transformer<T> transformer;

  const ListTransformer(this.transformer);

  @override
  List<T> transformValue(dynamic value) {
    try {
      if (value is List) {
        return value.map((e) => transformer.transform(e)).toList();
      }
    } catch (e, s) {
      if (e is TransformerException) {
        rethrow;
      }
      myLogger.e(e, stackTrace: s, header: "Transformer.transform");
      throw TransformerException(
          "Value $value of type ${value.runtimeType} cannot be transformed to an double",
          value);
    }

    throw TransformerException(
        "Value $value of type ${value.runtimeType} cannot be transformed to an double",
        value);
  }
}

class MapTransformer<KeyType, ValueType>
    extends Transformer<Map<KeyType, ValueType>> {
  const MapTransformer();
  @override
  Map<KeyType, ValueType> transformValue(dynamic value) {
    try {
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
          myLogger.w(KeyType.toString());
          final keyTransformer = transformers[KeyType];
          if (keyTransformer == null) {
            throw TransformerException(
                "No transformer found for key type $KeyType", value);
          }
          if (ValueType != dynamic) {
            myLogger.w(ValueType.toString());

            final valueTransformer = transformers[ValueType];
            if (valueTransformer == null) {
              throw TransformerException(
                  "No transformer found for value type $ValueType", value);
            }

            return value.map((key, value) => MapEntry<KeyType, ValueType>(
                keyTransformer.transform(key),
                valueTransformer.transform(value)));
          } else {
            return value.map((key, value) => MapEntry<KeyType, ValueType>(
                keyTransformer.transform(key), value));
          }
        } else if (ValueType != dynamic) {
          final valueTransformer = transformers[ValueType];
          if (valueTransformer == null) {
            throw TransformerException(
                "No transformer found for value type $ValueType", value);
          }
          return value.map((key, value) => MapEntry<KeyType, ValueType>(
              key, valueTransformer.transform(value)));
        } else {
          myLogger.w(
              "No KeyType and ValueType found for MapTransformer. Returning value $value of type ${value.runtimeType} as it is.",
              header: "MapTransformer<$KeyType, $ValueType>");
          return value.cast<KeyType, ValueType>();
        }
      }
    } catch (e, s) {
      myLogger.e(e, stackTrace: s, header: "Transformer.transform");
      throw TransformerException(
          "Value $value of type ${value.runtimeType} cannot be transformed to an double",
          value);
    }
    throw TransformerException(
        "Value $value of type ${value.runtimeType} cannot be transformed to an double",
        value);
  }
}

class StringTransformer extends Transformer<String> {
  const StringTransformer();
  @override
  String transformValue(dynamic value) {
    try {
      if (value is String) {
        return value;
      } else if (value is Map || value is List) {
        return jsonEncode(value);
      }
      return value.toString();
    } catch (e, s) {
      myLogger.e(e, stackTrace: s, header: "Transformer.transform");
      throw TransformerException(
          "Value $value of type ${value.runtimeType} cannot be transformed to an double",
          value);
    }
  }
}

abstract class Transformer<TransformTo> {
  const Transformer();
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
