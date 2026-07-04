import 'dart:async';
import 'dart:html' as html;
import 'dart:math';

class UploadProgressInfo {
  final double progress; // 0.0 to 1.0
  final double speedMBs; // MB/s
  final int uploadedBytes;
  final int totalBytes;

  UploadProgressInfo({
    required this.progress,
    required this.speedMBs,
    required this.uploadedBytes,
    required this.totalBytes,
  });
}

class ChunkedUploadService {
  final int chunkSize; // default 2MB
  final int maxRetries;

  ChunkedUploadService({
    this.chunkSize = 2 * 1024 * 1024,
    this.maxRetries = 5,
  });

  // Active sessions cache
  final Map<String, _UploadSession> _activeSessions = {};

  Future<String?> upload({
    required String fileId,
    required html.File file,
    required String uploadUrl,
    required bool isMock,
    required Function(UploadProgressInfo progressInfo) onProgress,
    required Function(String status, String? error) onStatusChanged,
  }) async {
    // If there is an existing session, we resume it. Otherwise create a new one.
    _UploadSession session = _activeSessions.putIfAbsent(fileId, () {
      return _UploadSession(
        fileId: fileId,
        file: file,
        uploadUrl: uploadUrl,
        isMock: isMock,
        chunkSize: chunkSize,
        maxRetries: maxRetries,
        onProgress: onProgress,
        onStatusChanged: onStatusChanged,
      );
    });

    return session.start();
  }

  void pause(String fileId) {
    _activeSessions[fileId]?.pause();
  }

  void resume(String fileId) {
    _activeSessions[fileId]?.resume();
  }

  void cancel(String fileId) {
    _activeSessions[fileId]?.cancel();
    _activeSessions.remove(fileId);
  }

  bool isUploading(String fileId) {
    final session = _activeSessions[fileId];
    return session != null && session.isUploading;
  }

  bool isPaused(String fileId) {
    final session = _activeSessions[fileId];
    return session != null && session.isPaused;
  }
}

class _UploadSession {
  final String fileId;
  final html.File file;
  final String uploadUrl;
  final bool isMock;
  final int chunkSize;
  final int maxRetries;
  final Function(UploadProgressInfo) onProgress;
  final Function(String status, String? error) onStatusChanged;

  int _currentChunkIndex = 0;
  bool _isPaused = false;
  bool _isCancelled = false;
  bool _isUploading = false;
  Completer<String?>? _completer;

  bool get isUploading => _isUploading;
  bool get isPaused => _isPaused;

  _UploadSession({
    required this.fileId,
    required this.file,
    required this.uploadUrl,
    required this.isMock,
    required this.chunkSize,
    required this.onProgress,
    required this.onStatusChanged,
    required this.maxRetries,
  });

  Future<String?> start() {
    if (_isUploading) return _completer!.future;
    
    _isPaused = false;
    _isCancelled = false;
    _isUploading = true;
    _completer = Completer<String?>();

    onStatusChanged('uploading', null);
    _uploadLoop();

    return _completer!.future;
  }

  void pause() {
    if (!_isUploading || _isPaused) return;
    _isPaused = true;
    _isUploading = false;
    onStatusChanged('paused', null);
  }

  void resume() {
    if (_isUploading || !_isPaused) return;
    _isPaused = false;
    _isUploading = true;
    onStatusChanged('uploading', null);
    _uploadLoop();
  }

  void cancel() {
    _isCancelled = true;
    _isUploading = false;
    _isPaused = false;
    onStatusChanged('idle', null);
    if (_completer != null && !_completer!.isCompleted) {
      _completer!.complete(null);
    }
  }

