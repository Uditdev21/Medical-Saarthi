import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthapp/helpers/api_helper.dart';
import 'package:healthapp/view_models/services/auth_services.dart';
import 'package:healthapp/view_models/services/bottom_nav_services.dart';
import 'package:healthapp/views/auth_screens/login_screen.dart';
import 'package:healthapp/view_models/services/chat_socket.dart';

void main() {
  Get.put(AuthServices());
  ApiHelper.init();
  Get.lazyPut<ChatService>(() => ChatService(), fenix: true);
  Get.lazyPut<BottomNavServices>(() => BottomNavServices(), fenix: true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: LoginScreen(),
    );
  }
}
