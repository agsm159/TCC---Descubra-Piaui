import '../core/api_service.dart';
import '../models/avaliacao.dart';

class AvaliacoesRepository {
  final ApiService _api;
  AvaliacoesRepository(this._api);

  Future<Map<String, dynamic>> getAvaliacoes(String pontoId) async {
    final response = await _api.get('/pontos/$pontoId/avaliacoes');
    final List avaliacoes = response.data['avaliacoes'];
    final media = response.data['media'];
    return {
      'avaliacoes': avaliacoes.map((json) => Avaliacao.fromJson(json)).toList(),
      'media': (media['media'] as num).toDouble(),
      'total': media['total'] as int,
    };
  }

  Future<int?> getMinhaAvaliacao(String pontoId) async {
    final response = await _api.get('/pontos/$pontoId/avaliacoes/minha');
    return response.data['estrelas'];
  }

  Future<void> avaliar(String pontoId, int estrelas) async {
    await _api.post('/pontos/$pontoId/avaliacoes', {'estrelas': estrelas});
  }
}