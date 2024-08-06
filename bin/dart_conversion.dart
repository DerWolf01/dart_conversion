import 'dart:io';

import 'package:dart_conversion/dart_conversion.dart';

void main() async {
  final f = await File("./hello.txt").create();
  await f.writeAsString("Hello World");
  print(await f.readAsString());
  print(f);
  final SignUpForm res = ConversionService.mapToObject(
      ConversionService.objectToMap(SignUpForm.init(User.init("test", f))),
      type: SignUpForm);
  print(ConversionService.encodeJSON(res));
  // print(await res.user.file.readAsString());
}

class SignUpResult {
  late final String token;
}

class User {
  User();

  User.init(this.name, this.file);

  late final File file;
  late final String name;
}

class SignUpForm {
  SignUpForm();

  SignUpForm.init(this.user);

  late final User user;
}
