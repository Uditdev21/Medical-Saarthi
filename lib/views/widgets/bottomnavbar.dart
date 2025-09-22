import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthapp/view_models/services/bottom_nav_services.dart';

class Bottomnavbar extends StatefulWidget {
  const Bottomnavbar({super.key});

  @override
  State<Bottomnavbar> createState() => _BottomnavbarState();
}

class _BottomnavbarState extends State<Bottomnavbar> {
  final BottomNavServices bottomNavServices = Get.find<BottomNavServices>();
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return BottomNavigationBar(
        currentIndex: bottomNavServices.currentIndex.value,
        onTap: (index) {
          bottomNavServices.changeIndex(index);
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
        ],
      );
    });
  }
}
