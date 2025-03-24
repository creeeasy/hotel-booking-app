import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CloudinaryService {
  CloudinaryService._();

  static final Dio _dio = Dio();

  static Future<String?> uploadImageWeb(
      Uint8List fileBytes, String fileName) async {
    final cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'];
    final uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'];

    if (cloudName?.isEmpty ?? true) return null;

    try {
      final response = await _dio.post(
        "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
        data: FormData.fromMap({
          "file": MultipartFile.fromBytes(fileBytes, filename: fileName),
          "upload_preset": uploadPreset,
        }),
      );
      return response.data["secure_url"];
    } catch (_) {
      return null;
    }
  }
}
