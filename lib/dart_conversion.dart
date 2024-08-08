library dart_conversion;

export "./dart_conversion.dart";
export "./method_service.dart";
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:mirrors';
import 'dart:typed_data';

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
        if (!isNullable(reflectType(t))) {
          throw Exception("Field $fieldName is not nullable");
        }

        map[fieldName] = null;
      } else if (t is File || t == File || value is File) {
        map[fieldName] = base64.encode((value as File).readAsBytesSync());
      } else if (isPrimitive(t) || value is Map<String, dynamic>) {
        map[fieldName] = value;
      } else if (value is List) {
        map[fieldName] = value.map((e) => mapToObject(e, type: t)).toList();
      } else {
        map[fieldName] = objectToMap(value);
      }
    }
    return map;
  }

  static T mapToObject<T>(Map<String, dynamic> map, {Type? type}) {
    var classMirror = reflectClass(type ?? T);

    InstanceMirror instance = classMirror.newInstance(Symbol(""), []);
    for (final decEntry in declarations(classMirror).entries) {
      final key = decEntry.key;
      final dec = decEntry.value as VariableMirror;

      final dynamic value = map[MirrorSystem.getName(key)];

      if (value.runtimeType == dec.type.reflectedType) {
        instance.setField(key, value);
        continue;
      } else if (value == null && isNullable(dec.type)) {
        instance.setField(key, null);
        continue;
      } else if (dec.type.reflectedType == File ||
          dec.type.reflectedType is File) {
        try {
          final f = File("./random.file");

          f.writeAsBytesSync(base64.decode(value));
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
      } else if (value is List) {
        instance.setField(
            key,
            value
                .map((e) => mapToObject(e, type: dec.type.reflectedType))
                .toList());
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

    if (value == null && isNullable(reflectType(t))) {
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

    late final String json;

    try {
      json = jsonEncode(map);
    } catch (e, s) {
      print(e);
      print(s);
    }
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

  static isNullable(TypeMirror type) =>
      (reflect(null).type.isSubtypeOf(type)) ||
      (reflect(null).type.isAssignableTo(type)) ||
      (type.reflectedType == Null) ||
      (type.reflectedType == dynamic);

  static isIntList(List object) => object.every(
        (element) => element is int || element == int,
      );
}
