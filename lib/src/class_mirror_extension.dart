import 'collection_of.dart';
import 'my_logger.dart';
import 'package:reflectable/reflectable.dart';

/// This extension is used to define some extra methods and getters to simplify the work with class mirrors
extension ClassMirrorExtension on ClassMirror {
  /// This method extracts the attributes of the class
  Map<String, VariableMirror> get variables {
    final Map<String, VariableMirror> declarations = {};
    print(this.declarations);
    for (final declaration in this.declarations.entries) {
      if (declaration.value is VariableMirror) {
        myLogger.d(
            "Found class attribute with name ${declaration.key} and metadata ${declaration.value.metadata}");
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
  VariableMirror? findField(String name) =>
      findFields([name]).values.firstOrNull;

  List<TypeMirror>? findTypeArguments(String fieldName) =>
      findField(fieldName)?.type.typeArguments;

  TypeMirror? findTypeArgument(String fieldName, int position) =>
      findField(fieldName)?.type.typeArguments.elementAtOrNull(position);

  CollectionOf? getCollectionOfUsingName(
    String name,
  ) {
    CollectionOf? collectionOf;
    try {
      final field = findField(name);
      if (field == null) {
        throw ClassMirrorExtensionException(
            "No field with name ”$name\" was found in class $simpleName");
      }

      final metadata = field.metadata;

      collectionOf = metadata.whereType<CollectionOf>().firstOrNull;

      if (collectionOf == null) {
        myLogger.d(
            "No @CollectionOf metadata found for the field $name of class $simpleName. This is the metadata list $metadata.");
        return null;
      }

      // /// If the keyType of the Map is not being defined in the @CollectionOf anotation the library will dynamically generate it.
      // if (field.type.reflectedType.toString().startsWith("Map") == true) {
      //   if (collectionOf.keyType != null) {
      //     return collectionOf;
      //   }
      //   return CollectionOf(
      //       keyType: typeArguments.firstOrNull?.reflectedType,
      //       valueType: collectionOf.runtimeType);
      // }

      return collectionOf;
    } catch (e, s) {
      myLogger.e(e,
          header: "ClassMirrorExtension.getCollectionOfUsingName",
          stackTrace: s);
    }
    return collectionOf;
  }
}

class ClassMirrorExtensionException implements Exception {
  ClassMirrorExtensionException(this.message);

  final String message;
  @override
  String toString() => "$runtimeType($message)";
}
