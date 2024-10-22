import 'package:dart_conversion/transformer/transformer.dart';
import 'package:test/test.dart';

void main() {
  test("\"true\" -> bool", () {
    final value = "true";
    final transformer = BoolTransformer();
    final result = transformer.transform(value);
    expect(result, true,
        reason: "Strings should be converted to true if they are 'true'");
    expect(result, isA<bool>(), reason: "Result should be a bool");
  });

  test("\"false\" -> bool", () {
    final value = "false";
    final transformer = BoolTransformer();
    final result = transformer.transform(value);
    expect(result, false,
        reason: "Strings should be converted to false if they are 'false'");
    expect(result, isA<bool>(), reason: "Result should be a bool");
  });
  test("1 -> bool", () {
    final value = 1;
    final transformer = BoolTransformer();
    final result = transformer.transform(value);
    expect(result, true,
        reason: "Integers should be converted to true if 1 and false if 0");
    expect(result, isA<bool>(), reason: "Result should be a bool");
  });

  test("0 -> bool", () {
    final value = 0;
    final transformer = BoolTransformer();
    final result = transformer.transform(value);
    expect(result, false,
        reason: "Integers should be converted to true if 1 and false if 0");
    expect(result, isA<bool>(), reason: "Result should be a bool");
  });
  test("non representive int -> bool", () {
    try {
      final value = 3;
      final transformer = BoolTransformer();
      transformer.transform(value);
    } catch (e) {
      expect(e, isA<TransformerException>());
    }
  });

  test("Map --> bool", () {
    try {
      final value = {"test": 1.25};
      final transformer = BoolTransformer();
      transformer.transform(value);
    } catch (e) {
      expect(e, isA<TransformerException>());
    }
  });
}
