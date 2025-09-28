import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:healthapp/helpers/storage_helper.dart';
import 'package:healthapp/view_models/services/auth_services.dart';
import 'package:healthapp/views/auth_screens/login_screen.dart';
import 'package:healthapp/views/home_page.dart';

class SplashPageController extends GetxController {
  // final RxBool isLoading = true.obs;
  final AuthServices _authServices = Get.find<AuthServices>();

  @override
  void onInit() {
    super.onInit();
    Future.delayed(const Duration(seconds: 2), () {
      if (StorageHelper.getData(StorageKeys.gmail) == null ||
          StorageHelper.getData(StorageKeys.password) == null) {
        Get.offAll(() => LoginScreen());
        return;
      }
      _authServices.login(
        StorageHelper.getData(StorageKeys.gmail)!,
        StorageHelper.getData(StorageKeys.password)!,
      );
      // _checkAuthentication();
    });
  }

  void _checkAuthentication() async {
    // Simulate a network call
    // await Future.delayed(const Duration(seconds: 2));
  }
}
