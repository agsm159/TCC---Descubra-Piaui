import 'package:flutter/material.dart';
import '../../core/theme.dart';

class BarraAcoes extends StatelessWidget {
  final VoidCallback onAbrirLista;
  final VoidCallback onAbrirPerfil;
  final bool isLogado;
  final bool isAdmin;

  const BarraAcoes({
    super.key,
    required this.onAbrirLista,
    required this.onAbrirPerfil,
    required this.isLogado,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: AppColors.verdePrincipal,
      selectedItemColor: AppColors.branco,
      unselectedItemColor: AppColors.branco.withOpacity(0.6),
      selectedLabelStyle: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: const TextStyle(fontSize: 11),
      onTap: (index) {
        if (index == 0) onAbrirLista();
        if (index == 1) onAbrirPerfil();
      },
      currentIndex: 0,
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.explore_outlined),
          activeIcon: Icon(Icons.explore),
          label: 'Pontos',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            isLogado ? Icons.account_circle_outlined : Icons.login_outlined,
          ),
          activeIcon: Icon(isLogado ? Icons.account_circle : Icons.login),
          label: isLogado ? (isAdmin ? 'Admin' : 'Perfil') : 'Entrar',
        ),
      ],
    );
  }
}
