import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CloudinaryService {
  CloudinaryService._();

  static final Dio _dio = Dio();
  static final String _cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
  static final String _uploadPreset =
      dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '';
  static final String _apiKey = dotenv.env['CLOUDINARY_API_KEY'] ?? '';
  static final String _apiSecret = dotenv.env['CLOUDINARY_API_SECRET'] ?? '';

  static Future<String?> uploadImageWeb(
      Uint8List fileBytes, String fileName) async {
    if (_cloudName.isEmpty) return null;

    try {
      final response = await _dio.post(
        "https://api.cloudinary.com/v1_1/$_cloudName/image/upload",
        data: FormData.fromMap({
          "file": MultipartFile.fromBytes(fileBytes, filename: fileName),
          "upload_preset": _uploadPreset,
        }),
      );
      return response.data["secure_url"];
    } catch (e) {
      print('Cloudinary upload error: $e');
      return null;
    }
  }

  static Future<bool> deleteImage(String publicId) async {
    if (_cloudName.isEmpty || _apiKey.isEmpty || _apiSecret.isEmpty) {
      return false;
    }

    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final signature = _generateSignature(publicId, timestamp);

      await _dio.post(
        "https://api.cloudinary.com/v1_1/$_cloudName/image/destroy",
        data: {
          "public_id": publicId,
          "api_key": _apiKey,
          "timestamp": timestamp,
          "signature": signature,
        },
      );
      return true;
    } catch (e) {
      print('Cloudinary delete error: $e');
      return false;
    }
  }

  static String? extractPublicIdFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;

      // The public ID is typically after the version segment (v1234567)
      final versionIndex =
          pathSegments.indexWhere((seg) => seg.startsWith('v'));
      if (versionIndex != -1 && pathSegments.length > versionIndex + 1) {
        return pathSegments.sublist(versionIndex + 1).join('/').split('.')[0];
      }

      // Fallback for URLs without version
      final uploadIndex = pathSegments.indexWhere((seg) => seg == 'upload');
      if (uploadIndex != -1 && pathSegments.length > uploadIndex + 1) {
        return pathSegments.sublist(uploadIndex + 1).join('/').split('.')[0];
      }

      return null;
    } catch (e) {
      print('Error extracting public ID: $e');
      return null;
    }
  }

  static String _generateSignature(String publicId, int timestamp) {
    final params = 'public_id=$publicId&timestamp=$timestamp$_apiSecret';
    return _sha1(params); // You'll need to implement SHA1 hashing
  }

  static String _sha1(String input) {
    // Implement SHA1 hashing using package:crypto or similar
    // This is a placeholder - you should use a proper hashing library
    return input; // Replace with actual SHA1 implementation
  }
}
