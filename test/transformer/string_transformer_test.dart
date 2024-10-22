import 'dart:convert';

import 'package:dart_conversion/transformer/transformer.dart';
import 'package:test/test.dart';

void main() {
  group("StringTransformer", () {
    test("String -> String", () {
      final value = "test";

      final transformer = StringTransformer();
      final result = transformer.transform(value);
      expect(
        value,
        result,
        reason: "Strings should remain unmodified",
      );
      expect(result, isA<String>(), reason: "Result should be a String");
    });

    test("Map -> String", () {
      final value = {"test": 123};
      final jsonEncodedValue = jsonEncode(value);
      final transformer = StringTransformer();
      final result = transformer.transform(value);
      expect(
        jsonEncodedValue,
        result,
        reason: "Maps should be converted to json Strings",
      );
      expect(result, isA<String>(), reason: "Result should be a String");
    });
    test("List -> String", () {
      final value = [
        1231,
        "12312",
        123123,
        {"test": 123}
      ];
      final jsonEncodedValue = jsonEncode(value);
      final transformer = StringTransformer();
      final result = transformer.transform(value);
      expect(
        jsonEncodedValue,
        result,
        reason: "Maps should be converted to json Strings",
      );
      expect(result, isA<String>(), reason: "Result should be a String");
    });
  });
}
