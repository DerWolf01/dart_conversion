import 'package:reflectable/reflectable.dart';

extension ClassMirrorExtension on ClassMirror {
  Map<String, DeclarationMirror> get instanceMemberDeclarationVariables {
    final Map<String, DeclarationMirror> declarations = {};

    declarations.addAll(Map.fromEntries(this.declarations.entries.where(
          (element) => element.value is VariableMirror,
        )));
    if (superclass != null) {
      declarations.addAll(superclass!.instanceMemberDeclarationVariables);
    }

    return declarations;
  }
}

extension MapEntryIterableExtension on Iterable<MapEntry> {
  Map toMap<K, V>() =>
      Map<K, V>.fromEntries(cast<MapEntry<K, V>>()).cast<K, V>();
}
