import 'package:dart_conversion/collection_of.dart';
import 'package:dart_conversion/my_logger.dart';
import 'package:reflectable/reflectable.dart';

/// This extension is used to define some extra methods and getters to simplify the work with class mirrors
extension ClassMirrorExtension on ClassMirror {
  /// This method extracts the attributes of the class
  Map<String, VariableMirror> get variables {
    final Map<String, VariableMirror> declarations = {};
    print(this.declarations);
    for (final declaration in this.declarations.entries) {
      if (declaration.value is VariableMirror) {
        declarations[declaration.key] = declaration.value as VariableMirror;
      }
    }

    if (superclass != null) {
      declarations.addAll(superclass!.variables);
    }

    return declarations;
  }

  /// Finds class attributes using a list of names to be searched for
  Map<String, VariableMirror> findFields(List<String> names) => Map.fromEntries(
      variables.entries.where((element) => names.contains(element.key)));

  /// Finds 1 class attribute using a name to be searched for
  VariableMirror? findField(String name) => variables.entries
      .where((element) => name.contains(element.key))
      .firstOrNull
      ?.value;

  List<TypeMirror>? findTypeArguments(String fieldName) =>
      findField(fieldName)?.type.typeArguments;

  TypeMirror? findTypeArgument(String fieldName, int position) =>
      findField(fieldName)?.type.typeArguments.elementAtOrNull(position);

  CollectionOf? getCollectionOfUsingName(
    String name,
  ) {
    try {
      final field = findField(name);
      if (field == null) {
        throw ClassMirrorExtensionException(
            "No field with name ”$name\" was found in class $simpleName");
      }
      final typeArguments = field.type.typeArguments;

      if (typeArguments.isEmpty) {
        return null;
      }
      if (field.type.reflectedType.toString().startsWith("Map") == true) {
        return CollectionOf(
            keyType: typeArguments.firstOrNull?.reflectedType,
            valueType: typeArguments[1].reflectedType);
      }

      return CollectionOf(valueType: typeArguments.first.reflectedType);
    } catch (e) {
      myLogger.d(e, header: "ClassMirrorExtension.getCollectionOfUsingName");
    }
    return null;
  }
}

class ClassMirrorExtensionException implements Exception {
  ClassMirrorExtensionException(this.message);

  final String message;
  @override
  String toString() => "$runtimeType($message)";
}
