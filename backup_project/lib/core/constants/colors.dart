import 'package:flutter/material.dart';

/// WhatsApp-подобная цветовая палитра
class AppColors {
  // Основные цвета WhatsApp
  static const Color primary = Color(0xFF075E54);       // Темно-зеленый
  static const Color primaryDark = Color(0xFF054D44);   // Еще темнее зеленый
  static const Color primaryLight = Color(0xFF128C7E);  // Светло-зеленый
  static const Color accent = Color(0xFF25D366);        // Ярко-зеленый (лайк/галочки)
  
  // Фоновые цвета
  static const Color background = Color(0xFFECE5DD);    // Кремовый фон чатов
  static const Color scaffoldBackground = Color(0xFFF0F0F0); // Фон всего приложения
  static const Color appBarBackground = Color(0xFF075E54);   // Фон AppBar
  
  // Цвета сообщений
  static const Color messageSent = Color(0xFFDCF8C6);   // Отправленные сообщения
  static const Color messageReceived = Color(0xFFFFFFFF); // Полученные сообщения
  static const Color messageTime = Color(0xFF667781);   // Время сообщений
  static const Color messageStatus = Color(0xFF34B7F1); // Статус доставки/прочтения
  
  // Текстовые цвета
  static const Color textPrimary = Color(0xFF000000);   // Основной текст
  static const Color textSecondary = Color(0xFF667781); // Вторичный текст (подписи)
  static const Color textHint = Color(0xFF9AA6AC);      // Текст подсказок
  static const Color textLight = Color(0xFFFFFFFF);     // Белый текст
  static const Color textLink = Color(0xFF34B7F1);      // Ссылки/активные элементы
  
  // Иконки
  static const Color iconPrimary = Color(0xFF075E54);   // Основные иконки
  static const Color iconSecondary = Color(0xFF667781); // Вторичные иконки
  static const Color iconLight = Color(0xFFFFFFFF);     // Белые иконки
  
  // Разделители и границы
  static const Color divider = Color(0xFFE0E0E0);       // Разделители
  static const Color border = Color(0xFFDDDDDD);        // Границы
  static const Color shadow = Color(0x1A000000);        // Тени
  
  // Элементы интерфейса
  static const Color card = Color(0xFFFFFFFF);          // Карточки
  static const Color button = Color(0xFF25D366);        // Основная кнопка
  static const Color buttonText = Color(0xFFFFFFFF);    // Текст на кнопке
  static const Color fab = Color(0xFF25D366);           // Плавающая кнопка
  
  // Статусы и индикаторы
  static const Color onlineStatus = Color(0xFF4CAF50);  // Онлайн статус
  static const Color offlineStatus = Color(0xFF9E9E9E); // Оффлайн статус
  static const Color typingIndicator = Color(0xFF25D366); // Индикатор набора
  static const Color unreadBadge = Color(0xFF25D366);   // Бейдж непрочитанных
  static const Color mentionHighlight = Color(0xFFFFEB3B); // Подсветка упоминаний
  
  // Вкладки (табы)
  static const Color tabSelected = Color(0xFFFFFFFF);   // Выбранная вкладка
  static const Color tabUnselected = Color(0xB3FFFFFF); // Невыбранная вкладка
  static const Color tabIndicator = Color(0xFFFFFFFF);  // Индикатор вкладки
  
  // Поиск
  static const Color searchBackground = Color(0xFFF6F6F6); // Фон поиска
  static const Color searchIcon = Color(0xFF757575);    // Иконка поиска
  
  // Уведомления
  static const Color notification = Color(0xFFF44336);  // Красный для уведомлений
  static const Color warning = Color(0xFFFF9800);       // Оранжевый предупреждения
  
  // Градиенты (если нужны)
  static const Gradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF075E54), Color(0xFF128C7E)],
  );
  
  static const Gradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF25D366), Color(0xFF4CAF50)],
  );
}

