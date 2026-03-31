import 'package:flutter/material.dart';
import '../data/comentarios_repository.dart';
import '../models/comentario.dart';

class ComentariosController extends ChangeNotifier {
  final ComentariosRepository _repository;
  ComentariosController(this._repository);

  List<Comentario> comentarios = [];
  bool carregando = false;
  String? erro;

  Future<void> carregarComentarios(String pontoId) async {
    carregando = true;
    erro = null;
    notifyListeners();
    try {
      comentarios = await _repository.getComentarios(pontoId);
    } catch (e) {
      erro = 'Erro ao carregar comentários: $e';
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  Future<bool> adicionar(String pontoId, String texto) async {
    try {
      final novo = await _repository.criar(pontoId, texto);
      comentarios.insert(0, novo);
      notifyListeners();
      return true;
    } catch (e) {
      erro = 'Erro ao adicionar comentário: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> atualizar(String pontoId, String id, String texto) async {
    try {
      final atualizado = await _repository.atualizar(pontoId, id, texto);
      final index = comentarios.indexWhere((c) => c.id == id);
      if (index != -1) comentarios[index] = atualizado;
      notifyListeners();
      return true;
    } catch (e) {
      erro = 'Erro ao atualizar comentário: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deletar(String pontoId, String id) async {
    try {
      await _repository.deletar(pontoId, id);
      comentarios.removeWhere((c) => c.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      erro = 'Erro ao deletar comentário: $e';
      notifyListeners();
      return false;
    }
  }
}