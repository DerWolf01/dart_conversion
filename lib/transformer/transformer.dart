import 'dart:convert';

import 'package:dart_conversion/dart_conversion.dart';

final transformers = <Type, Transformer>{
  bool: BoolTransformer(),
  int: IntTransformer(),
  String: StringTransformer(),
  double: DoubleTransformer(),
  List<int>: ListTransformer<int>(IntTransformer()),
  List<String>: ListTransformer<String>(StringTransformer()),
  List<double>: ListTransformer<double>(DoubleTransformer()),
  List<bool>: ListTransformer<bool>(BoolTransformer()),
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