/// Тёмная тема (WhatsApp Dark Mode)
class DarkAppColors {
  // Основные цвета
  static const Color primary = Color(0xFF075E54);       // Сохраняем тот же зеленый
  static const Color primaryDark = Color(0xFF054D44);
  static const Color primaryLight = Color(0xFF128C7E);
  static const Color accent = Color(0xFF25D366);
  
  // Фоновые цвета
  static const Color background = Color(0xFF121212);    // Темный фон
  static const Color scaffoldBackground = Color(0xFF121212);
  static const Color appBarBackground = Color(0xFF1F1F1F); // Темный AppBar
  
  // Цвета сообщений
  static const Color messageSent = Color(0xFF005C4B);   // Темно-зеленый для отправленных
  static const Color messageReceived = Color(0xFF1F2C34); // Темный для полученных
  static const Color messageTime = Color(0xFF8696A0);   // Серое время
  static const Color messageStatus = Color(0xFF53BDEB); // Голубой статус
  
  // Текстовые цвета
  static const Color textPrimary = Color(0xFFE9EDEF);   // Светлый текст
  static const Color textSecondary = Color(0xFF8696A0); // Серый текст
  static const Color textHint = Color(0xFF667781);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textLink = Color(0xFF53BDEB);
  
  // Иконки
  static const Color iconPrimary = Color(0xFFE9EDEF);
  static const Color iconSecondary = Color(0xFF8696A0);
  static const Color iconLight = Color(0xFFFFFFFF);
  
  // Разделители
  static const Color divider = Color(0xFF2A3942);
  static const Color border = Color(0xFF2A3942);
  static const Color shadow = Color(0x1AFFFFFF);
  
  // Элементы интерфейса
  static const Color card = Color(0xFF1F2C34);
  static const Color button = Color(0xFF00A884);
  static const Color buttonText = Color(0xFFFFFFFF);
  static const Color fab = Color(0xFF00A884);
  
  // Статусы
  static const Color onlineStatus = Color(0xFF25D366);
  static const Color offlineStatus = Color(0xFF8A8A8A);
  static const Color typingIndicator = Color(0xFF25D366);
  static const Color unreadBadge = Color(0xFF25D366);
  static const Color mentionHighlight = Color(0xFFFFD740);
}

/// Расширения для удобства использования
extension CustomTheme on Color {
  /// Создает ColorScheme из AppColors
  static ColorScheme get lightColorScheme => const ColorScheme.light(
    primary: AppColors.primary,
    primaryContainer: AppColors.primaryDark,
    secondary: AppColors.accent,
    secondaryContainer: AppColors.primaryLight,
    surface: AppColors.card,
    background: AppColors.background,
    error: AppColors.notification,
    onPrimary: AppColors.textLight,
    onSecondary: AppColors.textLight,
    onSurface: AppColors.textPrimary,
    onBackground: AppColors.textPrimary,
    onError: AppColors.textLight,
    brightness: Brightness.light,
  );

  static ColorScheme get darkColorScheme => const ColorScheme.dark(
    primary: DarkAppColors.primary,
    primaryContainer: DarkAppColors.primaryDark,
    secondary: DarkAppColors.accent,
    secondaryContainer: DarkAppColors.primaryLight,
    surface: DarkAppColors.card,
    background: DarkAppColors.background,
    error: DarkAppColors.notification,
    onPrimary: DarkAppColors.textLight,
    onSecondary: DarkAppColors.textLight,
    onSurface: DarkAppColors.textPrimary,
    onBackground: DarkAppColors.textPrimary,
    onError: DarkAppColors.textLight,
    brightness: Brightness.dark,
  );

