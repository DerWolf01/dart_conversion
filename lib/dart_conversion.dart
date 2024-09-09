library dart_conversion;

export "./dart_conversion.dart";
export "./method_service.dart";
export 'list_of.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:mirrors';
import 'dart:typed_data';

import 'package:dart_conversion/list_of.dart';
import 'package:dart_conversion/method_service.dart';

class ConversionService {
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

  static Map<String, dynamic> objectToMap(dynamic object) {
    var mirror = reflect(object);
    var classMirror = mirror.type;

    var map = <String, dynamic>{};
    print("objectToMap --> ${classMirror.name}");

    for (final entry in declarations(classMirror).entries) {
      final declaration = entry.value;
      final name = entry.key;
      if (!(declaration is VariableMirror && !declaration.isStatic)) {
        continue;
      }
      final t = declaration.type.reflectedType;

      var fieldName = MirrorSystem.getName(name);
      var value = mirror.getField(name).reflectee;

      print("objectToMap --> $fieldName --> ${value}");
      if (value == null) {
        map[fieldName] = null;
      } else if (t is File || t == File || value is File) {
        final bytes = (value as File).readAsBytesSync();
        map[fieldName] = base64Encode(bytes);
      } else if (isPrimitive(t) ||
          value is Map<String, dynamic> ||
          value is DateTime) {
        map[fieldName] = value;
      } else if (value is List) {
        if (value.isEmpty) {
          map[fieldName] = [];
          continue;
        }
        map[fieldName] = value.map((e) => objectToMap(e)).toList();
      } else {
        map[fieldName] = objectToMap(value);
      }
    }
    return map;
  }

  static T mapToObject<T>(Map<String, dynamic> map, {Type? type}) {
    var classMirror = reflectClass(type ?? T);
    print("converting $map to $classMirror");
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
          print(e);
          print(s);
          throw ConversionException("${MirrorSystem.getName(key)} is missing");
        }
        continue;
      } else if (dec.type.reflectedType == File ||
          dec.type.reflectedType is File) {
        try {
          final f = File("./random.file");

          f.writeAsBytesSync(base64Decode(value));

          instance.setField(key, f);

          continue;
        } catch (e, s) {
          print(e);
          print(s);
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
          print(e);
          print(s);
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
        print("Set $listEntries for ${MirrorSystem.getName(key)}");
        instance.setField(key, listEntries);
      } else {
        instance.setField(
            key, mapToObject(value, type: dec.type.reflectedType));
      }
    }
    return instance.reflectee as T;
  }

  static Future<Map<String, dynamic>> requestToMap(HttpRequest request) async {
    final body = await utf8.decodeStream(request);
    return jsonDecode(body);
  }

  static Future<T> requestToObject<T>(HttpRequest request, {Type? type}) async {
    return mapToObject<T>(await requestToRequestDataMap(request), type: type);
  }

  static Future<Map<String, dynamic>> requestToRequestDataMap(
      HttpRequest request,
      {Type? type}) async {
    return request.method == "GET"
        ? request.uri.queryParameters
        : jsonDecode(await utf8.decodeStream(request));
  }

  static dynamic convert<T>({Type? type, dynamic value}) {
    final t = type ?? T;

    if (value == null) {
      return null;
    } else if (t is File || t == File) {
      final f = File("random.file");
      f.writeAsBytesSync(Uint8List.fromList(value));

      return f;
    } else if (isPrimitive(t)) {
      if (value.runtimeType == t) {
        return value;
      }

      return convertPrimitive(value, t);
    } else if (value is List) {
      if (value.isEmpty) {
        return [];
      }
      return value.map((e) => mapToObject(e, type: t)).toList();
    } else if (value is Map<String, dynamic>) {
      return mapToObject(value, type: t);
    } else {
      if (value.runtimeType == t) {
        return value;
      }

      return objectToMap(value);
    }
  }

  /// Converts a JSON string to an object of type T.
  ///
  /// \param body The JSON string to convert.
  /// \return An instance of type T.
  static T? jsonToObject<T>(dynamic body) {
    if (T == dynamic) {
      return jsonDecode(body) as T;
    }
    if (T == String) {
      return body as T;
    } else if (T == int) {
      return int.parse(body) as T;
    } else if (T == double) {
      return double.parse(body) as T;
    } else if (T == bool) {
      return (body == "true") as T;
    }

    return mapToObject<T>(jsonDecode(body));
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

  static String encodeJSON(dynamic object) {
    if (isPrimitive(object)) {
      return jsonEncode(object);
    }
    final map = objectToMap(object);

    print("encodeJSON --> $map");
    late final String json;

    try {
      json = jsonEncode(map);
    } catch (e, s) {
      print(e);
      print(s);
    }
    print("Encoded $json");
    return json;
  }

  static bool isImage(dynamic object) => object is File;

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

  static isIntList(List object) => object.every(
        (element) => element is int || element == int,
      );
}

class ConversionException extends FormatException {
  ConversionException(
    super.message,
  );
}
