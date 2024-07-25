import 'package:dart_conversion/dart_conversion.dart';

void main() {
  print(ConversionService.mapToObject(
      ConversionService.objectToMap(SignUpForm(User("test"))),
      type: SignUpForm));
}

class SignUpResult {
  const SignUpResult(this.token);

  final String token;
}

class User {
  const User(this.name);

  final String name;
}

class SignUpForm {
  const SignUpForm(this.user);

  final User user;
}
