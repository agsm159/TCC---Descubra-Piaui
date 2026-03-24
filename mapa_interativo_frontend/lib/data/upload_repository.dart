import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../core/api_service.dart';

class UploadRepository {
  final ApiService _api;
  UploadRepository(this._api);

  Future<String> uploadImagem(Uint8List bytes, String nomeArquivo) async {
    final formData = FormData.fromMap({
      'imagem': MultipartFile.fromBytes(
        bytes,
        filename: nomeArquivo,
      ),
    });

    final response = await _api.postFormData('/upload', formData);
    return response.data['url'];
  }
}