  /// Получить тему приложения
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: lightColorScheme,
    scaffoldBackgroundColor: AppColors.scaffoldBackground,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.appBarBackground,
      foregroundColor: AppColors.textLight,
      elevation: 0,
      centerTitle: false,
      iconTheme: const IconThemeData(color: AppColors.iconLight),
      titleTextStyle: const TextStyle(
        color: AppColors.textLight,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.appBarBackground,
      selectedItemColor: AppColors.textLight,
      unselectedItemColor: AppColors.tabUnselected,
      elevation: 8,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.fab,
      foregroundColor: AppColors.textLight,
    ),
    cardTheme: const CardTheme(
      color: AppColors.card,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 0.5,
      space: 1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: AppColors.accent, width: 1),
      ),
      hintStyle: const TextStyle(color: AppColors.textHint),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: AppColors.textPrimary),
      displayMedium: TextStyle(color: AppColors.textPrimary),
      displaySmall: TextStyle(color: AppColors.textPrimary),
      headlineLarge: TextStyle(color: AppColors.textPrimary),
      headlineMedium: TextStyle(color: AppColors.textPrimary),
      headlineSmall: TextStyle(color: AppColors.textPrimary),
      titleLarge: TextStyle(color: AppColors.textPrimary),
      titleMedium: TextStyle(color: AppColors.textPrimary),
      titleSmall: TextStyle(color: AppColors.textPrimary),
      bodyLarge: TextStyle(color: AppColors.textPrimary),
      bodyMedium: TextStyle(color: AppColors.textPrimary),
      bodySmall: TextStyle(color: AppColors.textSecondary),
      labelLarge: TextStyle(color: AppColors.textLight),
      labelMedium: TextStyle(color: AppColors.textSecondary),
      labelSmall: TextStyle(color: AppColors.textHint),
    ),
    iconTheme: const IconThemeData(color: AppColors.iconPrimary),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    colorScheme: darkColorScheme,
    scaffoldBackgroundColor: DarkAppColors.scaffoldBackground,
    appBarTheme: AppBarTheme(
      backgroundColor: DarkAppColors.appBarBackground,
      foregroundColor: DarkAppColors.textLight,
      elevation: 0,
      centerTitle: false,
      iconTheme: const IconThemeData(color: DarkAppColors.iconLight),
      titleTextStyle: const TextStyle(
        color: DarkAppColors.textLight,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: DarkAppColors.appBarBackground,
      selectedItemColor: DarkAppColors.textLight,
      unselectedItemColor: DarkAppColors.textSecondary,
      elevation: 8,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: DarkAppColors.fab,
      foregroundColor: DarkAppColors.textLight,
    ),
    cardTheme: const CardTheme(
      color: DarkAppColors.card,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: DarkAppColors.divider,
      thickness: 0.5,
      space: 1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: DarkAppColors.card,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: DarkAppColors.accent, width: 1),
      ),
      hintStyle: const TextStyle(color: DarkAppColors.textHint),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: DarkAppColors.textPrimary),
      displayMedium: TextStyle(color: DarkAppColors.textPrimary),
      displaySmall: TextStyle(color: DarkAppColors.textPrimary),
      headlineLarge: TextStyle(color: DarkAppColors.textPrimary),
      headlineMedium: TextStyle(color: DarkAppColors.textPrimary),
      headlineSmall: TextStyle(color: DarkAppColors.textPrimary),
      titleLarge: TextStyle(color: DarkAppColors.textPrimary),
      titleMedium: TextStyle(color: DarkAppColors.textPrimary),
      titleSmall: TextStyle(color: DarkAppColors.textPrimary),
      bodyLarge: TextStyle(color: DarkAppColors.textPrimary),
      bodyMedium: TextStyle(color: DarkAppColors.textPrimary),
      bodySmall: TextStyle(color: DarkAppColors.textSecondary),
      labelLarge: TextStyle(color: DarkAppColors.textLight),
      labelMedium: TextStyle(color: DarkAppColors.textSecondary),
      labelSmall: TextStyle(color: DarkAppColors.textHint),
    ),
    iconTheme: const IconThemeData(color: DarkAppColors.iconPrimary),
  );
}

/// Утилиты для работы с цветами
class ColorUtils {
  /// Затемнить цвет
  static Color darken(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  /// Осветлить цвет
  static Color lighten(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }

  /// Сделать цвет прозрачным
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  /// Получить контрастный текст для фона
  static Color getContrastText(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? AppColors.textPrimary : AppColors.textLight;
  }
}