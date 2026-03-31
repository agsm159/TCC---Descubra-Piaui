import '../core/api_service.dart';
import '../models/evento.dart';

class EventosRepository {
  final ApiService _api;
  EventosRepository(this._api);

  Future<List<Evento>> getEventos(String pontoId) async {
    final response = await _api.get('/pontos/$pontoId/eventos');
    final List data = response.data;
    return data.map((json) => Evento.fromJson(json)).toList();
  }

  Future<Evento> criar(String pontoId, Map<String, dynamic> dados) async {
    final response = await _api.post('/pontos/$pontoId/eventos', dados);
    return Evento.fromJson(response.data);
  }

  Future<Evento> atualizar(String pontoId, String id, Map<String, dynamic> dados) async {
    final response = await _api.put('/pontos/$pontoId/eventos/$id', dados);
    return Evento.fromJson(response.data);
  }

  Future<void> deletar(String pontoId, String id) async {
    await _api.delete('/pontos/$pontoId/eventos/$id');
  }
}