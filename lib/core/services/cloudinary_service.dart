import 'dart:convert';
import 'dart:io' show File;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class CloudinaryService {
  // Free-tier cloud settings (User can edit these in settings/profile)
  static String cloudName = "dtywpkwy0";
  static String uploadPreset = "anhire_unsigned";

  static bool get isConfigured =>
      cloudName.isNotEmpty &&
      cloudName != "demo-cloud-anhire" &&
      uploadPreset.isNotEmpty;

  /// Uploads a file (PDF/Image) directly to Cloudinary.
  /// If credentials are the default demo values, it simulates the upload
  /// and returns a mock successful URL so the app runs without setup.
  Future<String> uploadFile({
    File? file,
    Uint8List? bytes,
    required String fileName,
    required String folder,
    bool isImage = false,
  }) async {
    if (!isConfigured) {
      // Simulation mode for student demo/viva
      await Future.delayed(const Duration(seconds: 2)); // Simulate network latency
      if (isImage) {
        return "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=200&q=80";
      } else {
        return "https://res.cloudinary.com/demo/image/upload/sample_resume_pdf.pdf";
      }
    }

    try {
      final resourceType = isImage ? "image" : "raw";
      final uri = Uri.parse(
        "https://api.cloudinary.com/v1_1/$cloudName/$resourceType/upload",
      );

      final request = http.MultipartRequest("POST", uri)
        ..fields['upload_preset'] = uploadPreset
        ..fields['folder'] = folder;

      if (kIsWeb) {
        if (bytes == null) {
          throw Exception("File bytes must be provided on Web");
        }
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            bytes,
            filename: fileName,
          ),
        );
      } else {
        if (file == null) {
          throw Exception("File object must be provided on Mobile/Desktop");
        }
        request.files.add(
          await http.MultipartFile.fromPath('file', file.path),
        );
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        return data['secure_url'] as String;
      } else {
        final error = jsonDecode(responseBody);
        throw Exception(
          "Cloudinary upload failed: ${error['error']['message'] ?? 'Unknown error'}",
        );
      }
    } catch (e) {
      throw Exception("Error uploading file: $e");
    }
  }

  /// Deletes a file (Simulated for client-side security since deletion
  /// typically requires a signed signature, not allowed in unsigned setups).
  Future<bool> deleteFile(String url) async {
    // Unsigned presets do not allow deletion via REST API for security.
    // We simulate deletion success for the demo.
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }
}
