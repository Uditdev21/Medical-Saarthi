import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthapp/helpers/api_helper.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:healthapp/views/home_page.dart';

class UploadeMedicalFileController extends GetxController {
  File? selectedFile;
  bool isLoading = false;
  String? uploadStatus;
  final RxInt progress = 0.obs;

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );
    if (result != null && result.files.single.path != null) {
      selectedFile = File(result.files.single.path!);
      update();
    }
  }

  void uploadeProgress(int sent, int total) {
    progress.value = ((sent / total) * 100).toInt();
    print("Upload progress: ${progress.value}%");
    update();
  }

  Future<void> uploadFile() async {
    if (selectedFile == null) return;
    isLoading = true;
    uploadStatus = null;
    update();
    try {
      Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Obx(
              () => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(value: progress.value / 100),
                  const SizedBox(height: 16),
                  Text('Upload Progress: ${progress.value}%'),
                  const SizedBox(height: 16),

                  // Status text
                  if (progress.value == 100 || uploadStatus != null)
                    Text(
                      uploadStatus ?? '',
                      style: TextStyle(
                        color: uploadStatus == 'Upload successful!'
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Show OK button only when upload completes (success/failure)
                  if (progress.value == 100 || uploadStatus != null)
                    ElevatedButton(
                      onPressed: () {
                        Get.offAll(() => HomePage());
                        progress.value = 0;
                      }, // closes dialog
                      child: const Text("OK"),
                    ),
                ],
              ),
            ),
          ),
        ),
        barrierDismissible: false,
        // prevent closing by tapping outside
      );

      final response = await ApiHelper.uploadFile(
        '/medical_document/upload',
        file: selectedFile!,
        onSendProgress: uploadeProgress,
      );
      uploadStatus = response.statusCode == 200
          ? 'Upload successful!'
          : 'Upload failed!';
    } catch (e) {
      uploadStatus = 'Error: $e';
    } finally {
      isLoading = false;
      // progress.value = 0;
      update();
    }
  }
}
