import 'package:flutter/material.dart';
import '../data/cidades_repository.dart';
import '../models/cidade.dart';
import '../models/zona.dart';

class CidadesController extends ChangeNotifier {
  final CidadesRepository _repository;

  CidadesController(this._repository);

  List<Cidade> _cidades = [];
  bool carregando = false;
  String? erro;

  List<Cidade> get todasCidades => _cidades;

  Future<void> carregarCidades() async {
    carregando = true;
    erro = null;
    notifyListeners();

    try {
      _cidades = await _repository.getCidades();
    } catch (e) {
      erro = 'Erro ao carregar cidades: $e';
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  List<Zona> buscarZonasPorCidade(String idCidade) {
    final cidade = _cidades.firstWhere(
      (c) => c.id == idCidade,
      orElse: () => Cidade(id: '', nome: '', zonas: []),
    );
    return cidade.zonas;
  }

  Cidade? buscarCidadePorId(String id) {
    try {
      return _cidades.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  Zona? buscarZonaPorId(String idZona) {
    for (final cidade in _cidades) {
      try {
        return cidade.zonas.firstWhere((z) => z.id == idZona);
      } catch (_) {}
    }
    return null;
  }

  Future<bool> adicionarCidade(String nome) async {
    try {
      final nova = await _repository.criarCidade(nome);
      _cidades.add(nova);
      notifyListeners();
      return true;
    } catch (e) {
      erro = 'Erro ao adicionar cidade: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> adicionarZona(String nome, String cidadeId) async {
    try {
      final nova = await _repository.criarZona(nome, cidadeId);
      final idx = _cidades.indexWhere((c) => c.id == cidadeId);
      if (idx != -1) {
        _cidades[idx].zonas.add(nova);
        notifyListeners();
      }
      return true;
    } catch (e) {
      erro = 'Erro ao adicionar zona: $e';
      notifyListeners();
      return false;
    }
  }
}