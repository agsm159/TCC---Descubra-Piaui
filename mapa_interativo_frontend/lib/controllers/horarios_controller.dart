import 'package:flutter/material.dart';
import '../data/horarios_repository.dart';
import '../models/horario_funcionamento.dart';

class HorariosController extends ChangeNotifier {
  final HorariosRepository _repository;
  HorariosController(this._repository);

  List<HorarioFuncionamento> horarios = [];
  bool carregando = false;
  String? erro;

  Future<void> carregarHorarios(String pontoId) async {
    carregando = true;
    erro = null;
    notifyListeners();
    try {
      horarios = await _repository.getHorarios(pontoId);
    } catch (e) {
      erro = 'Erro ao carregar horários: $e';
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  Future<bool> adicionar(String pontoId, Map<String, dynamic> dados) async {
    try {
      final novo = await _repository.criar(pontoId, dados);
      horarios.add(novo);
      notifyListeners();
      return true;
    } catch (e) {
      erro = 'Erro ao adicionar horário: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> atualizar(String pontoId, String id, Map<String, dynamic> dados) async {
    try {
      final atualizado = await _repository.atualizar(pontoId, id, dados);
      final index = horarios.indexWhere((h) => h.id == id);
      if (index != -1) horarios[index] = atualizado;
      notifyListeners();
      return true;
    } catch (e) {
      erro = 'Erro ao atualizar horário: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deletar(String pontoId, String id) async {
    try {
      await _repository.deletar(pontoId, id);
      horarios.removeWhere((h) => h.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      erro = 'Erro ao deletar horário: $e';
      notifyListeners();
      return false;
    }
  }
}