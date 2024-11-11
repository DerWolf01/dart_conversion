import 'dart:io';

import 'package:dart_conversion/class_mirror_extension.dart';
import 'package:dart_conversion/convertable.dart';
import 'dart:core';
import 'package:reflectable/reflectable.dart';
import './dart_conversion.reflectable.dart';

@convertable
class TestUser {
  const TestUser(this.name, this.friendNames);
  final String name;
  final List<String> friendNames;
}

void main() async {
  initializeReflectable();

  return;
  print((convertable.reflectType(TestUser) as ClassMirror).variables);

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
