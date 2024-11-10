import 'package:reflectable/reflectable.dart';

extension ConstructorExtension on ClassMirror {
  Map<String, MethodMirror> get constructors => Map.fromEntries(
      instanceMembers.entries.where((entry) => entry.value.isConstructor));

  MethodMirror? findConstructor(String name) => constructors[name];

  
}




