import 'dart:io';

import 'package:dart_conversion/class_mirror_extension.dart';
import 'package:dart_conversion/convertable.dart';

import 'package:reflectable/reflectable.dart';
import './dart_conversion.reflectable.dart';

@convertable
class TestUser {
  const TestUser(this.name);
  final String name;
}

void main() async {
  initializeReflectable();
  print((convertable.reflectType(TestUser) as ClassMirror)
      .instanceMemberDeclarationVariables);

  return;
}

class DaeHolder {
  DateTime date = DateTime.now();
  DaeHolder();
}

class ProfilePicture {
  late File? file;
  ProfilePicture();
  ProfilePicture.init(this.file);
}
