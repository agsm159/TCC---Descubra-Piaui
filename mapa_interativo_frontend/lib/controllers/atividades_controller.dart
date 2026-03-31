import 'package:flutter/material.dart';
import '../data/atividades_repository.dart';
import '../models/atividade.dart';

class AtividadesController extends ChangeNotifier {
  final AtividadesRepository _repository;
  AtividadesController(this._repository);

  List<Atividade> atividades = [];
  bool carregando = false;
  String? erro;

  Future<void> carregarAtividades(String pontoId) async {
    carregando = true;
    erro = null;
    notifyListeners();
    try {
      atividades = await _repository.getAtividades(pontoId);
    } catch (e) {
      erro = 'Erro ao carregar atividades: $e';
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  Future<bool> adicionar(String pontoId, Map<String, dynamic> dados) async {
    try {
      final nova = await _repository.criar(pontoId, dados);
      atividades.add(nova);
      notifyListeners();
      return true;
    } catch (e) {
      erro = 'Erro ao adicionar atividade: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> atualizar(String pontoId, String id, Map<String, dynamic> dados) async {
    try {
      final atualizada = await _repository.atualizar(pontoId, id, dados);
      final index = atividades.indexWhere((a) => a.id == id);
      if (index != -1) atividades[index] = atualizada;
      notifyListeners();
      return true;
    } catch (e) {
      erro = 'Erro ao atualizar atividade: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deletar(String pontoId, String id) async {
    try {
      await _repository.deletar(pontoId, id);
      atividades.removeWhere((a) => a.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      erro = 'Erro ao deletar atividade: $e';
      notifyListeners();
      return false;
    }
  }
}