// File: lib/pages/api_service.dart
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ApiService {
  static Future<Uint8List?> sendFrame(Uint8List frameBytes, {required String feedType}) async {
    final url = Uri.parse('http://20.24.49.239:8000/stream?feed_type=$feedType');

    try {
      final request = http.MultipartRequest('POST', url)
        ..files.add(http.MultipartFile.fromBytes(
          'file',
          frameBytes,
          filename: '$feedType.jpg',
          contentType: MediaType('image', 'jpeg'),
        ));

      final response = await request.send();

      if (response.statusCode == 200) {
        print('✅ Frame acknowledged by server');
        return await response.stream.toBytes();
      } else {
        print('❌ Server responded with status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Error sending frame: $e');
      return null;
    }
  }
}
