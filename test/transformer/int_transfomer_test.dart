import 'package:dart_conversion/transformer/transformer.dart';
import 'package:test/test.dart';

void main() {
  group("IntTransformer", () {
    test("int --> int", () {
      final value = 123;
      final transformer = IntTransformer();
      final result = transformer.transform(value);
      expect(
        value,
        result,
        reason: "Integers should remain unmodified",
      );
      expect(result, isA<int>(), reason: "Result should be an Integer");
    });

    test("String --> int", () {
      final value = "123";
      final transformer = IntTransformer();
      final result = transformer.transform(value);
      expect(
        123,
        result,
        reason: "Strings should be converted to ints",
      );
      expect(result, isA<int>(), reason: "Result should be an int");
    });

    test("bool --> int", () {
      final value = true;
      final transformer = IntTransformer();
      final result = transformer.transform(value);
      expect(
        result,
        1,
        reason: "bools should be converted to ints",
      );
      expect(result, isA<int>(), reason: "Result should be an int");
    });

    test("double --> int", () {
      final value = 1.25;
      final transformer = IntTransformer();
      final result = transformer.transform(value);
      expect(
        result,
        1,
        reason: "doubles should be converted to ints",
      );
      expect(result, isA<int>(), reason: "Result should be an int");
    });

    test("Map --> int", () {
      try {
        final value = {"test": 1.25};
        final transformer = IntTransformer();
        transformer.transform(value);
      } catch (e) {
        expect(e, isA<TransformerException>());
      }
    });
  });
}
