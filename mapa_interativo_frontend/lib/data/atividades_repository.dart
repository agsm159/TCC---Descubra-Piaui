import '../core/api_service.dart';
import '../models/atividade.dart';

class AtividadesRepository {
  final ApiService _api;
  AtividadesRepository(this._api);

  Future<List<Atividade>> getAtividades(String pontoId) async {
    final response = await _api.get('/pontos/$pontoId/atividades');
    final List data = response.data;
    return data.map((json) => Atividade.fromJson(json)).toList();
  }

  Future<Atividade> criar(String pontoId, Map<String, dynamic> dados) async {
    final response = await _api.post('/pontos/$pontoId/atividades', dados);
    return Atividade.fromJson(response.data);
  }

  Future<Atividade> atualizar(String pontoId, String id, Map<String, dynamic> dados) async {
    final response = await _api.put('/pontos/$pontoId/atividades/$id', dados);
    return Atividade.fromJson(response.data);
  }

  Future<void> deletar(String pontoId, String id) async {
    await _api.delete('/pontos/$pontoId/atividades/$id');
  }
}