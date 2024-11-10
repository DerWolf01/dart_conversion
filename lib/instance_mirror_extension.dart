import 'package:dart_conversion/class_mirror_extension.dart';
import 'package:reflectable/reflectable.dart';

extension RefelctableExtension on InstanceMirror {
  Map<String, DeclarationMirror> get variables => type.variables;
}
