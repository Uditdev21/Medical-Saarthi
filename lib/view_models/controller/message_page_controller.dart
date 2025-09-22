import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../services/chat_socket.dart';

class MessagePageController extends GetxController {
  late final String chatRoomID;
  late final PagingController<int, Map<String, dynamic>>
  chatPaginationController;

  final ChatService chatService = Get.find<ChatService>();
  final TextEditingController messageController = TextEditingController();

  @override
  void onInit() {
    super.onInit();

    chatRoomID = Get.arguments["room_id"];
    log("Chat Room ID in MessagePageController: $chatRoomID");

    chatPaginationController = PagingController(
      getNextPageKey: (PagingState<int, Map<String, dynamic>> state) {
        if (state.pages == null || state.pages!.isEmpty) return 0;

        final lastPage = state.pages!.last;
        if (lastPage.length < 10) return null;

        final currentPage = state.keys!.last;
        return currentPage + 1;
      },
      fetchPage: (int pageKey) async {
        log("Fetching page: $pageKey for chatRoomID: $chatRoomID");
        chatService.joinChat(chatRoomID, pageKey);

        final completer = Completer<List<Map<String, dynamic>>>();

        late void Function(dynamic) listener;
        listener = (data) {
          log("Received chat messages: $data");
          if (!completer.isCompleted) {
            completer.complete(List<Map<String, dynamic>>.from(data));
          }
          chatService.socketRepo.offEvent('chat_messages');
        };

        chatService.socketRepo.onEvent('chat_messages', listener);

        return await completer.future;
      },
    );
  }

  void addNewMessage(Map<String, dynamic> message) {
    final currentPages = chatPaginationController.value.pages ?? [];
    final currentKeys = chatPaginationController.value.keys ?? [];
    // Add the new message to the first page (most recent)
    List<List<Map<String, dynamic>>> newPages;
    if (currentPages.isNotEmpty) {
      newPages = [
        [message, ...currentPages.first],
        ...currentPages.skip(1),
      ];
    } else {
      newPages = [
        [message],
      ];
    }
    chatPaginationController.value = PagingState(
      pages: newPages,
      keys: currentKeys,
      error: null,
      hasNextPage: true,
      isLoading: false,
    );
  }

  void sendMessage() {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    addNewMessage({
      'role': 'user',
      'content': text,
      'timestamp': DateTime.now().toIso8601String(),
    });

    final completer = Completer<Map<String, dynamic>>();
    late void Function(dynamic) listener;
    listener = (data) {
      if (!completer.isCompleted) {
        completer.complete(Map<String, dynamic>.from(data));
      }
      addNewMessage(data);
      chatService.socketRepo.offEvent('new_message');
    };
    chatService.socketRepo.onEvent('new_message', listener);

    chatService.sendChatMessage(chatRoomID, text);
    messageController.clear();
  }
}
