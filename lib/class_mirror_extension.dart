import 'package:reflectable/reflectable.dart';

extension ClassMirrorExtension on ClassMirror {
  Map<String, VariableMirror> get instanceMemberDeclarationVariables {
    final Map<String, VariableMirror> declarations = {};
    print(this.declarations);
    for (final declaration in this.declarations.entries) {
      if (declaration.value is VariableMirror) {
        declarations[declaration.key] = declaration.value as VariableMirror;
      }
    }

    if (superclass != null) {
      declarations.addAll(superclass!.instanceMemberDeclarationVariables);
    }

    return declarations;
  }

  Map<String, VariableMirror> findFields(List<String> names) =>
      Map.fromEntries(instanceMemberDeclarationVariables.entries
          .where((element) => names.contains(element.key)));

  VariableMirror? findField(List<String> names) =>
      instanceMemberDeclarationVariables.entries
          .where((element) => names.contains(element.key))
          .firstOrNull
          ?.value;
}

extension MapEntryIterableExtension on Iterable<MapEntry> {
  Map toMap<K, V>() =>
      Map<K, V>.fromEntries(cast<MapEntry<K, V>>()).cast<K, V>();
}
