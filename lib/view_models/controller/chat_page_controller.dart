import 'dart:async';
import 'package:get/get.dart';
import 'package:healthapp/view_models/services/chat_socket.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class ChatPageController extends GetxController {
  final ChatService service = Get.find<ChatService>();

  final PagingController<int, Map<String, dynamic>> chatPaginationController =
      PagingController(
        getNextPageKey: (state) {
          if (state.pages == null || state.pages!.isEmpty) return 0;

          final lastPage = state.pages!.last;
          if (lastPage.length < 10) return null;

          final currentPage = state.keys!.last;
          return currentPage + 1;
        },
        fetchPage: (int pageKey) async {
          final service = Get.find<ChatService>();
          service.socketRepo.emitEvent('get_recent_chats', {"key": pageKey});
          print("Emitting event for page key: $pageKey");

          final completer = Completer<List<Map<String, dynamic>>>();

          late void Function(dynamic) listener;
          listener = (data) {
            if (!completer.isCompleted) {
              completer.complete(List<Map<String, dynamic>>.from(data));
            }
            service.socketRepo.offEvent('recent_chats');
          };

          service.socketRepo.onEvent('recent_chats', listener);

          return await completer.future;
        },
      );

  @override
  void onClose() {
    chatPaginationController.dispose();
    super.onClose();
  }
}
