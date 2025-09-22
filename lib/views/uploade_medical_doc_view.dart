import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthapp/view_models/controller/uploade_medical_file_controller.dart';
import 'package:healthapp/views/home_page.dart';

class UploadeMedicalDocView extends StatelessWidget {
  final UploadeMedicalFileController controller = Get.put(
    UploadeMedicalFileController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Medical Document'),
        leading: IconButton(
          onPressed: () {
            Get.offAll(() => HomePage());
          },
          icon: Icon(Icons.arrow_back_ios_new_outlined),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: GetBuilder<UploadeMedicalFileController>(
              builder: (controller) => Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 32,
                    horizontal: 24,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.folder_shared,
                        size: 60,
                        color: Colors.blueAccent,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Upload your medical document',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 24),
                      ElevatedButton.icon(
                        icon: Icon(Icons.attach_file),
                        label: Text('Select Document'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: controller.pickFile,
                      ),
                      SizedBox(height: 16),
                      if (controller.selectedFile != null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.insert_drive_file, color: Colors.green),
                            SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                controller.selectedFile!.path.split('/').last,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      SizedBox(height: 24),
                      controller.isLoading
                          ? CircularProgressIndicator()
                          : ElevatedButton.icon(
                              icon: Icon(Icons.cloud_upload),
                              label: Text('Upload'),
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(double.infinity, 48),
                                backgroundColor: Colors.blueAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: controller.selectedFile != null
                                  ? controller.uploadFile
                                  : null,
                            ),
                      if (controller.uploadStatus != null) ...[
                        SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              controller.uploadStatus!.contains('success')
                                  ? Icons.check_circle
                                  : Icons.error,
                              color:
                                  controller.uploadStatus!.contains('success')
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                controller.uploadStatus!,
                                style: TextStyle(
                                  color:
                                      controller.uploadStatus!.contains(
                                        'success',
                                      )
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
