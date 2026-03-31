import 'package:flutter/material.dart';
import '../data/eventos_repository.dart';
import '../models/evento.dart';

class EventosController extends ChangeNotifier {
  final EventosRepository _repository;
  EventosController(this._repository);

  List<Evento> eventos = [];
  bool carregando = false;
  String? erro;

  Future<void> carregarEventos(String pontoId) async {
    carregando = true;
    erro = null;
    notifyListeners();
    try {
      eventos = await _repository.getEventos(pontoId);
    } catch (e) {
      erro = 'Erro ao carregar eventos: $e';
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  Future<bool> adicionar(String pontoId, Map<String, dynamic> dados) async {
    try {
      final novo = await _repository.criar(pontoId, dados);
      eventos.add(novo);
      notifyListeners();
      return true;
    } catch (e) {
      erro = 'Erro ao adicionar evento: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> atualizar(String pontoId, String id, Map<String, dynamic> dados) async {
    try {
      final atualizado = await _repository.atualizar(pontoId, id, dados);
      final index = eventos.indexWhere((e) => e.id == id);
      if (index != -1) eventos[index] = atualizado;
      notifyListeners();
      return true;
    } catch (e) {
      erro = 'Erro ao atualizar evento: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deletar(String pontoId, String id) async {
    try {
      await _repository.deletar(pontoId, id);
      eventos.removeWhere((e) => e.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      erro = 'Erro ao deletar evento: $e';
      notifyListeners();
      return false;
    }
  }
}