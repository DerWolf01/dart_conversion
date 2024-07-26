import 'package:dart_conversion/dart_conversion.dart';

void main() {
  print(ConversionService.mapToObject(
      ConversionService.objectToMap(SignUpForm.init(User.init("test"))),
      type: SignUpForm));
}

class SignUpResult {
  late final String token;
}

class User {
  User();
  User.init(this.name);
  late final String name;
}

class SignUpForm {
  SignUpForm();
  SignUpForm.init(this.user);

  late final User user;
}
