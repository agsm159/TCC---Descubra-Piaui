import 'package:flutter/material.dart';
import '../data/pontos_repository.dart';
import '../models/ponto_interesse.dart';
import 'cidades_controller.dart';

class PontosController extends ChangeNotifier {
  final PontosRepository _repository;

  PontosController(this._repository);

  List<PontoInteresse> _pontos = [];
  bool carregando = false;
  String? erro;

  List<PontoInteresse> get todos => _pontos;

  Future<void> carregarPontos({String? cidadeId, String? zonaId}) async {
    carregando = true;
    erro = null;
    notifyListeners();

    try {
      _pontos = await _repository.getPontos(
        cidadeId: cidadeId,
        zonaId: zonaId,
      );
    } catch (e) {
      erro = 'Erro ao carregar pontos: $e';
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  List<PontoInteresse> buscarPorNome(String termo) {
    return _pontos
        .where((p) => p.nome.toLowerCase().contains(termo.toLowerCase()))
        .toList();
  }

  List<PontoInteresse> buscarPorCidade(String idCidade, CidadesController cidadesController) {
  final zonasDaCidade = cidadesController.buscarZonasPorCidade(idCidade);
  final idsZonas = zonasDaCidade.map((z) => z.id).toSet();
  return _pontos
      .where((p) => idsZonas.contains(p.idZona))
      .toList()
    ..sort((a, b) => a.nome.compareTo(b.nome));
}

  List<PontoInteresse> buscarPorZona(String idZona) {
    return _pontos.where((p) => p.idZona == idZona).toList();
  }

  List<PontoInteresse> buscarPorNomeEmZona(String termo, String? idZona) {
    return _pontos.where((p) {
      final correspondeZona = idZona == null || p.idZona == idZona;
      final correspondeNome =
          p.nome.toLowerCase().contains(termo.toLowerCase());
      return correspondeZona && correspondeNome;
    }).toList();
  }

  Future<bool> adicionar(PontoInteresse ponto) async {
    try {
      final novo = await _repository.criarPonto(ponto);
      _pontos.add(novo);
      notifyListeners();
      return true;
    } catch (e) {
      erro = 'Erro ao adicionar ponto: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> editar(String id, PontoInteresse novo) async {
    try {
      final atualizado = await _repository.editarPonto(id, novo);
      final index = _pontos.indexWhere((p) => p.id == id);
      if (index != -1) {
        _pontos[index] = atualizado;
        notifyListeners();
      }
      return true;
    } catch (e) {
      erro = 'Erro ao editar ponto: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> excluir(String id) async {
    try {
      await _repository.excluirPonto(id);
      _pontos.removeWhere((p) => p.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      erro = 'Erro ao excluir ponto: $e';
      notifyListeners();
      return false;
    }
  }
}