class TextUtils {
  // Проверяет текст на наличие неподдерживаемых символов (только латинские буквы и пробелы)
  static bool hasUnsupportedCharacters(String text) {
    final unsupportedChars = RegExp(r'[^a-zA-Z\s]');
    return unsupportedChars.hasMatch(text);
  }
}
