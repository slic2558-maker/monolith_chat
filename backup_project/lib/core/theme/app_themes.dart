import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

enum ThemeType {
  whatsappGreen,
  dark,
  light,
  blue,
  purple,
  amoled,
  custom
}

class AppTheme {
  final ThemeType type;
  final String name;
  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;
  final Color scaffoldBackground;
  final Color cardColor;
  final Color textColor;
  final Color secondaryText;
  final Color bubbleSentColor;
  final Color bubbleReceivedColor;
  final Color inputBackground;
  final Color dividerColor;
  final Color onlineIndicator;
  final Color typingIndicator;
  final Color errorColor;
  final Color successColor;
  final Color warningColor;
  final Color infoColor;
  final Brightness brightness;
  final double bubbleBorderRadius;

  const AppTheme({
    required this.type,
    required this.name,
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.scaffoldBackground,
    required this.cardColor,
    required this.textColor,
    required this.secondaryText,
    required this.bubbleSentColor,
    required this.bubbleReceivedColor,
    required this.inputBackground,
    required this.dividerColor,
    required this.onlineIndicator,
    required this.typingIndicator,
    required this.errorColor,
    required this.successColor,
    required this.warningColor,
    required this.infoColor,
    required this.brightness,
    this.bubbleBorderRadius = 16.0,
  });

  // WhatsApp Green Theme (Default)
  static AppTheme get whatsappGreen => AppTheme(
    type: ThemeType.whatsappGreen,
    name: 'WhatsApp Green',
    primaryColor: AppConstants.whatsappGreen,
    secondaryColor: AppConstants.whatsappLightGreen,
    backgroundColor: AppConstants.chatBackground,
    scaffoldBackground: AppConstants.chatBackground,
    cardColor: Colors.white,
    textColor: Colors.black,
    secondaryText: Color(0xFF667781),
    bubbleSentColor: AppConstants.messageSent,
    bubbleReceivedColor: AppConstants.messageReceived,
    inputBackground: Colors.white,
    dividerColor: Color(0xFFE0E0E0),
    onlineIndicator: AppConstants.onlineGreen,
    typingIndicator: AppConstants.typingIndicator,
    errorColor: Colors.red,
    successColor: Colors.green,
    warningColor: Colors.orange,
    infoColor: Colors.blue,
    brightness: Brightness.light,
  );

  // Dark Theme
  static AppTheme get dark => AppTheme(
    type: ThemeType.dark,
    name: 'Dark',
    primaryColor: Color(0xFF1F2C34),
    secondaryColor: Color(0xFF00A884),
    backgroundColor: Color(0xFF121B22),
    scaffoldBackground: Color(0xFF121B22),
    cardColor: Color(0xFF1F2C34),
    textColor: Colors.white,
    secondaryText: Color(0xFF8696A0),
    bubbleSentColor: Color(0xFF005C4B),
    bubbleReceivedColor: Color(0xFF1F2C34),
    inputBackground: Color(0xFF1F2C34),
    dividerColor: Color(0xFF26333D),
    onlineIndicator: Color(0xFF00A884),
    typingIndicator: Color(0xFF53BDEB),
    errorColor: Color(0xFFFF6B6B),
    successColor: Color(0xFF4CAF50),
    warningColor: Color(0xFFFFA726),
    infoColor: Color(0xFF29B6F6),
    brightness: Brightness.dark,
  );

  // Light Theme
  static AppTheme get light => AppTheme(
    type: ThemeType.light,
    name: 'Light',
    primaryColor: Colors.blue,
    secondaryColor: Colors.lightBlue,
    backgroundColor: Color(0xFFF5F5F5),
    scaffoldBackground: Colors.white,
    cardColor: Colors.white,
    textColor: Colors.black87,
    secondaryText: Colors.grey[700]!,
    bubbleSentColor: Colors.blue[100]!,
    bubbleReceivedColor: Colors.white,
    inputBackground: Colors.grey[100]!,
    dividerColor: Colors.grey[300]!,
    onlineIndicator: Colors.green,
    typingIndicator: Colors.blue,
    errorColor: Colors.red,
    successColor: Colors.green,
    warningColor: Colors.orange,
    infoColor: Colors.blue,
    brightness: Brightness.light,
  );

