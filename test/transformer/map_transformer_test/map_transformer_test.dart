import 'package:dart_conversion/my_logger.dart';
import 'package:dart_conversion/transformer/transformer.dart';
import 'package:test/test.dart';

void main() {
  group("MapTranformer", () {
    MyLogger.init(enabled: true);
    test("MapTransformer: Map<String, String> --> Map<String, int>", () {
      final transformer = transformers[Map<String, int>];

      expect(transformer, isNotNull);
      final invalidMap = {"asdasd": "asdasd", "s": "adasd"};
      try {
        transformer!.transform(invalidMap);
      } catch (e) {
        print(e);
        expect(e, isA<TransformerException>());
      }

      final validMap = {"asdasd": "1", "d": "false"};

      final validMapTransformed = transformer!.transform(validMap);
      expect(validMapTransformed, isA<Map<String, int>>());
    });

    test("MapTransformer: Map<String, String> --> Map<String, bool>", () {
      final transformer = transformers[Map<String, bool>];

      expect(transformer, isNotNull);
      final invalidMap = {"asdasd": "asdasd", "s": "adasd"};
      try {
        transformer!.transform(invalidMap);
      } catch (e) {
        print(e);
        expect(e, isA<TransformerException>());
      }

      final validMap = {"asdasd": 1, "d": false};

      final validMapTransformed = transformer!.transform(validMap);
      expect(validMapTransformed, isA<Map<String, bool>>());
    });

    test("MapTransformer: Map<String, String> --> Map<String, double>", () {
      final transformer = transformers[Map<String, double>];

      expect(transformer, isNotNull);
      final invalidMap = {"asdasd": "asdasd", "s": "adasd"};
      try {
        transformer!.transform(invalidMap);
      } catch (e) {
        print(e);
        expect(e, isA<TransformerException>());
      }

      final validMap = {"asdasd": "1.23", "d": "1"};

      final validMapTransformed = transformer!.transform(validMap);
      expect(validMapTransformed, isA<Map<String, double>>());
    });

// testing list transformers of previously tested types

    test("MapTransformer: Map<String, String> --> Map<String, List<int>>", () {
      final transformer = transformers[Map<String, List<int>>];

      expect(transformer, isNotNull);
      final invalidMap = {"asdasd": "asdasd", "s": "adasd"};
      try {
        transformer!.transform(invalidMap);
      } catch (e) {
        print(e);
        expect(e, isA<TransformerException>());
      }

      final validMap = {
        "asdasd": ["1", false, "true"],
        "d": [2, 3.1, "false"]
      };

      final validMapTransformed = transformer!.transform(validMap);
      expect(validMapTransformed, isA<Map<String, List<int>>>());
    });

    test("MapTransformer: Map<String, String> --> Map<String, List<bool>>", () {
      final transformer = transformers[Map<String, List<bool>>];

      expect(transformer, isNotNull);
      final invalidMap = {"asdasd": "asdasd", "s": "adasd"};
      try {
        transformer!.transform(invalidMap);
      } catch (e) {
        print(e);
        expect(e, isA<TransformerException>());
      }

      final validMap = {
        "asdasd": ["1"],
        "d": ["false", 0, 1]
      };

      final validMapTransformed = transformer!.transform(validMap);
      expect(validMapTransformed, isA<Map<String, List<bool>>>());
    });

    test("MapTransformer: Map<String, String> --> Map<String, List<double>>",
        () {
      final transformer = transformers[Map<String, List<double>>];

      expect(transformer, isNotNull);
      final invalidMap = {"asdasd": "asdasd", "s": "adasd"};
      try {
        transformer!.transform(invalidMap);
      } catch (e) {
        print(e);
        expect(e, isA<TransformerException>());
      }

      final validMap = {
        "asdasd": ["1.23", 2, "3.2"],
        "d": [1]
      };

      final validMapTransformed = transformer!.transform(validMap);
      expect(validMapTransformed, isA<Map<String, List<double>>>());
    });
  });
}
