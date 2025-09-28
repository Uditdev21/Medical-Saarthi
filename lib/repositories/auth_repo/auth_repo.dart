import 'package:healthapp/helpers/api_helper.dart';
import 'package:healthapp/models/auth_models.dart';

class AuthRepo {
  /// 🔹 Login (returns AuthModels or throws)
  Future<AuthModels?> login(String email, String password) async {
    final response = await ApiHelper.postForm('/user/login', {
      'grant_type': 'password',
      'username': email,
      'password': password,
    });

    if (response.statusCode == 200) {
      try {
        ApiHelper.setToken(response.data['access_token']);
        return AuthModels.fromJson(response.data);
      } catch (e) {
        print("❌ Parsing error: $e");
        return null;
      }
    } else {
      print("❌ Login failed: ${response.statusCode} => ${response.data}");
      return null;
    }
  }

  /// 🔹 Register (returns AuthModels or null)
  Future<AuthModels?> register(
    String email,
    String password,
    String name,
  ) async {
    final response = await ApiHelper.postData('/user/register', {
      'email': email,
      'password': password,
      'name': name,
    });

    if (response.statusCode == 200) {
      try {
        return AuthModels.fromJson(response.data);
      } catch (e) {
        print("❌ Parsing error: $e");
        // return null;
        rethrow;
      }
    } else {
      print(
        "❌ Registration failed: ${response.statusCode} => ${response.data}",
      );
      return null;
    }
  }
}
