import 'package:dart_conversion/convertable.dart';
import 'package:dart_conversion/dart_conversion.dart';
import 'package:dart_conversion/my_logger.dart';
import 'package:test/test.dart';

import 'convert.reflectable.dart';

@convertable
class TestUser {
  final String name;

  final int id;
  final String lastName;

  TestUser({required this.id, required this.lastName, required this.name});
}

void main() {
  initializeReflectable();
  group("DartConversion", () {
    MyLogger.init(enabled: true);
    test(
      "TestUser --> Map<String, dynamic>",
      () {
        dartConversion.convert(
            TestUser(id: 0, lastName: "lastname", name: "name"),
            to: Map<String, dynamic>);
      },
    );
  });
}
