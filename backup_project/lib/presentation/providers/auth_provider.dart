import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import '../../domain/entities/user.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/encryption_service.dart';
import '../../core/constants/app_constants.dart';

part 'auth_provider.g.dart';

@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  final _storage = FlutterSecureStorage();
  late Box<User> _userBox;
  
  @override
  Future<User?> build() async {
    _userBox = await Hive.openBox<User>(AppConstants.userBox);
    return _loadUser();
  }
  
  Future<User?> _loadUser() async {
    try {
      final storedUIN = await _storage.read(key: 'current_uin');
      if (storedUIN == null) return null;
      
      final user = _userBox.get(storedUIN);
      if (user != null) {
        await User.initialize(user: user);
        return user;
      }
    } catch (e) {
      print('Error loading user: $e');
    }
    return null;
  }
  
  Future<void> register({
    required String name,
    String? phoneNumber,
    String? email,
  }) async {
    state = const AsyncLoading();
    
    try {
      // Generate UIN
      final uin = Validators.generateUIN();
      
      // Create user
      final user = User(
        uin: uin,
        name: name,
        phoneNumber: phoneNumber,
        email: email,
        lastSeen: DateTime.now(),
        isOnline: true,
      );
      
      // Save to storage
      await _userBox.put(uin, user);
      await _storage.write(key: 'current_uin', value: uin);
      await User.initialize(user: user);
      
      state = AsyncData(user);
      
      // Notify listeners
      ref.read(userStatusProvider.notifier).setOnline(true);
      
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }
  
  Future<void> login(String uin) async {
    state = const AsyncLoading();
    
    try {
      if (!Validators.isValidUIN(uin)) {
        throw Exception('Invalid UIN');
      }
      
      final user = _userBox.get(uin);
      if (user == null) {
        throw Exception('User not found');
      }
      
      // Update last seen
      final updatedUser = user.copyWith(
        lastSeen: DateTime.now(),
        isOnline: true,
      );
      
      await _userBox.put(uin, updatedUser);
      await _storage.write(key: 'current_uin', value: uin);
      await User.initialize(user: updatedUser);
      
      state = AsyncData(updatedUser);
      
      // Notify listeners
      ref.read(userStatusProvider.notifier).setOnline(true);
      
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }
  
  Future<void> logout() async {
    state = const AsyncLoading();
    
    try {
      final currentUser = state.value;
      if (currentUser != null) {
        // Update user status
        final updatedUser = currentUser.copyWith(
          isOnline: false,
          lastSeen: DateTime.now(),
        );
        await _userBox.put(currentUser.uin, updatedUser);
        
        // Clear encryption keys
        await EncryptionService.clearKeys();
      }
      
      // Clear storage
      await _storage.delete(key: 'current_uin');
      await _userBox.clear();
      
      state = const AsyncData(null);
      
      // Notify listeners
      ref.read(userStatusProvider.notifier).setOnline(false);
      
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }
  
  Future<void> updateProfile({
    String? name,
    String? statusMessage,
    String? avatarUrl,
  }) async {
    final currentUser = state.value;
    if (currentUser == null) return;
    
    state = const AsyncLoading();
    
    try {
      final updatedUser = currentUser.copyWith(
        name: name ?? currentUser.name,
        statusMessage: statusMessage ?? currentUser.statusMessage,
        avatarUrl: avatarUrl ?? currentUser.avatarUrl,
      );
      
      await _userBox.put(currentUser.uin, updatedUser);
      await User.initialize(user: updatedUser);
      
      state = AsyncData(updatedUser);
      
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }
  
  Future<void> deleteAccount() async {
    state = const AsyncLoading();
    
    try {
      final currentUser = state.value;
      if (currentUser != null) {
        await _userBox.delete(currentUser.uin);
      }
      
      await EncryptionService.clearKeys();
      await _storage.deleteAll();
      await _userBox.clear();
      
      state = const AsyncData(null);
      
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }
  
  bool get isLoggedIn => state.value != null;
  
  User? get currentUser => state.value;
  
  String get currentUIN => state.value?.uin ?? AppConstants.defaultUserUIN;
}

// Provider for user online status
@Riverpod(keepAlive: true)
class UserStatus extends _$UserStatus {
  Timer? _statusTimer;
  
  @override
  bool build() {
    final auth = ref.watch(authProvider);
    return auth.value?.isOnline ?? false;
  }
  
  void setOnline(bool online) {
    final auth = ref.read(authProvider.notifier);
    final currentUser = auth.currentUser;
    
    if (currentUser != null) {
      final updatedUser = currentUser.copyWith(
        isOnline: online,
        lastSeen: DateTime.now(),
      );
      
      // Update in background
      auth.updateProfile(
        name: updatedUser.name,
        statusMessage: updatedUser.statusMessage,
        avatarUrl: updatedUser.avatarUrl,
      );
    }
    
    state = online;
  }
  
  void startStatusUpdates() {
    _statusTimer?.cancel();
    _statusTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      setOnline(true);
    });
  }
  
  void stopStatusUpdates() {
    _statusTimer?.cancel();
    _statusTimer = null;
    setOnline(false);
  }
  
  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }
}