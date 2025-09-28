import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthapp/helpers/api_helper.dart';
import 'package:healthapp/helpers/storage_helper.dart';
import 'package:healthapp/models/auth_models.dart';
import 'package:healthapp/repositories/auth_repo/auth_repo.dart';
import 'package:healthapp/repositories/socket_repo.dart';
import 'package:healthapp/view_models/services/chat_socket.dart';
import 'package:healthapp/views/auth_screens/login_screen.dart';
import 'package:healthapp/views/home_page.dart';

class AuthServices extends GetxService {
  final AuthRepo authRepo = Get.put(AuthRepo());
  // final ChatService chatService = Get.put(ChatService());
  final RxBool isloading = false.obs;
  final RxString token = ''.obs;
  //  token.value;

  void register(String email, String password, String name) async {
    isloading.value = true;
    try {
      final AuthModels? response = await authRepo.register(
        email,
        password,
        name,
      );
      if (response != null) {
        print("✅ Registration successful: ${response.accessToken}");
        token.value = response.accessToken ?? "";
        print("Token: ${token.value}");
        ApiHelper.setToken(token.value);

        // Reinitialize ChatService with new token
        if (Get.isRegistered<ChatService>()) {
          final chatService = Get.find<ChatService>();
          chatService.reinitializeWithToken(token.value);
        }

        StorageHelper.saveData(StorageKeys.gmail, email);
        StorageHelper.saveData(StorageKeys.password, password);
        Get.offAll(() => const HomePage());
      } else {
        print("❌ Registration failed");
      }
    } catch (e) {
      print("❌ Registration error: $e");
      Get.bottomSheet(
        Container(
          color: Colors.red,
          padding: EdgeInsets.all(16),
          child: Text(
            'Registration failed: $e',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    } finally {
      isloading.value = false;
    }
  }

  void login(String email, String password) async {
    isloading.value = true;
    try {
      final AuthModels? response = await authRepo.login(email, password);
      if (response != null) {
        print("✅ Login successful: ${response.accessToken}");
        token.value = response.accessToken ?? "";

        // Reinitialize ChatService with new token
        if (Get.isRegistered<ChatService>()) {
          final chatService = Get.find<ChatService>();
          chatService.reinitializeWithToken(token.value);
        }

        StorageHelper.saveData(StorageKeys.gmail, email);
        StorageHelper.saveData(StorageKeys.password, password);
        Get.offAll(() => const HomePage());
      } else {
        print("❌ Login failed");
      }
    } catch (e) {
      print("❌ Login error: $e");
    } finally {
      isloading.value = false;
    }
  }

  void logout() {
    token.value = "";
    ApiHelper.setToken("");
    StorageHelper.removeData(StorageKeys.gmail);
    StorageHelper.removeData(StorageKeys.password);

    // Dispose old ChatService and SocketRepo
    if (Get.isRegistered<ChatService>()) {
      final chatService = Get.find<ChatService>();
      chatService.socketRepo.disconnect(); // <-- disconnect socket first
      Get.delete<ChatService>(force: true);
    }

    if (Get.isRegistered<SocketRepo>()) {
      final socketRepo = Get.find<SocketRepo>();
      socketRepo.disconnect(); // <-- disconnect again if standalone
      Get.delete<SocketRepo>(force: true);
    }

    print("✅ Logged out successfully");
    Get.offAll(() => LoginScreen());
  }

  /// Ensure ChatService is initialized with current token
  void ensureChatServiceWithToken() {
    if (!Get.isRegistered<ChatService>()) {
      // Create new ChatService instance
      Get.put<ChatService>(ChatService());
    }

    if (token.value.isNotEmpty) {
      final chatService = Get.find<ChatService>();
      log("Ensuring ChatService with token: ${token.value}");
      chatService.reinitializeWithToken(token.value);
    }
  }
}
