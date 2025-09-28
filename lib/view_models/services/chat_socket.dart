import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthapp/repositories/socket_repo.dart';
import 'package:healthapp/view_models/services/auth_services.dart';
import 'package:healthapp/views/messages_page.dart';

class ChatService extends GetxService {
  final SocketRepo socketRepo = Get.put(SocketRepo());

  final ScrollController scrollController = ScrollController();

  var isConnected = false.obs;
  var messages = <Map<String, dynamic>>[].obs;
  var chats = <Map<String, dynamic>>[].obs;
  var selectedChatId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Get the current token and initialize socket
    final currentToken = Get.find<AuthServices>().token.value;
    log(
      "🚀 ChatService initializing with token: ${currentToken.isEmpty ? 'EMPTY' : '${currentToken.substring(0, 10)}...'}",
    );

    if (currentToken.isNotEmpty) {
      initSocket(currentToken);
    }
  }

  /// Reinitialize socket connection with new token
  void reinitializeWithToken(String newToken) {
    log(
      "🔄 Reinitializing socket with new token: ${newToken.isEmpty ? 'EMPTY' : '${newToken.substring(0, 10)}...'}",
    );

    // Clear old state
    messages.clear();
    chats.clear();
    selectedChatId.value = '';
    isConnected.value = false;

    // Initialize with new token
    if (newToken.isNotEmpty) {
      initSocket(newToken);
    }
  }

  void initSocket(String token) {
    log(
      "🔌 Initializing socket with token: ${token.isEmpty ? 'EMPTY' : '${token.substring(0, 10)}...'}",
    );

    socketRepo.connect(token);

    socketRepo.onEvent("connect", (_) {
      isConnected.value = true;
      log("✅ Socket connected successfully");
    });

    socketRepo.onEvent("disconnect", (_) {
      isConnected.value = false;
      log("❌ Socket disconnected");
    });

    // Clear previous listeners before adding new ones
    socketRepo.offEvent('recent_chats');
    socketRepo.offEvent('chat_messages');
    socketRepo.offEvent('message-send');
    socketRepo.offEvent('new_message');
    socketRepo.offEvent('new_chat');

    // Set up event listeners
    _setupEventListeners();
  }

  void _setupEventListeners() {
    log("📡 Setting up socket event listeners...");

    socketRepo.onEvent('recent_chats', (data) {
      log("📨 Received recent_chats: ${data.length} chats");
      chats.clear();
      chats.addAll(List<Map<String, dynamic>>.from(data));
    });

    socketRepo.onEvent('chat_messages', (data) {
      log("💬 Received chat_messages: ${data.length} messages");
      messages.clear();
      messages.addAll(List<Map<String, dynamic>>.from(data));
    });

    socketRepo.onEvent('message-send', (data) {
      log("✉️ Message sent successfully");
      messages.insert(0, Map<String, dynamic>.from(data));
    });

    socketRepo.onEvent('new_message', (data) {
      log("🆕 New message received");
      messages.insert(0, Map<String, dynamic>.from(data));
    });

    socketRepo.onEvent("new_chat", (data) {
      log("💬 New chat created: ${data['chat_id']}");
      Get.to(
        () => MessagesPageScreen(),
        arguments: {"room_id": data['chat_id'] ?? ""},
      );
      joinChat(data['chat_id'], data['key'] ?? 0);
      Get.snackbar("New Chat", "A new chat has been created.");
    });
  }

  void fetchChats(int key) {
    log("📥 Fetching chats with key: $key");
    socketRepo.emitEvent('get_recent_chats', {"key": key});
  }

  void joinChat(String chatId, int key) {
    selectedChatId.value = chatId;
    log("🏠 Joining chat: $chatId");
    socketRepo.emitEvent("select_chat", {"chat_id": chatId, "key": key});
  }

  void sendChatMessage(String chatId, String text) {
    log("📤 Sending message to chat: $chatId");
    socketRepo.emitEvent("send_message", {"chat_id": chatId, "content": text});
  }

  void leaveChat(String chatId) {
    messages.clear();
    log("🚪 Leaving chat: $chatId");
    socketRepo.emitEvent("leave_chat", {"chat_id": chatId});
  }

  void createChat(String medical_document_id) {
    log("➕ Creating chat for document: $medical_document_id");
    socketRepo.emitEvent("create_chat", {
      "medical_document_id": medical_document_id,
    });
  }

  @override
  void onClose() {
    log("🧹 ChatService closing...");
    socketRepo.disconnect();
    super.onClose();
  }
}
