class ConstructorServiceException implements NoSuchMethodError {
  ConstructorServiceException(String message, StackTrace stackTrace)
      : _stackTrace = stackTrace;

  final StackTrace _stackTrace;

  @override
  StackTrace? get stackTrace => _stackTrace;
}

class ConstructorParameterException extends ArgumentError {
  ConstructorParameterException(
    super.message,
    super.name,
  );

  @override
  String toString() => "ConstructorParameterException($message, $name)";
}
