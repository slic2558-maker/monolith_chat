import 'dart:convert';
import 'package:flutter/material.dart';

class AppConstants {
  // App Info
  static const String appName = 'Monolith Chat';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';
  
  // UIN System
  static const int uinLength = 6;
  static const String uinRegex = r'^\d{6}$';
  
  // Current User
  static const String defaultUserUIN = '428971';
  static const String defaultUserName = 'You';
  
  // Message Limits
  static const int maxMessageLength = 1000;
  static const int maxVoiceDuration = 300; // 5 minutes
  
  // Pagination
  static const int messagesPerPage = 50;
  static const int contactsPerPage = 100;
  
  // Paths
  static const String messagesBox = 'messages_box';
  static const String contactsBox = 'contacts_box';
  static const String userBox = 'user_box';
  
  // Colors
  static const Color whatsappGreen = Color(0xFF075E54);
  static const Color whatsappLightGreen = Color(0xFF25D366);
  static const Color whatsappTealGreen = Color(0xFF128C7E);
  static const Color chatBackground = Color(0xFFECE5DD);
  static const Color messageSent = Color(0xFFDCF8C6);
  static const Color messageReceived = Color(0xFFFFFFFF);
  static const Color onlineGreen = Color(0xFF4CAF50);
  static const Color readReceipt = Color(0xFF34B7F1);
  
  // Validation Messages
  static const String invalidUIN = 'UIN должен состоять из 6 цифр';
  static const String invalidName = 'Имя должно содержать от 2 до 50 символов';
  static const String messageEmpty = 'Сообщение не может быть пустым';
}