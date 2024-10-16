abstract class Converter<ConvertType, SourceType> {
  ConvertType convert();
  reverseConvert(ConvertType value);
}
