library dart_conversion;

export "./dart_conversion.dart";
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:mirrors';

class ConversionService {
  static Map<String, dynamic> objectToMap(dynamic object) {
    var mirror = reflect(object);
    var classMirror = mirror.type;

    var map = <String, dynamic>{};

    for (final entry in classMirror.declarations.entries) {
      final declaration = entry.value;
      final name = entry.key;
      if (declaration is VariableMirror && !declaration.isStatic) {
        var fieldName = MirrorSystem.getName(name);
        var fieldValue = classMirror.getField(name).reflectee;
        if (isPrimitive(fieldValue)) {
          map[fieldName] = fieldValue;
        } else if (fieldValue is List) {
          map[fieldName] = fieldValue.map((e) => objectToMap(e)).toList();
        } else {
          map[fieldName] = objectToMap(fieldValue);
        }
      }
    }
    return map;
  }

  static T mapToObject<T>(Map<String, dynamic> map, {Type? type}) {
    var classMirror = reflectClass(type ?? T);

    InstanceMirror instance = classMirror.newInstance(
        Symbol(""),
        map
            .map(
              (key, value) {
                final type = classMirror.declarations[key] as VariableMirror;
                if (isPrimitive(type.type.reflectedType)) {
                  return MapEntry(key, value);
                } else if (value is List) {
                  return MapEntry(
                      key,
                      value
                          .map((e) =>
                              mapToObject(e, type: type.type.reflectedType))
                          .toList());
                } else if (value is Map<String, dynamic>) {
                  return MapEntry(
                      key, mapToObject(value, type: type.type.reflectedType));
                } else {
                  return MapEntry(key, value);
                }
              },
            )
            .values
            .toList());
    return instance.reflectee as T;
  }

  static Future<Map<String, dynamic>> requestToMap(HttpRequest request) async {
    final body = await utf8.decodeStream(request);
    return jsonDecode(body);
  }

  static Future<T> requestToObject<T>(HttpRequest request, {Type? type}) async {
    return request.method == "GET"
        ? mapToObject<T>(await uriParamsStreamToMap(request), type: type)
        : mapToObject<T>(jsonDecode(await utf8.decodeStream(request)),
            type: type);
  }

  static uriParamsStreamToMap(Stream<List<int>> stream) async {
    final body = await utf8.decodeStream(stream);
    print(body.split("&").map(
          (e) => MapEntry<String, dynamic>(e.split("=")[0], e.split("=")[1]),
        ));
    return Map<String, dynamic>.fromEntries(body.split("&").map(
          (e) => MapEntry<String, dynamic>(e.split("=")[0], e.split("=")[1]),
        ));
  }

  /// Converts a JSON string to an object of type T.
  ///
  /// \param body The JSON string to convert.
  /// \return An instance of type T.
  static Future<T?> convert<T>(dynamic body) async {
    if (T == dynamic) {
      return jsonDecode(body) as T;
    }
    if (T == String) {
      return body as T;
    } else if (T == int) {
      return int.parse(body) as T;
    } else if (T == double) {
      return double.parse(body) as T;
    } else if (T is bool) {
      return (body == "true") as T;
    }

    return mapToObject<T>(jsonDecode(body));
  }

  /// Converts an object to a JSON string or its string representation.
  ///
  /// \param object The object to convert.
  /// \return A JSON string or string representation of the object.
  static String convertToStringOrJson(dynamic object) {
    if (object is String || object is num || object is bool) {
      return object.toString();
    }
    try {
      return jsonEncode(objectToMap(object));
    } catch (e) {
      throw Exception(e);
    }
  }

  static bool isPrimitive(dynamic object) => (object is String ||
      object is num ||
      object is bool ||
      object is List<String> ||
      object is List<int> ||
      object is List<bool> ||
      object == String ||
      object == num ||
      object == bool ||
      object == (List<String>) ||
      object == (List<int>) ||
      object == (List<double>) ||
      object == (List<num>) ||
      object == (List<bool>));
}
