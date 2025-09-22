import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthapp/models/health_doc_model.dart';
import 'package:healthapp/view_models/controller/home_page_controller.dart';
import 'package:healthapp/view_models/services/auth_services.dart';
import 'package:healthapp/view_models/services/bottom_nav_services.dart';
import 'package:healthapp/view_models/services/chat_socket.dart';
import 'package:healthapp/views/chat_page.dart';
import 'package:healthapp/views/messages_page.dart';
import 'package:healthapp/views/uploade_medical_doc_view.dart';
import 'package:healthapp/views/widgets/bottomnavbar.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // final AuthServices services = Get.find<AuthServices>();
  final ChatService chatService = Get.find<ChatService>();
  final HomePageController controller = Get.put(HomePageController());

  @override
  void initState() {
    // TODO: implement initState
    // chatService.onInit();
    // chatService.fetchChats();
    // controller.fetchHealthDocs();
    chatService.onInit();
    print("");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Health App')),
      // body: Obx(() {
      //   if (controller.isLoading.value) {
      //     return const Center(child: CircularProgressIndicator());
      //   }
      //   return ListView.builder(
      //     itemCount: controller.healthDocs.length,
      //     itemBuilder: (context, index) {
      //       final doc = controller.healthDocs[index];
      //       return ListTile(
      //         title: Text(doc.sId ?? 'No ID'),
      //         subtitle: Text(doc.aiContext ?? 'No Context'),
      //         trailing: GestureDetector(
      //           onTap: () {
      //             chatService.createChat(doc.sId ?? "");
      //             print("Creating chat for document ID: ${doc.sId}");
      //             Get.to(() => MessagesPageScreen());
      //           },
      //           child: const Icon(Icons.chat, color: Colors.blue),
      //         ),
      //       );
      //     },
      //   );
      // }),
      body: PagingListener(
        controller: controller.healthDocPaginationController,
        builder: (context, state, fetchNextPage) {
          return PagedListView<int, healthDocModel>(
            state: state,
            fetchNextPage: fetchNextPage,
            builderDelegate: PagedChildBuilderDelegate(
              itemBuilder: (context, item, index) {
                final doc = item;
                return ListTile(
                  title: Text(doc.sId ?? 'No ID'),
                  subtitle: Text(doc.aiContext ?? 'No Context'),
                  trailing: GestureDetector(
                    onTap: () {
                      chatService.createChat(doc.sId ?? "");
                      print("Creating chat for document ID: ${doc.sId}");
                      Get.to(() => MessagesPageScreen());
                    },
                    child: const Icon(Icons.chat, color: Colors.blue),
                  ),
                );
              },
            ),
          );
        },
      ),
      bottomNavigationBar: Bottomnavbar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Get.to(() => const ChatPageScreen());
          Get.off(() => UploadeMedicalDocView());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
