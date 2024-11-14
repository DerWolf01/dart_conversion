import 'class_mirror_extension.dart';
import 'package:reflectable/reflectable.dart';

extension RefelctableExtension on InstanceMirror {
  Map<String, VariableMirror> get variables => type.variables;
}
