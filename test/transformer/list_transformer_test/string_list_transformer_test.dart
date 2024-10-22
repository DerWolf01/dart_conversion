import 'package:dart_conversion/transformer/transformer.dart';
import 'package:test/test.dart';

void main() {
  group("List<String>", () {
    test("List<String> -> List<String>", () {
      final transformer = transformers[List<String>];
      expect(transformer, isNotNull);
      final input = ["1", "2", "3"];
      final output = transformer!.transform(input);
      expect(output, input);
    });

    test(
        '["test", 1, 1.23, true, {"test_map": 0}] -> List<String> with invalid input',
        () {
      final value = [
        "test",
        1,
        1.23,
        true,
        {"test_map": 0},
        [1, 2, 3]
      ];
      final transformer = ListTransformer<String>(StringTransformer());
      final result = transformer.transform(value);
      expect(
          result, ["test", "1", "1.23", "true", '{"test_map":0}', "[1,2,3]"]);

      expect(result, isA<List<String>>());
    });
  });
}
