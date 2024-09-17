import 'dart:io';

import 'package:dart_conversion/dart_conversion.dart';

void main() async {
  final json = ConversionService.encodeJSON(DaeHolder());

  print(json);

  final object = ConversionService.jsonToObject<DaeHolder>(json);
  print(object);
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
