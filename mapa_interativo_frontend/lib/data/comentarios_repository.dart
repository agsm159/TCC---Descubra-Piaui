import '../core/api_service.dart';
import '../models/comentario.dart';

class ComentariosRepository {
  final ApiService _api;
  ComentariosRepository(this._api);

  Future<List<Comentario>> getComentarios(String pontoId) async {
    final response = await _api.get('/pontos/$pontoId/comentarios');
    final List data = response.data;
    return data.map((json) => Comentario.fromJson(json)).toList();
  }

  Future<Comentario> criar(String pontoId, String texto) async {
    final response = await _api.post('/pontos/$pontoId/comentarios', {'texto': texto});
    return Comentario.fromJson(response.data);
  }

  Future<Comentario> atualizar(String pontoId, String id, String texto) async {
    final response = await _api.put('/pontos/$pontoId/comentarios/$id', {'texto': texto});
    return Comentario.fromJson(response.data);
  }

  Future<void> deletar(String pontoId, String id) async {
    await _api.delete('/pontos/$pontoId/comentarios/$id');
  }
}