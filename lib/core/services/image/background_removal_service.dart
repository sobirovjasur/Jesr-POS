import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../../constants/constants.dart';
import '../../utilities/console_logger.dart';

/// Removes the background from an image using the remove.bg API, producing a
/// transparent PNG. Best-effort: returns `null` when no API key is configured
/// or the request fails, so callers can fall back to the original image.
class BackgroundRemovalService {
  BackgroundRemovalService._();

  static const _endpoint = 'https://api.remove.bg/v1.0/removebg';

  /// Returns a new transparent-PNG [File] with the background removed, or
  /// `null` if removal was skipped or failed.
  static Future<File?> removeBackground(File source) async {
    if (Constants.removeBgApiKey.isEmpty) return null;

    try {
      final request = http.MultipartRequest('POST', Uri.parse(_endpoint))
        ..headers['X-Api-Key'] = Constants.removeBgApiKey
        ..fields['size'] = 'auto'
        ..files.add(await http.MultipartFile.fromPath('image_file', source.path));

      final streamed = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/nobg_${DateTime.now().millisecondsSinceEpoch}.png');
        await file.writeAsBytes(response.bodyBytes);

        return file;
      }

      cl('remove.bg failed (${response.statusCode}): ${response.body}');
      return null;
    } catch (e) {
      cl('remove.bg error: $e');
      return null;
    }
  }
}
