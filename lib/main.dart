import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthapp/helpers/api_helper.dart';
import 'package:healthapp/helpers/storage_helper.dart';
import 'package:healthapp/view_models/services/auth_services.dart';
import 'package:healthapp/view_models/services/bottom_nav_services.dart';
import 'package:healthapp/view_models/services/chat_socket.dart';
import 'package:healthapp/views/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize storage first
    await StorageHelper.init();

    // Initialize API helper
    ApiHelper.init();

    // Initialize services
    Get.put(AuthServices());

    // Initialize ChatService with lazy loading
    Get.lazyPut<ChatService>(() => ChatService(), fenix: true);
    Get.lazyPut<BottomNavServices>(() => BottomNavServices(), fenix: true);

    runApp(const MyApp());
  } catch (e) {
    print('❌ Initialization error: $e');
    // You can show an error screen or fallback here
    runApp(ErrorApp(error: e.toString()));
  }
}

class ErrorApp extends StatelessWidget {
  final String error;

  const ErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 64, color: Colors.red),
                SizedBox(height: 16),
                Text(
                  'Initialization Error',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Text(
                  error,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
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
      home: SplashScreen(),
    );
  }
}
