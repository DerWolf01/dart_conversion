class CollectionOf<T> {
  const CollectionOf({required this.valueType, this.keyType});

  final Type valueType;
  final Type? keyType;
}
