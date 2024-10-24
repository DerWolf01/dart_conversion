library dart_conversion;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:mirrors';
import 'dart:typed_data';

import 'package:dart_conversion/list_of.dart';
import 'package:dart_conversion/my_logger.dart';

export "./dart_conversion.dart";
export "./method_service.dart";
export 'list_of.dart';

class ConversionException extends FormatException {
  ConversionException(
    super.message,
  );
}

/// A service that provides methods for converting objects into many different formats.
class ConversionService {
  static final MyLogger logger = MyLogger.init(enabled: true);

  /// Creates a new instance of the ConversionService. Useful for implementing extensions. Otherwise you should use the static methods.
  const ConversionService();

  ConversionService.disableLogging() {
    ConversionService.logger.enabled = true;
  }
  ConversionService.enableLogging() {
    ConversionService.logger.enabled = false;
  }
  static dynamic convert<T>({Type? type, dynamic value}) {
    final t = type ?? T;

    if (value == null) {
      ConversionService.logger.d(
        "Cannot convert null value to $t",
        header: "Value is null",
      );
      return null;
    } else if (t is File || t == File) {
      if (value is! List || value is! String) {
        ConversionService.logger.e(
          "File should be a list of bytes or base64 encoded string",
          header: "Invalid file format",
        );
        throw Exception(
            "File should be a list of bytes or base64 encoded string");
      }
      if (value is String) {
        ConversionService.logger
            .i("$value --> File", header: "Converting base64 string to file");
        final f = File("random.file");
        f.writeAsBytesSync(base64Decode(value as String));

        ConversionService.logger.i("$f", header: "File converted");
        return f;
      }

      final f = File("random.file");
      f.writeAsBytesSync(value.whereType<int>().toList());
      ConversionService.logger.i("$f", header: "File converted");
      return f;
    } else if (isPrimitive(t)) {
      if (value.runtimeType == t) {
        ConversionService.logger
            .i("$value --> $t", header: "Value is already of type $t");
        return value;
      }

      ConversionService.logger.i("$value --> $t",
          header: "Converting value to $t using convertPrimitive");
      return convertPrimitive(value, t);
    } else if (value is List) {
      if (value.isEmpty) {
        ConversionService.logger.i("[] --> List<$t", header: "Empty list");
        return [];
      }
      ConversionService.logger
          .i("$value --> List<$t", header: "Converting list to List<$t>");
      return value.map((e) => mapToObject(e, type: t)).toList();
    } else if (value is Map<String, dynamic>) {
      ConversionService.logger
          .i("$value --> $t", header: "Converting map to $t");
      return mapToObject(value, type: t);
    } else {
      ConversionService.logger
          .i("$value --> $t", header: "Converting object to $t");
      if (value.runtimeType == t) {
        return value;
      }

      ConversionService.logger
          .i("$value --> $t", header: "Converting object to $t");
      return objectToMap(value);
    }
  }

  static dynamic convertPrimitive(dynamic body, Type T) {
    if (T == List<String>) {
      return (body as List).map((e) => e.toString()).toList();
    }
    if (T == List<int>) {
      return (body as List).map((e) => int.parse(e.toString())).toList();
    }
    if (T == List<double>) {
      return (body as List).map((e) => double.parse(e.toString())).toList();
    }
    if (T == List<num>) {
      return (body as List).map((e) => num.parse(e.toString())).toList();
    }
    if (T == List<bool>) {
      return (body as List).map((e) => e == "true").toList();
    }
    if (T == dynamic) {
      return jsonDecode(body);
    }
    if (T == File) {
      return File.fromRawPath(Uint8List.fromList(jsonDecode(body)));
    }
    if (T == String) {
      return body;
    } else if (T == int) {
      return int.parse(body);
    } else if (T == double) {
      return double.parse(body);
    } else if (T == bool) {
      return (body == "true");
    }
  }

