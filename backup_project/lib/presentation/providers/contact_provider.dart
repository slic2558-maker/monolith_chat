import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../domain/entities/contact.dart';
import '../../data/repositories/chat_repository.dart';
import '../../core/utils/validators.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';

part 'contact_provider.g.dart';

@Riverpod(keepAlive: true)
class Contact extends _$Contact {
  late ChatRepository _repository;
  
  @override
  Future<List<Contact>> build() async {
    _repository = ref.watch(chatRepositoryProvider);
    await _repository.init();
    return _repository.getContacts();
  }
  
  // Add contact by UIN
  Future<void> addContact({
    required String uin,
    String? name,
    String? customName,
  }) async {
    if (!Validators.isValidUIN(uin)) {
      throw Exception('Invalid UIN format');
    }
    
    // Check if already exists
    final existing = await _repository.getContact(uin);
    if (existing != null) {
      throw Exception('Contact already exists');
    }
    
    // Create contact
    final contact = Contact(
      uin: uin,
      name: name ?? uin,
      customName: customName,
      dateAdded: DateTime.now(),
      lastInteraction: DateTime.now(),
      isOnline: false,
    );
    
    await _repository.saveContact(contact);
    
    // Refresh state
    final contacts = await _repository.getContacts();
    state = AsyncData(contacts);
  }
  
  // Add contact from QR
  Future<void> addContactFromQR(String qrData) async {
    // Parse QR data (assuming format: "MONOLITH_CONTACT:UIN:NAME")
    final parts = qrData.split(':');
    if (parts.length >= 3 && parts[0] == 'MONOLITH_CONTACT') {
      final uin = parts[1];
      final name = parts[2];
      
      await addContact(uin: uin, name: name);
    } else {
      // Try to parse as just UIN
      if (Validators.isValidUIN(qrData)) {
        await addContact(uin: qrData);
      } else {
        throw Exception('Invalid QR code format');
      }
    }
  }
  
  // Remove contact
  Future<void> removeContact(String uin) async {
    await _ensureInitialized();
    
    // Delete contact
    await _repository.deleteContact(uin);
    
    // Also delete chat messages
    final chatProvider = ref.read(chatProvider.notifier);
    await chatProvider.clearChat(uin);
    
    // Refresh state
    final contacts = await _repository.getContacts();
    state = AsyncData(contacts);
  }
  
  // Update contact
  Future<void> updateContact(Contact contact) async {
    await _ensureInitialized();
    await _repository.updateContact(contact);
    
    // Refresh state
    final contacts = await _repository.getContacts();
    state = AsyncData(contacts);
  }
  
  // Create group
  Future<void> createGroup({
    required String name,
    required List<String> memberUINs,
    String? description,
    String? avatar,
  }) async {
    if (!Validators.isValidGroupName(name)) {
      throw Exception('Group name must be 3-100 characters');
    }
    
    if (memberUINs.length < 2) {
      throw Exception('Group must have at least 2 members');
    }
    
    final auth = ref.read(authProvider);
    final currentUIN = auth.value?.uin ?? AppConstants.defaultUserUIN;
    
    // Add current user to members
    final allMembers = [...memberUINs, currentUIN];
    
    // Create group
    final group = Contact.createGroup(
      name: name,
      members: allMembers,
      admin: currentUIN,
      description: description,
      avatar: avatar,
    );
    
    await _repository.saveContact(group);
    
    // Refresh state
    final contacts = await _repository.getContacts();
    state = AsyncData(contacts);
    
    // Send welcome message
    final chatProvider = ref.read(chatProvider.notifier);
    await chatProvider.sendTextMessage(
      chatId: group.id,
      text: 'Группа "$name" создана. Добавлены участники: ${allMembers.length}',
    );
  }
  
