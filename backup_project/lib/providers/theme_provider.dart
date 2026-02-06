import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'isDarkMode';
  static const String _themeTypeKey = 'themeType';
  
  bool _isDarkMode = false;
  ThemeType _themeType = ThemeType.whatsappGreen;
  
  ThemeProvider() {
    _loadTheme();
  }
  
  bool get isDarkMode => _isDarkMode;
  ThemeType get themeType => _themeType;
  
  // Получить текущую тему
  ThemeData get currentTheme {
    switch (_themeType) {
      case ThemeType.whatsappGreen:
        return _isDarkMode ? _getWhatsAppDarkTheme() : _getWhatsAppLightTheme();
      case ThemeType.dark:
        return _getDarkTheme();
      case ThemeType.light:
        return _getLightTheme();
      case ThemeType.blue:
        return _isDarkMode ? _getBlueDarkTheme() : _getBlueLightTheme();
      case ThemeType.purple:
        return _isDarkMode ? _getPurpleDarkTheme() : _getPurpleLightTheme();
      case ThemeType.amoled:
        return _getAmoledTheme();
      case ThemeType.custom:
        return _getCustomTheme();
    }
  }
  
  // Загрузить настройки темы
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_themeKey) ?? false;
    
    final savedType = prefs.getInt(_themeTypeKey) ?? 0;
    _themeType = ThemeType.values[savedType];
    
    notifyListeners();
  }
  
  // Сохранить настройки темы
  Future<void> _saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _isDarkMode);
    await prefs.setInt(_themeTypeKey, _themeType.index);
  }
  
  // Переключить темную/светлую тему
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _saveTheme();
    notifyListeners();
  }
  
  // Изменить тип темы
  Future<void> changeThemeType(ThemeType type) async {
    _themeType = type;
    await _saveTheme();
    notifyListeners();
  }
  
  // WhatsApp светлая тема (точные цвета WhatsApp)
  ThemeData _getWhatsAppLightTheme() {
    return ThemeData.light().copyWith(
      primaryColor: const Color(0xFF075E54),
      primaryColorDark: const Color(0xFF054D44),
      primaryColorLight: const Color(0xFF128C7E),
      hintColor: const Color(0xFF25D366),
      scaffoldBackgroundColor: const Color(0xFFECE5DD),
      backgroundColor: const Color(0xFFECE5DD),
      cardColor: Colors.white,
      dialogBackgroundColor: Colors.white,
      canvasColor: Colors.white,
      dividerColor: const Color(0xFFE0E0E0),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF075E54),
        foregroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF25D366),
        foregroundColor: Colors.white,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF075E54),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Color(0xFF128C7E), width: 2),
        ),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Colors.black,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Color(0xFF667781),
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: Color(0xFF667781),
        ),
      ),
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: _createMaterialColor(const Color(0xFF075E54)),
        backgroundColor: const Color(0xFFECE5DD),
        cardColor: Colors.white,
        errorColor: Colors.red,
      ),
    );
  }
  
  // WhatsApp темная тема
  ThemeData _getWhatsAppDarkTheme() {
    return ThemeData.dark().copyWith(
      primaryColor: const Color(0xFF1F2C34),
      primaryColorDark: const Color(0xFF121B22),
      primaryColorLight: const Color(0xFF2A3942),
      hintColor: const Color(0xFF00A884),
      scaffoldBackgroundColor: const Color(0xFF121B22),
      backgroundColor: const Color(0xFF121B22),
      cardColor: const Color(0xFF1F2C34),
      dialogBackgroundColor: const Color(0xFF1F2C34),
      canvasColor: const Color(0xFF1F2C34),
      dividerColor: const Color(0xFF26333D),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1F2C34),
        foregroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF00A884),
        foregroundColor: Colors.white,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1F2C34),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1F2C34),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Color(0xFF00A884), width: 2),
        ),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Colors.white,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Color(0xFF8696A0),
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: Color(0xFF8696A0),
        ),
      ),
      colorScheme: ColorScheme.fromSwatch(
        brightness: Brightness.dark,
        primarySwatch: _createMaterialColor(const Color(0xFF00A884)),
        backgroundColor: const Color(0xFF121B22),
        cardColor: const Color(0xFF1F2C34),
        errorColor: const Color(0xFFFF6B6B),
      ),
    );
  }
  
  // Другие темы
  ThemeData _getDarkTheme() => ThemeData.dark();
  ThemeData _getLightTheme() => ThemeData.light();
  
  ThemeData _getBlueLightTheme() {
    return ThemeData.light().copyWith(
      primaryColor: const Color(0xFF1A73E8),
      scaffoldBackgroundColor: const Color(0xFFE8F0FE),
    );
  }
  
  ThemeData _getBlueDarkTheme() {
    return ThemeData.dark().copyWith(
      primaryColor: const Color(0xFF1A73E8),
      scaffoldBackgroundColor: const Color(0xFF0D1117),
    );
  }
  
  ThemeData _getPurpleLightTheme() {
    return ThemeData.light().copyWith(
      primaryColor: const Color(0xFF6F42C1),
      scaffoldBackgroundColor: const Color(0xFFF3E5F5),
    );
  }
  
  ThemeData _getPurpleDarkTheme() {
    return ThemeData.dark().copyWith(
      primaryColor: const Color(0xFF6F42C1),
      scaffoldBackgroundColor: const Color(0xFF1A1A2E),
    );
  }
  
  ThemeData _getAmoledTheme() {
    return ThemeData.dark().copyWith(
      primaryColor: Colors.black,
      scaffoldBackgroundColor: Colors.black,
      backgroundColor: Colors.black,
      cardColor: const Color(0xFF111111),
      canvasColor: Colors.black,
      dialogBackgroundColor: const Color(0xFF111111),
    );
  }
  
  ThemeData _getCustomTheme() {
    // TODO: Реализовать кастомную тему
    return _getWhatsAppLightTheme();
  }
  
  // Создание MaterialColor из Color
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
  
  // Получить список всех доступных тем
  List<ThemeType> get availableThemes => ThemeType.values;
  
  // Получить название темы
  String getThemeName(ThemeType type) {
    switch (type) {
      case ThemeType.whatsappGreen:
        return 'WhatsApp';
      case ThemeType.dark:
        return 'Тёмная';
      case ThemeType.light:
        return 'Светлая';
      case ThemeType.blue:
        return 'Синяя';
      case ThemeType.purple:
        return 'Фиолетовая';
      case ThemeType.amoled:
        return 'AMOLED';
      case ThemeType.custom:
        return 'Своя';
    }
  }
}

enum ThemeType {
  whatsappGreen,
  dark,
  light,
  blue,
  purple,
  amoled,
  custom,
}