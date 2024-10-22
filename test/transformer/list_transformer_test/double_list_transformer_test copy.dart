import 'package:dart_conversion/transformer/transformer.dart';
import 'package:test/test.dart';

void main() {
  group("List<double>", () {
    test("List<String> -> List<double>", () {
      final value = ["1.13", "0.11", "0.15"];
      final transformer = transformers[List<double>];
      expect(transformer, isNotNull);

      final result = transformer!.transform(value);
      expect(
        result,
        [1.13, 0.11, 0.15],
        reason: "Strings should be converted to ints",
      );
      expect(result, isA<List<double>>(), reason: "Result should be an double");
    });
    test("List<double> -> List<double>", () {
      final value = [1.0, 0.0, 1.0];
      final transformer = transformers[List<double>];
      expect(transformer, isNotNull);

      final result = transformer!.transform(value);
      expect(
        result,
        [1.0, 0.0, 1.0],
        reason: "doubles should be converted to doubles",
      );
      expect(result, isA<List<double>>(), reason: "Result should be an double");
    });

    test("List<Map> -> List<double>", () {
      try {
        final value = [
          {"test": 1.25}
        ];
        final transformer = transformers[List<double>];
        transformer!.transform(value);
      } catch (e) {
        expect(e, isA<TransformerException>());
      }
    });

    test("List<dynamic> -> List<double>", () {
      final value = [
        1,
        "1.23",
        123,
      ];
      final transformer = transformers[List<double>];
      expect(transformer, isNotNull);

      final result = transformer!.transform(value);
      expect(
        result,
        [1, 1.23, 123, 0],
        reason: "List<dynamic> should be converted to ints",
      );
      expect(result, isA<List<double>>(), reason: "Result should be an double");
    });

    test("[1, 2, {\"test\": 123}] -> List<double>", () {
      try {
        final value = [
          1,
          2,
          {"test": 123}
        ];
        final transformer = transformers[List<double>];
        expect(transformer, isNotNull);

        transformer!.transform(value);
      } catch (e) {
        expect(e, isA<TransformerException>());
      }
    });
  });
}
