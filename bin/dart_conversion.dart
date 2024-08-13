import 'dart:io';
import 'dart:mirrors';

import 'package:dart_conversion/dart_conversion.dart';

typedef NullableString = String?;
void main() async {}

class SignUpResult {
  SignUpResult.init(this.token);
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