  // Add member to group
  Future<void> addMemberToGroup({
    required String groupId,
    required String memberUIN,
  }) async {
    await _ensureInitialized();
    
    final group = await _repository.getContact(groupId);
    if (group == null || !group.isGroup) {
      throw Exception('Group not found');
    }
    
    // Check if user is admin
    final auth = ref.read(authProvider);
    final currentUIN = auth.value?.uin ?? AppConstants.defaultUserUIN;
    
    if (!group.isAdmin(currentUIN)) {
      throw Exception('Only admin can add members');
    }
    
    // Add member
    final updatedGroup = group.copyWith(
      groupMembers: [...group.groupMembers ?? [], memberUIN],
    );
    
    await updateContact(updatedGroup);
    
    // Send system message
    final memberContact = await _repository.getContact(memberUIN);
    final chatProvider = ref.read(chatProvider.notifier);
    
    await chatProvider.sendTextMessage(
      chatId: groupId,
      text: '${memberContact?.displayName ?? memberUIN} добавлен(а) в группу',
    );
  }
  
  // Remove member from group
  Future<void> removeMemberFromGroup({
    required String groupId,
    required String memberUIN,
  }) async {
    await _ensureInitialized();
    
    final group = await _repository.getContact(groupId);
    if (group == null || !group.isGroup) {
      throw Exception('Group not found');
    }
    
    // Check if user is admin or removing themselves
    final auth = ref.read(authProvider);
    final currentUIN = auth.value?.uin ?? AppConstants.defaultUserUIN;
    
    if (memberUIN != currentUIN && !group.isAdmin(currentUIN)) {
      throw Exception('Only admin can remove other members');
    }
    
    // Remove member
    final updatedMembers = group.groupMembers?.where((m) => m != memberUIN).toList() ?? [];
    final updatedGroup = group.copyWith(groupMembers: updatedMembers);
    
    await updateContact(updatedGroup);
    
    // Send system message
    final memberContact = await _repository.getContact(memberUIN);
    final chatProvider = ref.read(chatProvider.notifier);
    
    await chatProvider.sendTextMessage(
      chatId: groupId,
      text: '${memberContact?.displayName ?? memberUIN} удален(а) из группы',
    );
  }
  
  // Update group info
  Future<void> updateGroupInfo({
    required String groupId,
    String? name,
    String? description,
    String? avatar,
  }) async {
    await _ensureInitialized();
    
    final group = await _repository.getContact(groupId);
    if (group == null || !group.isGroup) {
      throw Exception('Group not found');
    }
    
    final updatedGroup = group.copyWith(
      name: name ?? group.name,
      groupDescription: description ?? group.groupDescription,
      groupAvatar: avatar ?? group.groupAvatar,
    );
    
    await updateContact(updatedGroup);
    
    // Send system message if name changed
    if (name != null && name != group.name) {
      final chatProvider = ref.read(chatProvider.notifier);
      await chatProvider.sendTextMessage(
        chatId: groupId,
        text: 'Название группы изменено на "$name"',
      );
    }
  }
  
  // Leave group
  Future<void> leaveGroup(String groupId) async {
    await _ensureInitialized();
    
    final auth = ref.read(authProvider);
    final currentUIN = auth.value?.uin ?? AppConstants.defaultUserUIN;
    
    await removeMemberFromGroup(groupId: groupId, memberUIN: currentUIN);
  }
  
  // Delete group
  Future<void> deleteGroup(String groupId) async {
    await _ensureInitialized();
    
    final group = await _repository.getContact(groupId);
    if (group == null || !group.isGroup) {
      throw Exception('Group not found');
    }
    
    // Check if user is admin
    final auth = ref.read(authProvider);
    final currentUIN = auth.value?.uin ?? AppConstants.defaultUserUIN;
    
    if (!group.isAdmin(currentUIN)) {
      throw Exception('Only admin can delete group');
    }
    
    // Delete group contact
    await _repository.deleteContact(groupId);
    
    // Clear group chat
    final chatProvider = ref.read(chatProvider.notifier);
    await chatProvider.clearChat(groupId);
    
    // Refresh state
    final contacts = await _repository.getContacts();
    state = AsyncData(contacts);
  }
  