  // Blue Theme
  static AppTheme get blue => AppTheme(
    type: ThemeType.blue,
    name: 'Blue',
    primaryColor: Color(0xFF1A73E8),
    secondaryColor: Color(0xFF4285F4),
    backgroundColor: Color(0xFFE8F0FE),
    scaffoldBackground: Color(0xFFE8F0FE),
    cardColor: Colors.white,
    textColor: Colors.black,
    secondaryText: Color(0xFF5F6368),
    bubbleSentColor: Color(0xFFD2E3FC),
    bubbleReceivedColor: Colors.white,
    inputBackground: Colors.white,
    dividerColor: Color(0xFFDADCE0),
    onlineIndicator: Colors.green,
    typingIndicator: Color(0xFF1A73E8),
    errorColor: Colors.red,
    successColor: Colors.green,
    warningColor: Colors.orange,
    infoColor: Colors.blue,
    brightness: Brightness.light,
  );

  // Purple Theme (Telegram-like)
  static AppTheme get purple => AppTheme(
    type: ThemeType.purple,
    name: 'Purple',
    primaryColor: Color(0xFF6F42C1),
    secondaryColor: Color(0xFF8A63D2),
    backgroundColor: Color(0xFFF3E5F5),
    scaffoldBackground: Color(0xFFF3E5F5),
    cardColor: Colors.white,
    textColor: Colors.black,
    secondaryText: Color(0xFF666666),
    bubbleSentColor: Color(0xFFE1D5F5),
    bubbleReceivedColor: Colors.white,
    inputBackground: Colors.white,
    dividerColor: Color(0xFFE0E0E0),
    onlineIndicator: Colors.green,
    typingIndicator: Color(0xFF6F42C1),
    errorColor: Colors.red,
    successColor: Colors.green,
    warningColor: Colors.orange,
    infoColor: Colors.blue,
    brightness: Brightness.light,
  );

  // AMOLED Black Theme
  static AppTheme get amoled => AppTheme(
    type: ThemeType.amoled,
    name: 'AMOLED',
    primaryColor: Colors.black,
    secondaryColor: Color(0xFF00FF00),
    backgroundColor: Colors.black,
    scaffoldBackground: Colors.black,
    cardColor: Color(0xFF111111),
    textColor: Colors.white,
    secondaryText: Color(0xFF666666),
    bubbleSentColor: Color(0xFF003300),
    bubbleReceivedColor: Color(0xFF111111),
    inputBackground: Color(0xFF111111),
    dividerColor: Color(0xFF222222),
    onlineIndicator: Color(0xFF00FF00),
    typingIndicator: Color(0xFF00FF00),
    errorColor: Colors.red,
    successColor: Colors.green,
    warningColor: Colors.orange,
    infoColor: Colors.blue,
    brightness: Brightness.dark,
    bubbleBorderRadius: 8.0,
  );

  // Get all themes
  static List<AppTheme> get allThemes => [
    whatsappGreen,
    dark,
    light,
    blue,
    purple,
    amoled,
  ];

  // Get theme by type
  static AppTheme fromType(ThemeType type) {
    return allThemes.firstWhere((theme) => theme.type == type);
  }

  // Convert to Material ThemeData
  ThemeData toThemeData() {
    return ThemeData(
      brightness: brightness,
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: _createMaterialColor(primaryColor),
        backgroundColor: scaffoldBackground,
        brightness: brightness,
      ),
      scaffoldBackgroundColor: scaffoldBackground,
      cardColor: cardColor,
      dividerColor: dividerColor,
      errorColor: errorColor,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: textColor,
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: secondaryColor,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: primaryColor,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
      ),
      iconTheme: IconThemeData(color: textColor),
      textTheme: TextTheme(
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: textColor,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: secondaryText,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: secondaryText,
        ),
      ),
    );
  }

  // Helper to create MaterialColor from Color
  static MaterialColor _createMaterialColor(Color color) {
    final strengths = <double>[.05];
    final swatch = <int, Color>{};
    final r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }

    for (final strength in strengths) {
      final ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }

    return MaterialColor(color.value, swatch);
  }

  // Get contrast color for text
  Color get contrastColor {
    return brightness == Brightness.dark ? Colors.white : Colors.black;
  }
}