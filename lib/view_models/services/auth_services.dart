import 'package:get/get.dart';
import 'package:healthapp/helpers/api_helper.dart';
import 'package:healthapp/models/auth_models.dart';
import 'package:healthapp/repositories/auth_repo/auth_repo.dart';
import 'package:healthapp/views/auth_screens/login_screen.dart';
import 'package:healthapp/views/home_page.dart';

class AuthServices extends GetxService {
  final AuthRepo authRepo = Get.put(AuthRepo());
  final RxBool isloading = false.obs;
  final RxString _token = ''.obs;
  String get token => _token.value;

  void login(String email, String password) async {
    isloading.value = true;
    try {
      final AuthModels? response = await authRepo.login(email, password);
      if (response != null) {
        print("✅ Login successful: ${response.accessToken}");
        _token.value = response.accessToken ?? "";
        Get.off(() => const HomePage());
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
    _token.value = "";
    ApiHelper.setToken("");
    print("🔒 Logged out");
    Get.offAll(() => LoginScreen());
  }
}
