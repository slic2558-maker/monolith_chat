import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioRecorderProvider with ChangeNotifier {
  final AudioRecorder _audioRecorder = AudioRecorder();
  
  bool _isRecording = false;
  bool _hasPermission = false;
  String? _currentFilePath;
  Timer? _recordingTimer;
  int _recordingDuration = 0; // в секундах
  
  bool get isRecording => _isRecording;
  String? get currentFilePath => _currentFilePath;
  int get recordingDuration => _recordingDuration;
  
  AudioRecorderProvider() {
    _init();
  }
  
  Future<void> _init() async {
    _hasPermission = await _checkPermission();
  }
  
  Future<bool> _checkPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }
  
  Future<void> startRecording() async {
    if (!_hasPermission) {
      _hasPermission = await _checkPermission();
      if (!_hasPermission) return;
    }
    
    try {
      // Создаем папку для аудио
      final directory = await getApplicationDocumentsDirectory();
      final audioDir = Directory('${directory.path}/audio_messages');
      if (!await audioDir.exists()) {
        await audioDir.create(recursive: true);
      }
      
      // Генерируем имя файла
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _currentFilePath = '${audioDir.path}/audio_$timestamp.m4a';
      
      // Начинаем запись
      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          samplingRate: 44100,
        ),
        path: _currentFilePath,
      );
      
      _isRecording = true;
      _recordingDuration = 0;
      
      // Таймер для отсчета времени
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _recordingDuration++;
        notifyListeners();
      });
      
      notifyListeners();
      
    } catch (e) {
      print('Ошибка записи аудио: $e');
      _isRecording = false;
      notifyListeners();
    }
  }
  
  Future<String?> stopRecording() async {
    if (!_isRecording) return null;
    
    try {
      _recordingTimer?.cancel();
      _recordingTimer = null;
      
      final path = await _audioRecorder.stop();
      _isRecording = false;
      
      notifyListeners();
      return path;
      
    } catch (e) {
      print('Ошибка остановки записи: $e');
      _isRecording = false;
      notifyListeners();
      return null;
    }
  }
  
  Future<void> cancelRecording() async {
    if (_isRecording) {
      await _audioRecorder.stop();
      _recordingTimer?.cancel();
      _recordingTimer = null;
      _isRecording = false;
      
      // Удаляем файл
      if (_currentFilePath != null) {
        final file = File(_currentFilePath!);
        if (await file.exists()) {
          await file.delete();
        }
      }
      
      notifyListeners();
    }
  }
  
  String get formattedDuration {
    final minutes = (_recordingDuration ~/ 60).toString().padLeft(2, '0');
    final seconds = (_recordingDuration % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
  
  @override
  void dispose() {
    _recordingTimer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }
}