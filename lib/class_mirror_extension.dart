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
  VariableMirror? findField(List<String> names) => variables.entries
      .where((element) => names.contains(element.key))
      .firstOrNull
      ?.value;
}
