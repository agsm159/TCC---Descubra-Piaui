import '../core/api_service.dart';
import '../models/cidade.dart';
import '../models/zona.dart';

class CidadesRepository {
  final ApiService _api;
  CidadesRepository(this._api);

  Future<List<Cidade>> getCidades() async {
    final response = await _api.get('/cidades');
    final List data = response.data;
    return data.map((json) => Cidade.fromJson(json)).toList();
  }

  Future<Cidade?> getCidadePorId(String id) async {
    final response = await _api.get('/cidades/$id');
    return Cidade.fromJson(response.data);
  }

  Future<Cidade> criarCidade(String nome) async {
    final response = await _api.post('/cidades', {'nome': nome});
    return Cidade.fromJson(response.data);
  }

  Future<List<Zona>> getZonasPorCidade(String cidadeId) async {
    final response = await _api.get('/zonas', params: {'cidadeId': cidadeId});
    final List data = response.data;
    return data.map((json) => Zona.fromJson(json)).toList();
  }

  Future<Zona> criarZona(String nome, String cidadeId) async {
    final response = await _api.post('/zonas', {
      'nome': nome,
      'cidadeId': cidadeId,
    });
    return Zona.fromJson(response.data);
  }
}