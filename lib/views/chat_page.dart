import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthapp/view_models/controller/chat_page_controller.dart';
import 'package:healthapp/view_models/services/bottom_nav_services.dart';
import 'package:healthapp/view_models/services/chat_socket.dart';
import 'package:healthapp/views/messages_page.dart';
import 'package:healthapp/views/widgets/bottomnavbar.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class ChatPageScreen extends StatefulWidget {
  const ChatPageScreen({super.key});

  @override
  State<ChatPageScreen> createState() => _ChatPageScreenState();
}

class _ChatPageScreenState extends State<ChatPageScreen> {
  final ChatService chatService = Get.find<ChatService>();
  final ChatPageController chatPageController = Get.put(ChatPageController());

  @override
  void initState() {
    // TODO: implement initState
    chatService.onInit();
    // chatService.fetchChats(0);
    chatPageController.onInit();
    super.initState();
  }

  @override
  void dispose() {
    // chatService.disposeSocket(); // remove listeners
    // chatService.disposeSocket();
    super.dispose();
    // test();
  }

  void test() {
    // chatPageController.chatPaginationController.value=PagingState(
    //   itemList: [],
    //   nextPageKey: null,
    //   error: null,
    //   status: PagingStatus.idle,
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat Page')),
      body: PagingListener(
        controller: chatPageController.chatPaginationController,
        builder: (context, state, fetchNextPage) {
          return PagedListView<int, Map<String, dynamic>>(
            state: state,
            fetchNextPage: fetchNextPage,
            builderDelegate: PagedChildBuilderDelegate(
              itemBuilder: (context, item, index) {
                return ListTile(
                  title: Text(
                    item['medical_document_ai_context'] ?? 'No Message',
                  ),
                  subtitle: Text('Chat ID: ${item['_id'] ?? 'N/A'}'),
                  onTap: () {
                    // chatService.setCurrentChatId(item['chatId'] ?? '');
                    // chatService.joinChat(item['_id'] ?? '',);
                    Get.to(
                      () => MessagesPageScreen(),
                      arguments: {"room_id": item['_id'] ?? ""},
                    );
                  },
                );
              },
            ),
          );
        },
      ),
      bottomNavigationBar: Bottomnavbar(),
    );
  }
}
