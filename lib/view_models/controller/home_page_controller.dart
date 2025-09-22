import 'dart:developer';

import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:healthapp/models/health_doc_model.dart';
import 'package:healthapp/repositories/health_doc_repo.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class HomePageController extends GetxController {
  // Define your state variables and methods here
  final RxList<healthDocModel> healthDocs = <healthDocModel>[].obs;
  final HealthDocRepo healthDocRepo = Get.put(HealthDocRepo());
  final RxBool isLoading = false.obs;

  late final PagingController<int, healthDocModel>
  healthDocPaginationController;

  @override
  void onInit() {
    super.onInit();
    // fetchHealthDocs();

    healthDocPaginationController = PagingController(
      getNextPageKey: (PagingState<int, healthDocModel> state) {
        if (state.pages == null || state.pages!.isEmpty) return 0;

        final lastPage = state.pages!.last;
        if (lastPage.length < 10) return null;

        final currentPage = state.keys!.last;
        return currentPage + 1;
      },
      fetchPage: (int pageKey) async {
        log("Fetching health documents for page: $pageKey");
        final newItems = await healthDocRepo.getHealthDoc(page: pageKey);
        return newItems;
      },
    );
  }

  void fetchHealthDocs() async {
    try {
      isLoading.value = true;
      final docs = await healthDocRepo.getHealthDoc();
      healthDocs.assignAll(docs);
    } catch (e) {
      // Handle error
      print("Error fetching health documents: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void clearHealthDocs() {
    healthDocs.clear();
  }
}

  // void addHealthDoc(healthDocModel doc) {
  //   healthDocs.add(doc);
  // }
// }
