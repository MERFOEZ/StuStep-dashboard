import 'dart:typed_data';
import 'package:dio/dio.dart';

class StorageService {
  final Dio _dio = Dio();

  // Dummy keys as requested
  static const String accessKey = "NN2PdXgh2i4YPVaT";
  static const String secretKey = "Wf9fn83j7lwaQUsG";
  static const String bucketName = "mhm-academy-videos-2026";

  /// Uploads a video file bytes to Archive.org and returns the direct download URL.
  Future<String> uploadVideo(
    String collegeId,
    String majorId,
    String levelId,
    String fileName,
    Uint8List fileBytes,
    void Function(int count, int total) onProgress,
  ) async {
    // Sanitize filename to prevent issues
    final sanitizedName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9.\-_]'), '_');
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final finalFileName = '${timestamp}_$sanitizedName';

    final String uploadUrl =
        'https://s3.us.archive.org/$bucketName/$collegeId/$majorId/$levelId/$finalFileName';

    try {
      await _dio.put(
        uploadUrl,
        data: fileBytes,
        options: Options(
          headers: {
            'Authorization': 'LOW $accessKey:$secretKey',
            'x-amz-auto-make-bucket': '1',
            'Content-Type': 'video/mp4',
          },
        ),
        onSendProgress: onProgress,
      );

      return 'https://archive.org/download/$bucketName/$collegeId/$majorId/$levelId/$finalFileName';
    } catch (e) {
      throw Exception('Failed to upload video: $e');
    }
  }
}
