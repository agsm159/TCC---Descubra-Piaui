import 'package:flutter/material.dart';
import '../data/avaliacoes_repository.dart';
import '../models/avaliacao.dart';

class AvaliacoesController extends ChangeNotifier {
  final AvaliacoesRepository _repository;
  AvaliacoesController(this._repository);

  List<Avaliacao> avaliacoes = [];
  double media = 0;
  int total = 0;
  int? minhaAvaliacao;
  bool carregando = false;
  String? erro;

  Future<void> carregarAvaliacoes(String pontoId) async {
    carregando = true;
    erro = null;
    notifyListeners();
    try {
      final resultado = await _repository.getAvaliacoes(pontoId);
      avaliacoes = resultado['avaliacoes'];
      media = resultado['media'];
      total = resultado['total'];
    } catch (e) {
      erro = 'Erro ao carregar avaliações: $e';
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  Future<void> carregarMinhaAvaliacao(String pontoId) async {
    try {
      minhaAvaliacao = await _repository.getMinhaAvaliacao(pontoId);
      notifyListeners();
    } catch (e) {
      erro = 'Erro ao carregar avaliação: $e';
    }
  }

  Future<bool> avaliar(String pontoId, int estrelas) async {
    try {
      await _repository.avaliar(pontoId, estrelas);
      minhaAvaliacao = estrelas;
      await carregarAvaliacoes(pontoId);
      return true;
    } catch (e) {
      erro = 'Erro ao avaliar: $e';
      notifyListeners();
      return false;
    }
  }
}