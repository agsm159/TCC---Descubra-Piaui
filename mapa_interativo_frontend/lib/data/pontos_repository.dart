import '../core/api_service.dart';
import '../models/ponto_interesse.dart';

class PontosRepository {
  final ApiService _api;
  PontosRepository(this._api);

  Future<List<PontoInteresse>> getPontos({
    String? cidadeId,
    String? zonaId,
  }) async {
    final response = await _api.get('/pontos', params: {
      if (cidadeId != null) 'cidadeId': cidadeId,
      if (zonaId != null) 'zonaId': zonaId,
    });
    final List data = response.data;
    return data.map((json) => PontoInteresse.fromJson(json)).toList();
  }

  Future<PontoInteresse> getPontoPorId(String id) async {
    final response = await _api.get('/pontos/$id');
    return PontoInteresse.fromJson(response.data);
  }

  Future<PontoInteresse> criarPonto(PontoInteresse ponto) async {
    final response = await _api.post('/pontos', ponto.toJson());
    return PontoInteresse.fromJson(response.data);
  }

  Future<PontoInteresse> editarPonto(String id, PontoInteresse ponto) async {
    final response = await _api.put('/pontos/$id', ponto.toJson());
    return PontoInteresse.fromJson(response.data);
  }

  Future<void> excluirPonto(String id) async {
    await _api.delete('/pontos/$id');
  }
}