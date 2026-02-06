import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class EncryptionService {
  static final _storage = FlutterSecureStorage();
  static final _iv = IV.fromLength(16);
  
  // Generate and store encryption key
  static Future<Key> _getOrCreateKey() async {
    const keyKey = 'encryption_key';
    String? storedKey = await _storage.read(key: keyKey);
    
    if (storedKey != null) {
      return Key(base64.decode(storedKey));
    }
    
    // Generate new key
    final key = Key.fromSecureRandom(32);
    await _storage.write(
      key: keyKey,
      value: base64.encode(key.bytes),
    );
    
    return key;
  }
  
  // Encrypt text
  static Future<String> encryptText(String text) async {
    try {
      final key = await _getOrCreateKey();
      final encrypter = Encrypter(AES(key));
      final encrypted = encrypter.encrypt(text, iv: _iv);
      return encrypted.base64;
    } catch (e) {
      throw Exception('Encryption failed: $e');
    }
  }
  
  // Decrypt text
  static Future<String> decryptText(String encryptedText) async {
    try {
      final key = await _getOrCreateKey();
      final encrypter = Encrypter(AES(key));
      final decrypted = encrypter.decrypt64(encryptedText, iv: _iv);
      return decrypted;
    } catch (e) {
      throw Exception('Decryption failed: $e');
    }
  }
  
  // Encrypt message for storage
  static Future<Map<String, dynamic>> encryptMessage(Map<String, dynamic> message) async {
    final encrypted = Map<String, dynamic>.from(message);
    
    if (encrypted.containsKey('text')) {
      encrypted['text'] = await encryptText(message['text']);
    }
    
    if (encrypted.containsKey('senderName')) {
      encrypted['senderName'] = await encryptText(message['senderName'] ?? '');
    }
    
    // Add integrity hash
    final checksum = sha256.convert(utf8.encode(json.encode(message))).toString();
    encrypted['_checksum'] = checksum;
    encrypted['_encrypted'] = true;
    
    return encrypted;
  }
  
  // Decrypt message from storage
  static Future<Map<String, dynamic>> decryptMessage(Map<String, dynamic> encryptedMessage) async {
    if (!(encryptedMessage['_encrypted'] ?? false)) {
      return encryptedMessage;
    }
    
    final decrypted = Map<String, dynamic>.from(encryptedMessage);
    
    if (decrypted.containsKey('text')) {
      decrypted['text'] = await decryptText(encryptedMessage['text']);
    }
    
    if (decrypted.containsKey('senderName')) {
      decrypted['senderName'] = await decryptText(encryptedMessage['senderName'] ?? '');
    }
    
    // Verify integrity
    final storedChecksum = decrypted.remove('_checksum');
    decrypted.remove('_encrypted');
    
    final calculatedChecksum = sha256.convert(
      utf8.encode(json.encode(decrypted))
    ).toString();
    
    if (storedChecksum != calculatedChecksum) {
      throw Exception('Message integrity check failed');
    }
    
    return decrypted;
  }
  
  // Generate hash for UIN verification
  static String hashUIN(String uin) {
    final bytes = utf8.encode('MONOLITH_SALT_$uin');
    return sha256.convert(bytes).toString();
  }
  
  // Clear all encryption data (logout)
  static Future<void> clearKeys() async {
    await _storage.deleteAll();
  }
}