import 'package:flutter/material.dart';

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
    final theme = Theme.of(context);
    final bg = theme.colorScheme.primary;
    final iconColor = theme.colorScheme.onPrimary;

    return SafeArea(
      top: false,
      child: Row(
        children: [
          Expanded(
            child: Material(
              color: bg,
              child: InkWell(
                onTap: onAbrirLista,
                child: SizedBox(
                  height: kBottomNavigationBarHeight,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.list, color: iconColor),
                      Text(
                        'Pontos',
                        style: TextStyle(color: iconColor, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          Expanded(
            child: Material(
              color: bg,
              child: InkWell(
                onTap: onAbrirPerfil,
                child: SizedBox(
                  height: kBottomNavigationBarHeight,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isLogado ? Icons.account_circle : Icons.login,
                        color: iconColor,
                      ),
                      Text(
                        isLogado
                            ? (isAdmin ? 'Admin' : 'Perfil')
                            : 'Entrar',
                        style: TextStyle(color: iconColor, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}