import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../core/theme.dart';

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
      _senhaVisivel = false;
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
          backgroundColor: AppColors.erro,
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
          backgroundColor: AppColors.erro,
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
          backgroundColor: AppColors.sucesso,
        ),
      );
      _mudarEstado(_TelaEstado.login);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.erro ?? 'Erro ao enviar email'),
          backgroundColor: AppColors.erro,
        ),
      );
    }
  }

  String get _tituloAppBar {
    switch (_estado) {
      case _TelaEstado.login:
        return 'Entrar';
      case _TelaEstado.registro:
        return 'Criar conta';
      case _TelaEstado.recuperarSenha:
        return 'Recuperar senha';
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

  IconData get _icone {
    switch (_estado) {
      case _TelaEstado.login:
        return Icons.login_rounded;
      case _TelaEstado.registro:
        return Icons.person_add_rounded;
      case _TelaEstado.recuperarSenha:
        return Icons.lock_reset_rounded;
    }
  }

  String get _labelBotao {
    switch (_estado) {
      case _TelaEstado.login:
        return 'Entrar';
      case _TelaEstado.registro:
        return 'Criar conta';
      case _TelaEstado.recuperarSenha:
        return 'Enviar email';
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    return Scaffold(
      appBar: AppBar(key: ValueKey(_estado), title: Text(_tituloAppBar)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
              decoration: const BoxDecoration(
                color: AppColors.verdePrincipal,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _titulo,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.branco,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _subtitulo,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.branco.withOpacity(0.85),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),

                  // Campo Nome
                  if (_estado == _TelaEstado.registro) ...[
                    TextField(
                      controller: _nomeController,
                      decoration: const InputDecoration(
                        labelText: 'Nome (opcional)',
                        prefixIcon: Icon(Icons.person_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Campo Email
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Campo Senha
                  if (_estado != _TelaEstado.recuperarSenha) ...[
                    TextField(
                      controller: _senhaController,
                      obscureText: !_senhaVisivel,
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _senhaVisivel
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() => _senhaVisivel = !_senhaVisivel);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ] else
                    const SizedBox(height: 16),

                  Center(
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
                      child: auth.carregando
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                color: AppColors.branco,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(_labelBotao),
                    ),
                  ),

                  const SizedBox(height: 16),

                  if (_estado == _TelaEstado.login) ...[
                    Center(
                      child: TextButton(
                        onPressed: () =>
                            _mudarEstado(_TelaEstado.recuperarSenha),
                        child: const Text('Esqueci minha senha'),
                      ),
                    ),
                    const Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'ou',
                            style: TextStyle(color: AppColors.cinzaTexto),
                          ),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: OutlinedButton(
                        onPressed: () => _mudarEstado(_TelaEstado.registro),
                        child: const Text('Criar nova conta'),
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
          ],
        ),
      ),
    );
  }
}