  // Toggle favorite
  Future<void> toggleFavorite(String uin) async {
    await _ensureInitialized();
    await _repository.toggleFavorite(uin);
    
    // Refresh state
    final contacts = await _repository.getContacts();
    state = AsyncData(contacts);
  }
  
  // Toggle mute
  Future<void> toggleMute(String uin, {Duration? duration}) async {
    await _ensureInitialized();
    await _repository.toggleMute(uin, duration: duration);
    
    // Refresh state
    final contacts = await _repository.getContacts();
    state = AsyncData(contacts);
  }
  
  // Update contact status
  Future<void> updateContactStatus({
    required String uin,
    required bool isOnline,
    DateTime? lastSeen,
  }) async {
    await _ensureInitialized();
    
    final contact = await _repository.getContact(uin);
    if (contact != null) {
      final updatedContact = contact.copyWith(
        isOnline: isOnline,
        lastSeen: lastSeen ?? DateTime.now(),
      );
      
      await updateContact(updatedContact);
    }
  }
  
  // Search contacts
  Future<List<Contact>> searchContacts(String query) async {
    await _ensureInitialized();
    return _repository.searchContacts(query);
  }
  
  // Get contact by UIN (sync for UI)
  Contact? getContactSync(String uin) {
    final contacts = state.value;
    if (contacts == null) return null;
    
    return contacts.firstWhere(
      (contact) => contact.uin == uin,
      orElse: () => Contact(uin: '', name: ''),
    );
  }
  
  // Get all groups
  Future<List<Contact>> getGroups() async {
    await _ensureInitialized();
    return _repository.getGroups();
  }
  
  // Get favorites
  Future<List<Contact>> getFavorites() async {
    await _ensureInitialized();
    return _repository.getFavorites();
  }
  
  // Get chat list (contacts + groups sorted by last interaction)
  List<Contact> getChatList() {
    final contacts = state.value;
    if (contacts == null) return [];
    
    return List<Contact>.from(contacts)
      ..sort((a, b) => b.lastInteraction.compareTo(a.lastInteraction));
  }
  
  // Check if contact exists
  Future<bool> contactExists(String uin) async {
    await _ensureInitialized();
    final contact = await _repository.getContact(uin);
    return contact != null && contact.uin.isNotEmpty;
  }
  
  // Generate QR data for contact
  String generateQRData() {
    final auth = ref.read(authProvider);
    final user = auth.value;
    
    if (user == null) return '';
    
    return 'MONOLITH_CONTACT:${user.uin}:${user.name}';
  }
  
  // Helper method
  Future<void> _ensureInitialized() async {
    if (state.value == null) {
      await future;
    }
  }
}

// Provider for QR scanner
@Riverpod(keepAlive: true)
class QRScanner extends _$QRScanner {
  MobileScannerController? _controller;
  
  @override
  MobileScannerController? build() {
    return null;
  }
  
  void initialize() {
    if (_controller == null) {
      _controller = MobileScannerController(
        formats: [BarcodeFormat.qrCode],
        autoStart: true,
        detectionSpeed: DetectionSpeed.normal,
        detectionTimeoutMs: 1000,
        returnImage: false,
      );
      
      state = _controller;
    }
  }
  
  void start() {
    _controller?.start();
  }
  
  void stop() {
    _controller?.stop();
  }
  
  void toggleTorch() {
    if (_controller != null) {
      _controller!.torchState = _controller!.torchState == TorchState.on
          ? TorchState.off
          : TorchState.on;
    }
  }
  
  void switchCamera() {
    if (_controller != null) {
      _controller!.switchCamera();
    }
  }
  
  @override
  void dispose() {
    _controller?.dispose();
    _controller = null;
    super.dispose();
  }
}