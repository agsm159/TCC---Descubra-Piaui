import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../core/theme.dart';

class WelcomeView extends StatefulWidget {
  const WelcomeView({super.key});

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> {
  @override
  void initState() {
    super.initState();
    _verificarSessao();
  }

  Future<void> _verificarSessao() async {
    final auth = context.read<AuthController>();
    await auth.carregarSessao();
    if (!mounted) return;
    if (auth.isLogado) {
      Navigator.pushReplacementNamed(context, '/mapa');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.verdePrincipal,
              Color(0xFF2E7D32),
              Color(0xFF1565C0),
            ],
            // controle dos gradientes da tela inicial
            stops: [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const Spacer(flex: 2),

                // Ícone
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.branco.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.map_outlined,
                    size: 72,
                    color: AppColors.branco,
                  ),
                ),
                const SizedBox(height: 32),

                // Título
                const Text(
                  'Descubra Piauí',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: AppColors.branco,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),

                // Subtítulo
                Text(
                  'Explore os pontos históricos\ne turísticos do estado do Piauí',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.branco.withOpacity(0.85),
                    height: 1.5,
                  ),
                ),

                const Spacer(flex: 3),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Explorar
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/mapa');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.branco,
                        foregroundColor: AppColors.verdePrincipal,
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 28,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: const Text('Explorar'),
                    ),

                    const SizedBox(width: 16),

                    // Entrar
                    OutlinedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.branco,
                        side: const BorderSide(
                          color: AppColors.branco,
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 28,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: const Text('Entrar'),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Text(
                  'Faça login para usar todas as funções',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.branco.withOpacity(0.6),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}