  Future<void> _uploadLoop() async {
    final int totalSize = file.size;
    final int totalChunks = (totalSize / chunkSize).ceil();
    final String sessionId = 'session_$fileId';

    DateTime lastTime = DateTime.now();

    while (_currentChunkIndex < totalChunks && _isUploading && !_isPaused && !_isCancelled) {
      final int start = _currentChunkIndex * chunkSize;
      final int end = min(start + chunkSize, totalSize);
      final int currentChunkSize = end - start;

      bool chunkSuccess = false;
      int retryCount = 0;

      while (!chunkSuccess && retryCount <= maxRetries && _isUploading && !_isPaused && !_isCancelled) {
        try {
          if (isMock) {
            // Simulated upload delay
            await Future.delayed(const Duration(milliseconds: 600));

            // Introduce 10% chance of transient network error to showcase retry mechanism
            if (Random().nextDouble() < 0.10 && retryCount < maxRetries) {
              throw Exception('Simulated Network Connectivity Loss');
            }

            chunkSuccess = true;
          } else {
            // Live Firebase / Private Cloud HTTP request
            chunkSuccess = await _uploadChunkLive(start, end, sessionId, _currentChunkIndex, totalChunks);
          }
        } catch (e) {
          retryCount++;
          if (retryCount > maxRetries) {
            _isUploading = false;
            onStatusChanged('error', 'Upload failed after $maxRetries retries. Error: ${e.toString()}');
            _completer!.completeError(e);
            return;
          }

          // Exponential backoff: 1s, 2s, 4s, 8s...
          final delaySeconds = pow(2, retryCount - 1).toInt();
          onStatusChanged('retrying', 'Connection lost. Retrying ($retryCount/$maxRetries) in ${delaySeconds}s...');
          await Future.delayed(Duration(seconds: delaySeconds));
          
          if (!_isUploading || _isPaused || _isCancelled) return; // check if state changed during sleep
          onStatusChanged('uploading', null);
        }
      }

      if (chunkSuccess) {
        _currentChunkIndex++;
        final double progress = min(end / totalSize, 1.0);

        // Speed calculations
        final DateTime now = DateTime.now();
        final double timeDiffSeconds = now.difference(lastTime).inMilliseconds / 1000.0;
        double speedMBs = 0.0;
        if (timeDiffSeconds > 0) {
          speedMBs = (currentChunkSize / (1024 * 1024)) / timeDiffSeconds;
        }
        lastTime = now;

        onProgress(UploadProgressInfo(
          progress: progress,
          speedMBs: speedMBs,
          uploadedBytes: end,
          totalBytes: totalSize,
        ));
      }
    }

    if (_currentChunkIndex >= totalChunks && _isUploading && !_isCancelled) {
      _isUploading = false;
      onStatusChanged('completed', null);
      
      // Final returned URL
      String finalUrl = '';
      if (isMock) {
        if (file.name.toLowerCase().endsWith('.pdf')) {
          finalUrl = 'https://private-cloud.stustep.edu/files/mock_${file.name}';
        } else {
          finalUrl = 'https://private-cloud.stustep.edu/videos/mock_${file.name}';
        }
      } else {
        // In real backend integration, the server response of the last chunk would return the file url
        finalUrl = '${uploadUrl.replaceAll('/upload', '/files')}/${file.name}';
      }

      _completer!.complete(finalUrl);
    }
  }

  Future<bool> _uploadChunkLive(int start, int end, String sessionId, int chunkIndex, int totalChunks) async {
    final completer = Completer<bool>();

    final html.Blob chunkBlob = file.slice(start, end);
    final html.HttpRequest request = html.HttpRequest();

    request.open('POST', uploadUrl);
    request.setRequestHeader('X-Session-ID', sessionId);
    request.setRequestHeader('X-Chunk-Index', chunkIndex.toString());
    request.setRequestHeader('X-Total-Chunks', totalChunks.toString());
    request.setRequestHeader('X-File-Name', Uri.encodeComponent(file.name));
    request.setRequestHeader('Content-Type', 'application/octet-stream');

    request.onLoad.listen((event) {
      if (request.status == 200 || request.status == 201) {
        completer.complete(true);
      } else {
        completer.completeError(Exception('Server responded with status code: ${request.status}'));
      }
    });

    request.onError.listen((event) {
      completer.completeError(Exception('Network error in XMLHttpRequest'));
    });

    // Native reader to read chunk without consuming full file memory
    final reader = html.FileReader();
    reader.onLoadEnd.listen((event) {
      if (reader.result != null) {
        request.send(reader.result);
      } else {
        completer.completeError(Exception('Failed to read slice buffer'));
      }
    });

    reader.readAsArrayBuffer(chunkBlob);
    return completer.future;
  }
}
