import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Типы тем
enum ThemeType { whatsappGreen, dark, light, custom }

// Класс темы
class AppTheme {
  final ThemeType type;
  final String name;
  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;
  final Color textColor;
  final Color bubbleSentColor;
  final Color bubbleReceivedColor;

  AppTheme({
    required this.type,
    required this.name,
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.textColor,
    required this.bubbleSentColor,
    required this.bubbleReceivedColor,
  });

  // WhatsApp зелёная тема (точные цвета WhatsApp)
  static AppTheme get whatsappGreen => AppTheme(
    type: ThemeType.whatsappGreen,
    name: 'WhatsApp Green',
    primaryColor: const Color(0xFF075E54),      // Тёмно-зелёный WhatsApp
    secondaryColor: const Color(0xFF128C7E),     // Средне-зелёный
    backgroundColor: const Color(0xFFECE5DD),    // Фон чата WhatsApp
    textColor: const Color(0xFF000000),
    bubbleSentColor: const Color(0xFFDCF8C6),    // Ваши сообщения (светло-зелёный)
    bubbleReceivedColor: const Color(0xFFFFFFFF), // Сообщения других (белый)
  );

  // Тёмная тема
  static AppTheme get dark => AppTheme(
    type: ThemeType.dark,
    name: 'Тём