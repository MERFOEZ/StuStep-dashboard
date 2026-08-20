import 'dart:async';
import 'dart:typed_data';
import 'dart:js_interop';
import 'package:web/web.dart' as web;

/// Service for uploading videos to Archive.org using their S3-like API.
/// Uses XMLHttpRequest for browser-based upload with progress tracking.
class ArchiveUploadService {
  static const String _s3Endpoint = 'https://s3.us.archive.org';

  /// Upload a video file to Archive.org.
  ///
  /// Returns the direct download URL on success.
  Future<String> uploadVideo({
    required String identifier,
    required String fileName,
    required Uint8List fileBytes,
    required String accessKey,
    required String secretKey,
    Function(double)? onProgress,
  }) async {
    final safeIdentifier = _sanitize(identifier);
    final safeFileName = _sanitize(fileName);
    final url = '$_s3Endpoint/$safeIdentifier/$safeFileName';

    final completer = Completer<String>();

    final xhr = web.XMLHttpRequest();
    xhr.open('PUT', url);

    // Archive.org S3 authentication
    xhr.setRequestHeader('Authorization', 'LOW $accessKey:$secretKey');

    // Archive.org metadata
    xhr.setRequestHeader('x-amz-auto-make-bucket', '1');
    xhr.setRequestHeader('x-archive-meta-collection', 'opensource_media');
    xhr.setRequestHeader('x-archive-meta-mediatype', 'movies');
    xhr.setRequestHeader('x-archive-meta-title', safeIdentifier);
    xhr.setRequestHeader('Content-Type', 'video/mp4');

    // Track upload progress
    xhr.upload.onprogress = ((web.ProgressEvent event) {
      if (event.lengthComputable) {
        final progress = event.loaded / event.total;
        onProgress?.call(progress);
      }
    }).toJS;

    // Handle completion
    xhr.onload = ((web.Event event) {
      final status = xhr.status;
      if (status == 200 || status == 201) {
        final directUrl = buildDirectUrl(safeIdentifier, safeFileName);
        completer.complete(directUrl);
      } else {
        completer.completeError(
          'Upload failed with status $status: ${xhr.responseText}',
        );
      }
    }).toJS;

    // Handle errors
    xhr.onerror = ((web.Event event) {
      completer.completeError('Network error during upload');
    }).toJS;

    // Send the data
    final blob = web.Blob(
      [fileBytes.toJS].toJS,
      web.BlobPropertyBag(type: 'video/mp4'),
    );
    xhr.send(blob);

    return completer.future;
  }

  /// Build the direct playback URL for an Archive.org item.
  String buildDirectUrl(String identifier, String fileName) {
    return 'https://archive.org/download/$identifier/$fileName';
  }

  /// Sanitize strings for use in URLs.
  String _sanitize(String input) {
    return input
        .replaceAll(RegExp(r'[^\w\-.]'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .toLowerCase();
  }
}
