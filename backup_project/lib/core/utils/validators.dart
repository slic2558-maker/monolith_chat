import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../constants/app_constants.dart';

class Validators {
  // Validate UIN format and checksum
  static bool isValidUIN(String uin) {
    if (uin.length != AppConstants.uinLength) return false;
    if (!RegExp(AppConstants.uinRegex).hasMatch(uin)) return false;
    
    // Calculate checksum (Luhn-like algorithm)
    final digits = uin.split('').map(int.parse).toList();
    int sum = 0;
    
    for (int i = 0; i < digits.length - 1; i++) {
      int digit = digits[i];
      if (i % 2 == 0) {
        digit *= 2;
        if (digit > 9) digit -= 9;
      }
      sum += digit;
    }
    
    int checksum = (10 - (sum % 10)) % 10;
    return checksum == digits.last;
  }
  
  // Generate UIN with checksum
  static String generateUIN() {
    final random = Random.secure();
    String base = '';
    for (int i = 0; i < AppConstants.uinLength - 1; i++) {
      base += random.nextInt(10).toString();
    }
    
    final digits = base.split('').map(int.parse).toList();
    int sum = 0;
    
    for (int i = 0; i < digits.length; i++) {
      int digit = digits[i];
      if (i % 2 == 0) {
        digit *= 2;
        if (digit > 9) digit -= 9;
      }
      sum += digit;
    }
    
    int checksum = (10 - (sum % 10)) % 10;
    return base + checksum.toString();
  }
  
  // Validate contact name
  static bool isValidName(String name) {
    return name.length >= 2 && name.length <= 50;
  }
  
  // Validate message text
  static bool isValidMessage(String text) {
    return text.trim().isNotEmpty && text.length <= AppConstants.maxMessageLength;
  }
  
  // Validate phone number (if added later)
  static bool isValidPhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
    return cleaned.length >= 10 && cleaned.length <= 15;
  }
  
  // Validate email (if added later)
  static bool isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }
  
  // Hash password/data
  static String hashData(String data) {
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  // Validate image file
  static bool isValidImage(String path) {
    final extension = path.split('.').last.toLowerCase();
    return AppConstants.allowedImageTypes.contains(extension);
  }
  
  // Validate file size
  static bool isValidFileSize(int bytes, {int maxMB = 10}) {
    final maxBytes = maxMB * 1024 * 1024;
    return bytes <= maxBytes;
  }
  
  // Sanitize input
  static String sanitizeInput(String input) {
    // Remove potentially dangerous characters
    return input
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;')
        .replaceAll('/', '&#x2F;');
  }
  
  // Validate group name
  static bool isValidGroupName(String name) {
    return name.length >= 3 && name.length <= 100;
  }
  
  // Calculate message checksum for integrity
  static String calculateMessageChecksum(String messageId, String text, DateTime timestamp) {
    final data = '$messageId$text${timestamp.millisecondsSinceEpoch}';
    return hashData(data);
  }
}