import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_themes.dart';

part 'theme_provider.g.dart';

@Riverpod(keepAlive: true)
class Theme extends _$Theme {
  late SharedPreferences _prefs;
  
  @override
  Future<AppTheme> build() async {
    _prefs = await SharedPreferences.getInstance();
    
    final themeIndex = _prefs.getInt('selected_theme') ?? 0;
    final themeType = ThemeType.values[themeIndex];
    
    return AppTheme.fromType(themeType);
  }
  
  // Get current theme as ThemeData
  ThemeData get currentThemeData {
    final theme = state.value ?? AppTheme.whatsappGreen;
    return theme.toThemeData();
  }
  
  // Change theme
  Future<void> changeTheme(ThemeType themeType) async {
    state = const AsyncLoading();
    
    try {
      final theme = AppTheme.fromType(themeType);
      await _prefs.setInt('selected_theme', themeType.index);
      state = AsyncData(theme);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }
  
  // Toggle dark/light
  Future<void> toggleDarkMode() async {
    final current = state.value ?? AppTheme.whatsappGreen;
    
    if (current.type == ThemeType.dark) {
      await changeTheme(ThemeType.whatsappGreen);
    } else {
      await changeTheme(ThemeType.dark);
    }
  }
  
  // Get all available themes
  List<AppTheme> get availableThemes => AppTheme.allThemes;
  
  // Check if dark mode is enabled
  bool get isDarkMode {
    final theme = state.value;
    return theme?.brightness == Brightness.dark;
  }
}

// Provider for dynamic colors based on theme
@Riverpod(keepAlive: true)
ThemeColors themeColors(ThemeColorsRef ref) {
  final theme = ref.watch(themeProvider);
  final themeValue = theme.value ?? AppTheme.whatsappGreen;
  
  return ThemeColors(
    primary: themeValue.primaryColor,
    secondary: themeValue.secondaryColor,
    background: themeValue.backgroundColor,
    card: themeValue.cardColor,
    text: themeValue.textColor,
    bubbleSent: themeValue.bubbleSentColor,
    bubbleReceived: themeValue.bubbleReceivedColor,
    online: themeValue.onlineIndicator,
    typing: themeValue.typingIndicator,
  );
}

class ThemeColors {
  final Color primary;
  final Color secondary;
  final Color background;
  final Color card;
  final Color text;
  final Color bubbleSent;
  final Color bubbleReceived;
  final Color online;
  final Color typing;
  
  ThemeColors({
    required this.primary,
    required this.secondary,
    required this.background,
    required this.card,
    required this.text,
    required this.bubbleSent,
    required this.bubbleReceived,
    required this.online,
    required this.typing,
  });
}

// Provider for font size
@Riverpod(keepAlive: true)
class FontSize extends _$FontSize {
  late SharedPreferences _prefs;
  
  @override
  double build() {
    _prefs = ref.watch(_sharedPreferencesProvider);
    return _prefs.getDouble('font_size') ?? 1.0;
  }
  
  Future<void> setSize(double size) async {
    await _prefs.setDouble('font_size', size.clamp(0.8, 1.5));
    state = size;
  }
  
  double get scaleFactor => state;
}

// Provider for bubble style
@Riverpod(keepAlive: true)
class BubbleStyle extends _$BubbleStyle {
  late SharedPreferences _prefs;
  
  @override
  Map<String, dynamic> build() {
    _prefs = ref.watch(_sharedPreferencesProvider);
    
    final borderRadius = _prefs.getDouble('bubble_radius') ?? 16.0;
    final showTail = _prefs.getBool('bubble_tail') ?? true;
    final elevation = _prefs.getDouble('bubble_elevation') ?? 2.0;
    
    return {
      'borderRadius': borderRadius,
      'showTail': showTail,
      'elevation': elevation,
    };
  }
  
  Future<void> updateStyle({
    double? borderRadius,
    bool? showTail,
    double? elevation,
  }) async {
    final current = Map<String, dynamic>.from(state);
    
    if (borderRadius != null) {
      await _prefs.setDouble('bubble_radius', borderRadius);
      current['borderRadius'] = borderRadius;
    }
    
    if (showTail != null) {
      await _prefs.setBool('bubble_tail', showTail);
      current['showTail'] = showTail;
    }
    
    if (elevation != null) {
      await _prefs.setDouble('bubble_elevation', elevation);
      current['elevation'] = elevation;
    }
    
    state = current;
  }
}

// SharedPreferences provider
@Riverpod(keepAlive: true)
Future<SharedPreferences> _sharedPreferences(_SharedPreferencesRef ref) async {
  return await SharedPreferences.getInstance();
}