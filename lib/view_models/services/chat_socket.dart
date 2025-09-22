import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthapp/repositories/socket_repo.dart';
import 'package:healthapp/view_models/services/auth_services.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class ChatService extends GetxService {
  final SocketRepo socketRepo = SocketRepo();

  final ScrollController scrollController = ScrollController();

  var isConnected = false.obs;
  var messages = <Map<String, dynamic>>[].obs;
  var chats = <Map<String, dynamic>>[].obs;
  var selectedChatId = ''.obs;

  bool _socketInitialized = false; // Track if socket is initialized
  // Replace with the correct pagination controller if using infinite_scroll_pagination package
  // import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
  @override
  void onInit() {
    super.onInit();
    if (!_socketInitialized) {
      initSocket(Get.find<AuthServices>().token);
      _socketInitialized = true;
    }
  }

  // disposeSocket() {
  //   socketRepo.disconnect();
  //   _socketInitialized = false;
  // }

  void initSocket(String token) {
    socketRepo.connect(token);

    socketRepo.onEvent("connect", (_) => isConnected.value = true);
    socketRepo.onEvent("disconnect", (_) => isConnected.value = false);

    // Clear previous listeners before adding new ones
    socketRepo.offEvent('recent_chats');
    socketRepo.offEvent('chat_messages');
    socketRepo.offEvent('message-send');
    socketRepo.offEvent('new_message');
    socketRepo.offEvent('new_chat');

    if (!_socketInitialized) {
      print("Initializing socket connection...");

      socketRepo.onEvent('recent_chats', (data) {
        chats.clear();
        chats.addAll(List<Map<String, dynamic>>.from(data));
        return data;
      });

      socketRepo.onEvent('chat_messages', (data) {
        print("Chat messages received: $data");
        messages.clear();
        messages.addAll(List<Map<String, dynamic>>.from(data));
        // WidgetsBinding.instance.addPostFrameCallback((_) {
        //   if (scrollController.hasClients) {
        //     scrollController.animateTo(
        //       scrollController.position.maxScrollExtent,
        //       // scrollController.position.
        //       duration: const Duration(milliseconds: 300),
        //       curve: Curves.easeOut,
        //     );
        //   }
        // });

        return data;
      });

      socketRepo.onEvent('message-send', (data) {
        messages.insert(0, Map<String, dynamic>.from(data));
      });

      socketRepo.onEvent('new_message', (data) {
        print("New message received: $data");
        messages.insert(0, Map<String, dynamic>.from(data));
        // scrollController.animateTo(
        //   scrollController.position.maxScrollExtent,
        //   duration: const Duration(milliseconds: 300),
        //   curve: Curves.easeOut,
        // );
        return data;
      });

      socketRepo.onEvent("new_chat", (data) {
        print("New chat created: $data[${data['chat_id']}]");
        joinChat(data['chat_id'], data['key'] ?? 0);
        Get.snackbar("New Chat", "A new chat has been created.");
      });
    }
  }

  void fetchChats(int key) {
    socketRepo.emitEvent('get_recent_chats', {"key": key});
  }

  void joinChat(String chatId, int key) {
    selectedChatId.value = chatId;
    print("Joining chat: $chatId");
    socketRepo.emitEvent("select_chat", {"chat_id": chatId, "key": key});
  }

  void sendChatMessage(String chatId, String text) {
    socketRepo.emitEvent("send_message", {"chat_id": chatId, "content": text});
  }

  void leaveChat(String chatId) {
    messages.clear();
    print("leaving chat: $chatId");
    socketRepo.emitEvent("leave_chat", {"chat_id": chatId});
  }

  void createChat(String medical_document_ai_context) {
    socketRepo.emitEvent("create_chat", {
      "medical_document_id": medical_document_ai_context,
    });
  }

  @override
  void onClose() {
    socketRepo.disconnect();
    super.onClose();
  }
}
