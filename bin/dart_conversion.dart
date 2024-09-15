import 'dart:io';

import 'package:dart_conversion/dart_conversion.dart';

void main() async {
  final json = ConversionService.encodeJSON(ProfilePicture.init(
      File("randome.txt")..writeAsStringSync("adsasdasds")));

  print(json);

  final object = ConversionService.jsonToObject<ProfilePicture>(json);
  print(object?.file);
}

class ProfilePicture {
  late File? file;
  ProfilePicture();
  ProfilePicture.init(this.file);
}
