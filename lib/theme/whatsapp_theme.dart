// Минимальная версия
import 'package:flutter/material.dart';

class WhatsAppTheme {
  static const Color whatsappGreen = Color(0xFF075E54);
  static const Color whatsappGreenAccent = Color(0xFF25D366);
  static const Color backgroundColor = Color(0xFFECE5DD);
  static const Color chatBackground = Color(0xFFECE5DD);
  static const Color messageSent = Color(0xFFDCF8C6);
  static const Color messageReceived = Color(0xFFFFFFFF);
  static const Color primaryText = Color(0xFF000000);
  static const Color secondaryText = Color(0xFF667781);
  static const Color textTime = Color(0xFF667781);
  static const Color dividerColor = Color(0xFFE0E0E0);
}

ThemeData getWhatsAppLightTheme() {
  return ThemeData.light().copyWith(
    primaryColor: WhatsAppTheme.whatsappGreen,
    scaffoldBackgroundColor: WhatsAppTheme.backgroundColor,
  );
}

ThemeData getWhatsAppDarkTheme() {
  return ThemeData.dark();
}