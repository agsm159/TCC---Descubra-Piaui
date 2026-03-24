import 'package:flutter/material.dart';
import '../data/favoritos_repository.dart';
import '../models/ponto_interesse.dart';

class FavoritosController extends ChangeNotifier {
  final FavoritosRepository _repository;

  FavoritosController(this._repository);

  List<PontoInteresse> favoritos = [];
  bool carregando = false;
  String? erro;

  Future<void> carregarFavoritos() async {
    carregando = true;
    erro = null;
    notifyListeners();

    try {
      favoritos = await _repository.getFavoritos();
    } catch (e) {
      erro = 'Erro ao carregar favoritos: $e';
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  Future<bool> toggleFavorito(PontoInteresse ponto) async {
    final jaFavorito = favoritos.any((f) => f.id == ponto.id);
    try {
      if (jaFavorito) {
        await _repository.removerFavorito(ponto.id);
        favoritos.removeWhere((f) => f.id == ponto.id);
      } else {
        await _repository.adicionarFavorito(ponto.id);
        favoritos.add(ponto);
      }
      notifyListeners();
      return true;
    } catch (e) {
      erro = 'Erro ao atualizar favorito: $e';
      notifyListeners();
      return false;
    }
  }

  bool isFavorito(String pontoId) {
    return favoritos.any((f) => f.id == pontoId);
  }
}