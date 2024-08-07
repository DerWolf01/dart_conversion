import 'dart:io';
import 'dart:mirrors';

import 'package:dart_conversion/dart_conversion.dart';

void main() async {
  final f = await File("./hello.txt").create();
  await f.writeAsString("Hello World");
  // print(ConversionService.mapToObject<SignUpForm>(
  //     ConversionService.objectToMap(SignUpForm.init(User.init("test", f)))));
  final m = reflectClass(SignUpForm)
      .declarations
      .entries
      .where((element) {
        print(MirrorSystem.getName(element.key));
        return MirrorSystem.getName(element.key) == "SignUpForm.init";
      })
      .firstOrNull
      ?.value as MethodMirror?;

  print(m);
  if (m == null) {
    return;
  }
  final mParams = methodService.methodArgumentsByMap(
      methodMirror: m,
      argumentsMap: {
        "user": ConversionService.objectToMap(User.init("test", f))
      });
  print(mParams);
  print(mParams.args);
  print(mParams.namedArgs);
  // final SignUpForm res = ConversionService.mapToObject(
  //    ,
  //     type: SignUpForm);
  // print(ConversionService.encodeJSON(res));
  // print(await res.user.file.readAsString());
}

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
