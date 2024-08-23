import 'dart:io';
import 'dart:mirrors';

import 'package:dart_conversion/dart_conversion.dart';
import 'package:dart_conversion/list_of.dart';

typedef NullableString = String?;
void main() async {
  ConversionService.mapToObject<SignUpResult>(ConversionService.objectToMap(
      SignUpResult.init("", [
    SignUpStrings.init("asd"),
    SignUpStrings.init("asd"),
    SignUpStrings.init("asd")
  ])));
}

class SignUpResult {
  SignUpResult.init(this.token, this.list);
  SignUpResult();
  late final String token;

  @ListOf(type: SignUpStrings)
  late final List<dynamic> list;
}

class SignUpStrings {
  SignUpStrings();
  SignUpStrings.init(this.value);

  late final String value;
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
