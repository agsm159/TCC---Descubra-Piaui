import '../core/api_service.dart';
import '../models/ponto_interesse.dart';

class FavoritosRepository {
  final ApiService _api;
  FavoritosRepository(this._api);

  Future<List<PontoInteresse>> getFavoritos() async {
    final response = await _api.get('/favoritos');
    final List data = response.data;
    return data
        .map((json) => PontoInteresse.fromJson(json['ponto']))
        .toList();
  }

  Future<void> adicionarFavorito(String pontoId) async {
    await _api.post('/favoritos/$pontoId', {});
  }

  Future<void> removerFavorito(String pontoId) async {
    await _api.delete('/favoritos/$pontoId');
  }

  Future<bool> isFavorito(String pontoId) async {
    final response = await _api.get('/favoritos/verificar/$pontoId');
    return response.data['isFavorito'] ?? false;
  }
}