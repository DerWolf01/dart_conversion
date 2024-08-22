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
      print("converting $value to $t");
      if (value == null) {
        map[fieldName] = null;
      } else if (t is File || t == File || value is File) {
        map[fieldName] = base64.encode((value as File).readAsBytesSync());
      } else if (isPrimitive(t) ||
          value is Map<String, dynamic> ||
          value is DateTime) {
        map[fieldName] = value;
      } else if (value is List) {
        if (value.isEmpty) {
          map[fieldName] = [];
          continue;
        }
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
      print("converting $value to ${dec.type.reflectedType}");
      if (value.runtimeType == dec.type.reflectedType) {
        instance.setField(key, value);
        continue;
      } else if (value == null) {
        try {
          instance.setField(key, null);
        } catch (e, s) {
          print(e);
          print(s);
          throw Exception("Field ${MirrorSystem.getName(key)} is not nullable");
        }
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
        print("Converting primitive $value to ${dec.type.reflectedType}");
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
      print("Converting primitive $value to $t");
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

  static isIntList(List object) => object.every(
        (element) => element is int || element == int,
      );
}
