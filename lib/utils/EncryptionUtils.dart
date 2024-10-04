import '../models/cipher_algorithm.dart';

class EncryptionUtils {
  static CipherAlgorithm? getAlgorithm(String algorithmName, {String? key}) {
    switch (algorithmName) {
      case 'Цезарь':
        return CaesarCipher(3);
      case 'Атбаш':
        return AtbashCipher();
      case 'Морзе':
        return MorseCipher();
      case 'Вижинер':
        if (key != null && key.isNotEmpty) {
          return VigenereCipher(key);
        } else {
          return null; // Вернем null, если не был передан ключ
        }
      default:
        return null;
    }
  }
}
