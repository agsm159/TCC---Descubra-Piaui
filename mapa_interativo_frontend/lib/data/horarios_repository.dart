import '../core/api_service.dart';
import '../models/horario_funcionamento.dart';

class HorariosRepository {
  final ApiService _api;
  HorariosRepository(this._api);

  Future<List<HorarioFuncionamento>> getHorarios(String pontoId) async {
    final response = await _api.get('/pontos/$pontoId/horarios');
    final List data = response.data;
    return data.map((json) => HorarioFuncionamento.fromJson(json)).toList();
  }

  Future<HorarioFuncionamento> criar(String pontoId, Map<String, dynamic> dados) async {
    final response = await _api.post('/pontos/$pontoId/horarios', dados);
    return HorarioFuncionamento.fromJson(response.data);
  }

  Future<HorarioFuncionamento> atualizar(String pontoId, String id, Map<String, dynamic> dados) async {
    final response = await _api.put('/pontos/$pontoId/horarios/$id', dados);
    return HorarioFuncionamento.fromJson(response.data);
  }

  Future<void> deletar(String pontoId, String id) async {
    await _api.delete('/pontos/$pontoId/horarios/$id');
  }
}