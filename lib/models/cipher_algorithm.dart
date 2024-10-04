abstract class CipherAlgorithm {
  String encrypt(String input);
}

class CaesarCipher implements CipherAlgorithm {
  final int shift;
  CaesarCipher(this.shift);

  @override
  String encrypt(String input) {
    return input.split('').map((char) {
      int code = char.codeUnitAt(0);
      if (char.contains(RegExp(r'[a-zA-Z]'))) {
        int a = char.contains(RegExp(r'[A-Z]')) ? 'A'.codeUnitAt(0) : 'a'.codeUnitAt(0);
        return String.fromCharCode(((code - a + shift) % 26) + a);
      }
      return char;
    }).join();
  }
}

class AtbashCipher implements CipherAlgorithm {
  @override
  String encrypt(String input) {
    return input.split('').map((char) {
      if (char.contains(RegExp(r'[a-zA-Z]'))) {
        int a = char.contains(RegExp(r'[A-Z]')) ? 'A'.codeUnitAt(0) : 'a'.codeUnitAt(0);
        int z = char.contains(RegExp(r'[A-Z]')) ? 'Z'.codeUnitAt(0) : 'z'.codeUnitAt(0);
        return String.fromCharCode(z - (char.codeUnitAt(0) - a));
      }
      return char;
    }).join();
  }
}

class MorseCipher implements CipherAlgorithm {
  final Map<String, String> morseCode = {
    'A': '.-', 'B': '-...', 'C': '-.-.', 'D': '-..', 'E': '.', 'F': '..-.',
    'G': '--.', 'H': '....', 'I': '..', 'J': '.---', 'K': '-.-', 'L': '.-..',
    'M': '--', 'N': '-.', 'O': '---', 'P': '.--.', 'Q': '--.-', 'R': '.-.',
    'S': '...', 'T': '-', 'U': '..-', 'V': '...-', 'W': '.--', 'X': '-..-',
    'Y': '-.--', 'Z': '--..', '0': '-----', '1': '.----', '2': '..---',
    '3': '...--', '4': '....-', '5': '.....', '6': '-....', '7': '--...',
    '8': '---..', '9': '----.', ' ': '/'
  };

  @override
  String encrypt(String input) {
    return input.toUpperCase().split('').map((char) {
      return morseCode[char] ?? char;
    }).join(' ');
  }
}

class VigenereCipher implements CipherAlgorithm {
  final String key;
  VigenereCipher(this.key);

  @override
  String encrypt(String input) {
    StringBuffer result = StringBuffer();
    int keyIndex = 0;
    for (int i = 0; i < input.length; i++) {
      if (input[i].contains(RegExp(r'[a-zA-Z]'))) {
        int shift = key[keyIndex % key.length].toUpperCase().codeUnitAt(0) - 'A'.codeUnitAt(0);
        int a = input[i].contains(RegExp(r'[A-Z]')) ? 'A'.codeUnitAt(0) : 'a'.codeUnitAt(0);
        int newChar = ((input[i].codeUnitAt(0) - a + shift) % 26) + a;
        result.write(String.fromCharCode(newChar));
        keyIndex++;
      } else {
        result.write(input[i]);
      }
    }
    return result.toString();
  }
}
