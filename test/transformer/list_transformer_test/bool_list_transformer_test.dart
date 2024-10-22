import 'package:dart_conversion/transformer/transformer.dart';
import 'package:test/test.dart';

void main() {
  group("List<bool>", () {
    test("List<String> -> List<bool>", () {
      final value = [
        "false",
        "true",
      ];
      final transformer = transformers[List<bool>];
      expect(transformer, isNotNull);

      final result = transformer!.transform(value);
      expect(
        result,
        [
          false,
          true,
        ],
        reason: "Strings should be converted to ints",
      );
      expect(result, isA<List<bool>>(), reason: "Result should be an bool");
    });
    test("List<num> -> List<bool>", () {
      final value = [1.0, 0, 1.0];
      final transformer = transformers[List<bool>];
      expect(transformer, isNotNull);

      final result = transformer!.transform(value);
      expect(
        result,
        [true, false, true],
        reason: "List<num> should be converted to List<bool>",
      );
      expect(result, isA<List<bool>>(), reason: "Result should be an bool");
    });

    test("List<Map> -> List<bool>", () {
      try {
        final value = [
          {"test": 1.25}
        ];
        final transformer = transformers[List<bool>];
        transformer!.transform(value);
      } catch (e) {
        expect(e, isA<TransformerException>());
      }
    });

    test("List<dynamic> -> List<bool>", () {
      final value = ["false", "true", 1, 0];
      final transformer = transformers[List<bool>];
      expect(transformer, isNotNull);

      final result = transformer!.transform(value);
      expect(
        result,
        [false, true, true, false],
        reason: '["false", "true", 1, 0] should be converted to List<bool>',
      );
      expect(result, isA<List<bool>>(),
          reason: "Result should be an List<bool>");
    });

    test("[1, 2, {\"test\": 123}] -> List<bool>", () {
      try {
        final value = [
          1,
          2,
          {"test": 123}
        ];
        final transformer = transformers[List<bool>];
        expect(transformer, isNotNull);

        transformer!.transform(value);
      } catch (e) {
        expect(e, isA<TransformerException>());
      }
    });
  });
}
