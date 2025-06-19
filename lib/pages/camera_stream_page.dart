// File: lib/pages/camera_stream_page.dart
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'api_service.dart';

class CameraStreamPage extends StatefulWidget {
  final String feedType;

  const CameraStreamPage({super.key, required this.feedType});

  @override
  State<CameraStreamPage> createState() => _CameraStreamPageState();
}

class _CameraStreamPageState extends State<CameraStreamPage> {
  CameraController? _controller;
  String _status = "Connecting...";
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      print("🔧 Initializing camera...");
      final cameras = await availableCameras();
      final camera = cameras.first;

      _controller = CameraController(
        camera,
        ResolutionPreset.medium,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      await _controller!.initialize();

      if (mounted) {
        setState(() {});
        print("✅ Camera initialized, starting stream...");
        _startStreaming();
      }
    } catch (e) {
      print("❌ Camera init failed: $e");
      setState(() => _status = "❌ Camera error");
    }
  }

  void _startStreaming() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    print("📷 Starting image stream...");
    _controller!.startImageStream((CameraImage image) async {
      if (_isProcessing) return;
      _isProcessing = true;

      try {
        print("📸 Captured frame...");
        setState(() => _status = "Sending frame...");

        final bytes = await _convertCameraImageToJpeg(image);
        if (bytes != null) {
          print("⬆️ Sending frame to server...");
          final response = await ApiService.sendFrame(bytes, feedType: widget.feedType);

          setState(() {
            _status = response != null ? "✅ Server Connected" : "❌ Server Not Responding";
          });

          print("✅ Frame sent: ${response != null}");
        } else {
          print("❌ Image conversion returned null");
          setState(() => _status = "❌ Image Conversion Failed");
        }
      } catch (e) {
        print("❌ Error during frame send: $e");
        setState(() => _status = "❌ Error: $e");
      } finally {
        _isProcessing = false;
      }
    });
  }

  Future<Uint8List?> _convertCameraImageToJpeg(CameraImage image) async {
    try {
      final int width = image.width;
      final int height = image.height;

      if (image.format.group != ImageFormatGroup.yuv420) {
        print("❌ Unsupported image format: ${image.format.group}");
        return null;
      }

      final img.Image grayscale = img.Image(width: width, height: height);

      final bytes = image.planes[0].bytes;
      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
          final pixel = bytes[y * width + x];
          grayscale.setPixelRgba(x, y, pixel, pixel, pixel, 255);
        }
      }

      return Uint8List.fromList(img.encodeJpg(grayscale));
    } catch (e) {
      print("❌ JPEG conversion error: $e");
      return null;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _controller == null || !_controller!.value.isInitialized
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                CameraPreview(_controller!),
                Positioned(
                  top: 40,
                  left: 0,
                  right: 0,
                  child: Container(
                    color: Colors.black.withOpacity(0.6),
                    padding: const EdgeInsets.all(10),
                    child: Center(
                      child: Text(
                        "${widget.feedType.toUpperCase()} Feed - $_status",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
