import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class DocumentService {
  static String get baseUrl => '${ApiConfig.apiBaseUrl}/documents';

  Future<bool> uploadDocument(String animalId, String docType, List<int> fileBytes, String filename) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/upload'));
      request.fields['animalId'] = animalId;
      request.fields['docType'] = docType;
      
      var multipartFile = http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: filename,
      );
      request.files.add(multipartFile);

      var response = await request.send();
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}
