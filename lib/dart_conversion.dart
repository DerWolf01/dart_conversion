library dart_conversion;

export "./dart_conversion.dart";
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:mirrors';
import 'dart:typed_data';

class MethodParameters {
  final List<dynamic> args;
  final Map<String, dynamic> namedArgs;

  MethodParameters(this.args, this.namedArgs);
}

class ConversionService {
  static MethodParameters methodArgumentsByMap(
      {required MethodMirror method, required Map<String, dynamic> map}) {
    List<dynamic> args = [];
    Map<String, dynamic> namedArgs = {};
    for (final param in method.parameters) {
      final type = param.type.reflectedType;
      final name = MirrorSystem.getName(param.simpleName);
      if (param.isNamed) {
        if (map.containsKey(name)) {
          if (type == File) {
            final f = File("random.file");
            f.writeAsBytesSync(Uint8List.fromList(map[name]));
            namedArgs[name] = f;
          } else if (type == int) {
            namedArgs[name] = int.parse(map[name]);
          } else if (type == double) {
            namedArgs[name] = double.parse(map[name]);
          } else if (type == bool) {
            namedArgs[name] = map[name] == "true";
          } else if (type == String) {
            namedArgs[name] = map[name].toString();
          } else if (type == List) {
            namedArgs[name] = map[name].map((e) => e).toList();
          } else {
            namedArgs[name] = mapToObject(map[name], type: type);
          }
        } else {
          namedArgs[name] = null;
        }
      }

      if (map.containsKey(name)) {
        if (type == File) {
          final f = File("random.file");
          f.writeAsBytesSync(Uint8List.fromList(map[name]));
          args.add(f);
        } else if (type == int) {
          args.add(int.parse(map[name]));
        } else if (type == double) {
          args.add(double.parse(map[name]));
        } else if (type == bool) {
          args.add(map[name] == "true");
        } else if (type == String) {
          args.add(map[name]);
        } else if (type == List) {
          args.add(map[name].map((e) => e).toList());
        } else {
          args.add(mapToObject(map[name], type: type));
        }
      } else {
        args.add(null);
      }
    }
    return MethodParameters(args, namedArgs);
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

  static Map<String, dynamic> objectToMap(dynamic object) {
    var mirror = reflect(object);
    var classMirror = mirror.type;

    var map = <String, dynamic>{};

    for (final entry in declarations(classMirror).entries) {
      final declaration = entry.value;
      final name = entry.key;
      if (declaration is VariableMirror && !declaration.isStatic) {
        print(
            "name: $name declaration: $declaration value: ${mirror.getField(name).reflectee} ${(declaration).type.reflectedType}");

        var fieldName = MirrorSystem.getName(name);
        var fieldValue = mirror.getField(name).reflectee;
        if (fieldValue == null && isNullable(declaration.type)) {
          map[fieldName] = null;
          continue;
        } else if (isPrimitive(fieldValue)) {
          if (fieldValue.runtimeType == declaration.type.reflectedType) {
            map[fieldName] = fieldValue;
          } else {
            map[fieldName] =
                convertUsingType(fieldValue, declaration.type.reflectedType);
          }
        } else if (fieldValue is File) {
          map[fieldName] = base64.encode(fieldValue.readAsBytesSync());
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

    InstanceMirror instance = classMirror.newInstance(Symbol(""), []);
    for (final decEntry in declarations(classMirror).entries) {
      final key = decEntry.key;
      final dec = decEntry.value as VariableMirror;

      final value = map[MirrorSystem.getName(key)];
      print(
          "key: $key dec: $dec type: ${dec.type.reflectedType} valueType: ${value.runtimeType}");
      if (classMirror.reflectedType is File ||
          classMirror.reflectedType == File && value is List) {
        final f = File("random.file");
        f.writeAsBytesSync(Uint8List.fromList(value));
        instance.setField(key, f);
        continue;
      }
      if (value == null && isNullable(dec.type)) {
        instance.setField(key, null);
        continue;
      } else if (dec.type.reflectedType == File) {
        try {
          final f = File("./random.file");

          f.writeAsBytesSync(base64.decode(value));
          instance.setField(key, f);

          continue;
        } catch (e) {
          print(e);
        }
      } else if (isPrimitive(dec.type.reflectedType)) {
        if (value.runtimeType == dec.type.reflectedType) {
          instance.setField(key, value);
          continue;
        }
        instance.setField(key, convertUsingType(value, dec.type.reflectedType));
      } else if (value is List) {
        instance.setField(
            key,
            value
                .map((e) => mapToObject(e, type: dec.type.reflectedType))
                .toList());
      } else if (value is Map<String, dynamic>) {
        instance.setField(
            key, mapToObject(value, type: dec.type.reflectedType));
      } else {
        if (value.runtimeType == dec.type.reflectedType) {
          instance.setField(key, value);
          continue;
        }
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
  static T? convert<T>(dynamic body) {
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

  static dynamic convertUsingType(dynamic body, Type T) {
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

    return mapToObject(jsonDecode(body), type: T);
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

  static bool isImage(dynamic object) => object is File;

  static bool isPrimitive(dynamic object) => (object is String ||
      object is num ||
      object is int ||
      object is double ||
      object is bool ||
      object is List<String> ||
      object is List<int> ||
      object is List<bool> ||
      object is Null ||
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
