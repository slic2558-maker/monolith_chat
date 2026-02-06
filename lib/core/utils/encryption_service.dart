import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:encrypt/encrypt.dart';

class EncryptionService {
  static Key get encryptionKey {
    final keyString = dotenv.get('ENCRYPTION_KEY');
    return Key.fromUtf8(keyString);
  }
  
  static IV get encryptionIV {
    final ivString = dotenv.get('ENCRYPTION_IV');
    return IV.fromUtf8(ivString);
  }
  
  static String encrypt(String text) {
    final encrypter = Encrypter(AES(encryptionKey));
    return encrypter.encrypt(text, iv: encryptionIV).base64;
  }
}