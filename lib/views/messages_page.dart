import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthapp/view_models/controller/message_page_controller.dart';
import 'package:healthapp/view_models/services/chat_socket.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class MessagesPageScreen extends StatefulWidget {
  const MessagesPageScreen({super.key});

  @override
  State<MessagesPageScreen> createState() => _MessagesPageScreenState();
}

class _MessagesPageScreenState extends State<MessagesPageScreen> {
  final ChatService chatService = Get.find<ChatService>();
  final MessagePageController messagingController = Get.put(
    MessagePageController(),
  );

  @override
  void initState() {
    // TODO: implement initState
    // chatService.onInit();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Text(
        //   'Messages Page =${chatService.selectedChatId.value}',
        //   style: const TextStyle(color: Colors.black, fontSize: 10),
        // ),
        title: const Text('Messages Page'),
        leading: IconButton(
          onPressed: () {
            chatService.leaveChat(chatService.selectedChatId.value);
            Get.back();
          },
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: PagingListener(
                controller: messagingController.chatPaginationController,
                builder: (context, state, fetchNextPage) {
                  return PagedListView<int, Map<String, dynamic>>(
                    reverse: true,
                    state: state,
                    fetchNextPage: fetchNextPage,
                    builderDelegate: PagedChildBuilderDelegate(
                      itemBuilder: (context, item, index) {
                        return Column(
                          children: [
                            Align(
                              alignment: item['role'] == 'user'
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.7,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: item['role'] == 'user'
                                      ? Colors.blueAccent
                                      : Colors.grey[300],
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                                child: Text(
                                  item['content'] ?? 'No Message',
                                  softWrap: true,
                                  overflow: TextOverflow.visible,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: TextField(
                controller: messagingController.messageController,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () {
                      messagingController.sendMessage();
                      messagingController.messageController.clear();
                      // Implement send message functionality
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
