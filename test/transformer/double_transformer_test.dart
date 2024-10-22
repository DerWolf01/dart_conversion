import 'package:dart_conversion/transformer/transformer.dart';
import 'package:test/test.dart';

void main() {
  group("DoubleTransformer", () {
    test("double --> double", () {
      final value = 1.25;
      final transformer = DoubleTransformer();
      final result = transformer.transform(value);
      expect(
        result,
        value,
        reason: "doubles should be returned unmodified",
      );
      expect(result, isA<double>(), reason: "Result should be an double");
    });

    test("int --> double", () {
      final value = 123;
      final transformer = DoubleTransformer();
      final result = transformer.transform(value);
      expect(
        value.toDouble(),
        result,
        reason: "ints should be converted to doubles",
      );
      expect(result, isA<double>(), reason: "Result should be an double");
    });

    test("String --> double", () {
      final value = "1.23";
      final transformer = DoubleTransformer();
      final result = transformer.transform(value);
      expect(
        1.23,
        result,
        reason: "Strings should be converted to doubles",
      );
      expect(result, isA<double>(), reason: "Result should be an double");
    });

    test("Map --> double", () {
      try {
        final value = {"test": 1.25};
        final transformer = DoubleTransformer();
        transformer.transform(value);
      } catch (e) {
        expect(e, isA<TransformerException>());
      }
    });
  });
}
