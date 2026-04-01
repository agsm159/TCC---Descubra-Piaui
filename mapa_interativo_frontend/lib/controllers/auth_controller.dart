import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api_service.dart';

class AuthController extends ChangeNotifier {
  final ApiService _api;

  AuthController(this._api);

  bool isAdmin = false;
  bool isLogado = false;
  bool carregando = false;
  String? erro;
  String? nome;
  String? email;

  Future<bool> login(String emailInput, String senha) async {
    carregando = true;
    erro = null;
    notifyListeners();

    try {
      final response = await _api.post('/auth/login', {
        'email': emailInput,
        'senha': senha,
      });

      final token = response.data['token'];
      isAdmin = response.data['isAdmin'] ?? false;
      nome = response.data['nome'];
      email = emailInput;
      isLogado = true;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setBool('isAdmin', isAdmin);
      await prefs.setString('nome', nome ?? '');
      await prefs.setString('email', email ?? '');

      notifyListeners();
      return true;
    } catch (e) {
      erro = 'Email ou senha inválidos';
      isLogado = false;
      notifyListeners();
      return false;
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  Future<bool> registrar(
    String emailInput,
    String senha,
    String? nomeInput,
  ) async {
    carregando = true;
    erro = null;
    notifyListeners();

    try {
      final response = await _api.post('/auth/registrar', {
        'email': emailInput,
        'senha': senha,
        'nome': nomeInput?.isNotEmpty == true ? nomeInput : null,
      });

      return await login(emailInput, senha);
    } catch (e) {
      erro = 'Erro ao criar conta';
      carregando = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> recuperarSenha(String emailInput) async {
    carregando = true;
    erro = null;
    notifyListeners();

    try {
      await _api.post('/auth/recuperar-senha', {'email': emailInput});
      carregando = false;
      notifyListeners();
      return true;
    } catch (e) {
      erro = 'Erro ao enviar email de recuperação';
      carregando = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('isAdmin');
    await prefs.remove('nome');
    await prefs.remove('email');
    isAdmin = false;
    isLogado = false;
    nome = null;
    email = null;
    notifyListeners();
  }

  Future<void> carregarSessao() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    isAdmin = prefs.getBool('isAdmin') ?? false;
    nome = prefs.getString('nome');
    email = prefs.getString('email');
    isLogado = token != null;
    notifyListeners();
  }
}
