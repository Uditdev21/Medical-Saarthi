import 'package:get/get_connect/http/src/response/response.dart';
import 'package:healthapp/helpers/api_helper.dart';
import 'package:healthapp/models/health_doc_model.dart';

class HealthDocRepo {
  Future<List<healthDocModel>> getHealthDoc({int page = 0}) async {
    // Simulate a network call with a delay
    try {
      final response = await ApiHelper.getData(
        "/medical_document/list?keys=$page",
      );
      if (response.statusCode == 200) {
        // Parse the response data
        final Map<String, dynamic> data = response.data;
        final List<dynamic> docs = data['documents'] ?? [];
        return docs.map((item) => healthDocModel.fromJson(item)).toList();
      } else {
        throw Exception("Failed to load health documents");
      }
    } catch (e) {
      rethrow;
    }

    // Return a sample healthDocModel object
  }
}
