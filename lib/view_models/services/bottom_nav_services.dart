import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthapp/views/chat_page.dart';
import 'package:healthapp/views/home_page.dart';

class BottomNavServices extends GetxService {
  RxInt currentIndex = 0.obs;

  final List<Widget> pages = [HomePage(), ChatPageScreen()];

  void changeIndex(int index) {
    if (currentIndex.value != index) {
      print("Changing index from ${currentIndex.value} to $index");
      currentIndex.value = index;
      Get.offAll(
        () => pages[currentIndex.value],
        transition: Transition.noTransition,
      );
    }
  }
}