  static Map<Symbol, DeclarationMirror> declarations(ClassMirror classMirror) {
    Map<Symbol, DeclarationMirror> decs = {...classMirror.declarations};
    ClassMirror? superClass = classMirror.superclass;
    while (superClass != null) {
      decs.addAll(superClass.declarations);
      superClass = superClass.superclass;
    }
    return Map.fromEntries(decs.entries.where(
      (entry) => entry.value is VariableMirror,
    ));
  }

  static String encodeJSON(dynamic object) {
    if (isPrimitive(object)) {
      return jsonEncode(object);
    }
    final map = objectToMap(object, json: true);

    late final String json;

    try {
      json = jsonEncode(map);
    } catch (e, s) {
      ConversionService.logger
          .e(e, stackTrace: s, header: "Couldn't encode object to JSON");
    }

    return json;
  }

  static bool isImage(dynamic object) => object is File;

  static isIntList(List object) => object.every(
        (element) => element is int || element == int,
      );

  static bool isPrimitive(dynamic object) => (object is String ||
      object is num ||
      object is int ||
      object is double ||
      object is bool ||
      object is List<String> ||
      object is List<int> ||
      object is List<bool> ||
      object == String ||
      object == num ||
      object == int ||
      object == double ||
      object == bool ||
      object == (List<String>) ||
      object == (List<int>) ||
      object == (List<double>) ||
      object == (List<num>) ||
      object == null ||
      object == (List<bool>));

  /// Converts a JSON string to an object of type T.
  ///
  /// \param body The JSON string to convert.
  /// \return An instance of type T.
  static dynamic jsonToObject<T>(dynamic body, {Type? type}) {
    final t = type ?? T;
    if (t == dynamic) {
      return jsonDecode(body);
    }
    if (t == String) {
      return body;
    } else if (t == int) {
      return int.parse(body);
    } else if (t == double) {
      return double.parse(body);
    } else if (t == bool) {
      return (body == "true");
    }

    return mapToObject<T>(jsonDecode(body));
  }

