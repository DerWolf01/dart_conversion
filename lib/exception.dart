class DartConversionException implements Exception {
  const DartConversionException(this.message);

  final String message;

  @override
  String toString() => "DartConversionException($message)";
}
