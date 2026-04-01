import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';

enum _TelaEstado { login, registro, recuperarSenha }

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _nomeController = TextEditingController();
  bool _senhaVisivel = false;
  _TelaEstado _estado = _TelaEstado.login;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    _nomeController.dispose();
    super.dispose();
  }

  void _mudarEstado(_TelaEstado novoEstado) {
    setState(() {
      _estado = novoEstado;
      _emailController.clear();
      _senhaController.clear();
      _nomeController.clear();
    });
  }

  Future<void> _fazerLogin() async {
    final auth = context.read<AuthController>();
    final sucesso = await auth.login(
      _emailController.text.trim(),
      _senhaController.text.trim(),
    );
    if (!mounted) return;
    if (sucesso) {
      Navigator.pushReplacementNamed(context, '/mapa');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.erro ?? 'Erro ao fazer login'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _fazerRegistro() async {
    final auth = context.read<AuthController>();
    final sucesso = await auth.registrar(
      _emailController.text.trim(),
      _senhaController.text.trim(),
      _nomeController.text.trim(),
    );
    if (!mounted) return;
    if (sucesso) {
      Navigator.pushReplacementNamed(context, '/mapa');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.erro ?? 'Erro ao criar conta'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _recuperarSenha() async {
    final auth = context.read<AuthController>();
    final sucesso = await auth.recuperarSenha(_emailController.text.trim());
    if (!mounted) return;
    if (sucesso) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Email de recuperação enviado! Verifique sua caixa de entrada.',
          ),
          backgroundColor: Colors.green,
        ),
      );
      _mudarEstado(_TelaEstado.login);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.erro ?? 'Erro ao enviar email'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String get _titulo {
    switch (_estado) {
      case _TelaEstado.login:
        return 'Bem-vindo de volta!';
      case _TelaEstado.registro:
        return 'Criar conta';
      case _TelaEstado.recuperarSenha:
        return 'Recuperar senha';
    }
  }

  String get _subtitulo {
    switch (_estado) {
      case _TelaEstado.login:
        return 'Entre com sua conta para acessar todos os recursos';
      case _TelaEstado.registro:
        return 'Preencha os dados para criar sua conta';
      case _TelaEstado.recuperarSenha:
        return 'Informe seu email para receber o link de recuperação';
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _estado == _TelaEstado.login
              ? 'Entrar'
              : _estado == _TelaEstado.registro
              ? 'Criar conta'
              : 'Recuperar senha',
        ),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),

            Text(
              _titulo,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _subtitulo,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 40),

            // Campo Nome
            if (_estado == _TelaEstado.registro) ...[
              TextField(
                controller: _nomeController,
                decoration: InputDecoration(
                  labelText: 'Nome (opcional)',
                  prefixIcon: const Icon(Icons.person_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Campo de Email
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Campo de Senha
            if (_estado != _TelaEstado.recuperarSenha) ...[
              TextField(
                controller: _senhaController,
                obscureText: !_senhaVisivel,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _senhaVisivel ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() => _senhaVisivel = !_senhaVisivel);
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ] else
              const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: auth.carregando
                    ? null
                    : () {
                        if (_estado == _TelaEstado.login) {
                          _fazerLogin();
                        } else if (_estado == _TelaEstado.registro) {
                          _fazerRegistro();
                        } else {
                          _recuperarSenha();
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E20),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: auth.carregando
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        _estado == _TelaEstado.login
                            ? 'Entrar'
                            : _estado == _TelaEstado.registro
                            ? 'Criar conta'
                            : 'Enviar email',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 24),

            if (_estado == _TelaEstado.login) ...[
              Center(
                child: TextButton(
                  onPressed: () => _mudarEstado(_TelaEstado.recuperarSenha),
                  child: const Text('Esqueci minha senha'),
                ),
              ),

              Center(
                child: TextButton(
                  onPressed: () => _mudarEstado(_TelaEstado.registro),
                  child: const Text(
                    'Não tem conta? Criar conta',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ] else ...[
              Center(
                child: TextButton(
                  onPressed: () => _mudarEstado(_TelaEstado.login),
                  child: const Text('Voltar para o login'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
