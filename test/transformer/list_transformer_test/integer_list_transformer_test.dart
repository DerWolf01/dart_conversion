import 'package:dart_conversion/transformer/transformer.dart';
import 'package:test/test.dart';

void main() {
  group("List<int>", () {
    test("List<bool> -> List<int>", () {
      final value = [true, false, true];
      final transformer = transformers[List<int>];
      expect(transformer, isNotNull);

      final result = transformer!.transform(value);
      expect(
        result,
        [1, 0, 1],
        reason: "bools should be converted to ints",
      );
      expect(result, isA<List<int>>(), reason: "Result should be an int");
    });
    test("List<String> -> List<int>", () {
      final value = ["1", "0", "1"];
      final transformer = transformers[List<int>];
      expect(transformer, isNotNull);

      final result = transformer!.transform(value);
      expect(
        result,
        [1, 0, 1],
        reason: "Strings should be converted to ints",
      );
      expect(result, isA<List<int>>(), reason: "Result should be an int");
    });
    test("List<double> -> List<int>", () {
      final value = [1.0, 0.0, 1.0];
      final transformer = transformers[List<int>];
      expect(transformer, isNotNull);

      final result = transformer!.transform(value);
      expect(
        result,
        [1, 0, 1],
        reason: "Strings should be converted to ints",
      );
      expect(result, isA<List<int>>(), reason: "Result should be an int");
    });

    test("List<Map> -> List<int>", () {
      try {
        final value = [
          {"test": 1.25}
        ];
        final transformer = transformers[List<int>];
        transformer!.transform(value);
      } catch (e) {
        expect(e, isA<TransformerException>());
      }
    });

    test("List<dynamic> -> List<int>", () {
      final value = [1, "123", 123, false];
      final transformer = transformers[List<int>];
      expect(transformer, isNotNull);

      final result = transformer!.transform(value);
      expect(
        result,
        [1, 123, 123, 0],
        reason: "Strings should be converted to ints",
      );
      expect(result, isA<List<int>>(), reason: "Result should be an int");
    });

    test("[1, 2, {\"test\": 123}] -> List<int>", () {
      try {
        final value = [
          1,
          2,
          {"test": 123}
        ];
        final transformer = transformers[List<int>];
        expect(transformer, isNotNull);

        transformer!.transform(value);
      } catch (e) {
        expect(e, isA<TransformerException>());
      }
    });
  });
}