  static T mapToObject<T>(Map<String, dynamic> map, {Type? type}) {
    var classMirror = reflectClass(type ?? T);

    final declarations = ConversionService.declarations(classMirror);
    final mapIncludesAllValues = declarations.keys.every(
      (element) => map.keys.contains(MirrorSystem.getName(element)),
    );
    InstanceMirror instance = classMirror.newInstance(Symbol(""), []);
    for (final decEntry in declarations.entries) {
      final key = decEntry.key;
      final dec = decEntry.value as VariableMirror;

      final dynamic value = map[MirrorSystem.getName(key)];

      if (value.runtimeType == dec.type.reflectedType) {
        instance.setField(key, value);
        continue;
      } else if (value == null) {
        try {
          instance.setField(key, null);
        } catch (e, s) {
          ConversionService.logger
              .e(e, stackTrace: s, header: "Couldn't set field to null");
          throw ConversionException("${MirrorSystem.getName(key)} is missing");
        }
        continue;
      } else if (dec.type.reflectedType == DateTime) {
        if (value is DateTime) {
          instance.setField(key, value);
        } else if (value is String) {
          instance.setField(key, DateTime.parse(value));
        } else if (value is int) {
          instance.setField(key, DateTime.fromMillisecondsSinceEpoch(value));
        } else {
          throw Exception("Invalid date format $value: ${value.runtimeType}");
        }
      } else if (dec.type.reflectedType == File ||
          dec.type.reflectedType is File) {
        try {
          final f = File("./random.file");
          if (value is! List) {
            throw Exception("File should be a list of bytes");
          }
          f.writeAsBytesSync(value.whereType<int>().toList());

          instance.setField(key, f);

          continue;
        } catch (e, s) {
          ConversionService.logger
              .e(e, stackTrace: s, header: "Couldn't set file");
          throw ConversionException("Couldn't set file");
        }
      } else if (isPrimitive(dec.type.reflectedType)) {
        if (value.runtimeType == dec.type.reflectedType) {
          instance.setField(key, value);
          continue;
        }

        instance.setField(key, convertPrimitive(value, dec.type.reflectedType));
      } else if (dec.type.isAssignableTo(reflectClass(DateTime)) ||
          dec.type.isSubtypeOf(reflectClass(DateTime)) ||
          dec.type.reflectedType == DateTime) {
        try {
          if (value is String) {
            instance.setField(key, DateTime.parse(value));
          } else if (value is int) {
            instance.setField(key, DateTime.fromMillisecondsSinceEpoch(value));
          } else if (value is DateTime) {
            instance.setField(key, value);
          } else {
            throw FormatException(
                "Invalid date format $value: ${value.runtimeType}");
          }
        } catch (e, s) {
          ConversionService.logger
              .e(e, stackTrace: s, header: "Couldn't set date");
        }
        continue;
      } else if (value is List) {
        if (value.isEmpty) {
          continue;
        }

        final listTypeArgument =
            dec.type.typeArguments.firstOrNull?.reflectedType;
        final listOfAnotation =
            dec.metadata.where((e) => e.reflectee is ListOf).firstOrNull;
        if (listOfAnotation == null) {
          throw Exception(
              "Field ${MirrorSystem.getName(key)} of type List<$listTypeArgument> in class ${dec.type.reflectedType} has to be anotated with @ListOf(type) to ensure conversion");
        }
        if (listTypeArgument != dynamic) {
          throw Exception(
              "Field ${MirrorSystem.getName(key)} of type List<$listTypeArgument> in class ${dec.type.reflectedType} should have a type argument of dynamic and should be anotated with @ListOf(type) to ensure conversion");
        }

        final listEntries = value
            .map((e) =>
                mapToObject(e, type: listOfAnotation.getField(#type).reflectee))
            .toList();

        instance.setField(key, listEntries);
      } else {
        instance.setField(
            key, mapToObject(value, type: dec.type.reflectedType));
      }
    }
    return instance.reflectee as T;
  }

  static Map<String, dynamic> objectToMap(dynamic object, {bool json = false}) {
    var mirror = reflect(object);
    var classMirror = mirror.type;

    var map = <String, dynamic>{};
    for (final entry in declarations(classMirror).entries) {
      final declaration = entry.value;
      final name = entry.key;
      if (!(declaration is VariableMirror && !declaration.isStatic)) {
        continue;
      }
      final t = declaration.type.reflectedType;

      var fieldName = MirrorSystem.getName(name);
      var value = mirror.getField(name).reflectee;

      if (value == null) {
        map[fieldName] = null;
      } else if (t is DateTime || t == DateTime || value is DateTime) {
        if (json) {
          map[fieldName] = (value as DateTime).toIso8601String();
          continue;
        } else {
          map[fieldName] = (value as DateTime);
          continue;
        }
      } else if (t is File || t == File || value is File) {
        final bytes = (value as File).readAsBytesSync();
        map[fieldName] = bytes.toList();
        continue;
      } else if (isPrimitive(t) ||
          value is Map<String, dynamic> ||
          value is DateTime) {
        map[fieldName] = value;
        continue;
      } else if (value is List) {
        if (value.isEmpty) {
          map[fieldName] = [];
          continue;
        }
        map[fieldName] = value.map((e) => objectToMap(e, json: json)).toList();
        continue;
      } else {
        map[fieldName] = objectToMap(value, json: json);
      }
    }
    return map;
  }

  static Future<Map<String, dynamic>> requestToMap(HttpRequest request) async {
    final body = await utf8.decodeStream(request);
    return jsonDecode(body);
  }

  static Future<T> requestToObject<T>(HttpRequest request, {Type? type}) async {
    try {
      final body = await requestToRequestDataMap(request);

      return mapToObject<T>(body, type: type);
    } catch (e, s) {
      ConversionService.logger
          .e(e, stackTrace: s, header: "Couldn't convert request to object");
      throw ConversionException("Couldn't convert request to object");
    }
  }

  static FutureOr<Map<String, dynamic>> requestToRequestDataMap(
      HttpRequest request,
      {Type? type}) async {
    return request.method == "GET"
        ? request.uri.queryParameters
        : jsonDecode(await utf8.decodeStream(request));
  }
}
