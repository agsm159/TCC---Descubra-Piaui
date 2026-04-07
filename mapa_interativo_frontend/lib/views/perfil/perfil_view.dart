import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../core/theme.dart';

class PerfilView extends StatelessWidget {
  const PerfilView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final inicial = auth.nome?.isNotEmpty == true
        ? auth.nome![0].toUpperCase()
        : '?';

    return Scaffold(
      appBar: AppBar(title: const Text('Meu Perfil')),
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
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: AppColors.branco.withOpacity(0.2),
                    child: Text(
                      inicial,
                      style: const TextStyle(
                        fontSize: 36,
                        color: AppColors.branco,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text(
                    auth.nome?.isNotEmpty == true ? auth.nome! : 'Usuário',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.branco,
                    ),
                  ),
                  const SizedBox(height: 4),

                  Text(
                    auth.email ?? '',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.branco.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (auth.isAdmin)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.branco.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.branco.withOpacity(0.5),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified,
                            color: AppColors.branco,
                            size: 14,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Administrador',
                            style: TextStyle(
                              color: AppColors.branco,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // ── Conteúdo ───────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 8),

                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(
                            Icons.person_outline,
                            color: AppColors.verdePrincipal,
                          ),
                          title: const Text(
                            'Nome',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.cinzaTexto,
                            ),
                          ),
                          subtitle: Text(
                            auth.nome?.isNotEmpty == true
                                ? auth.nome!
                                : 'Não informado',
                            style: const TextStyle(
                              fontSize: 15,
                              color: AppColors.cinzaEscuro,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(
                            Icons.email_outlined,
                            color: AppColors.verdePrincipal,
                          ),
                          title: const Text(
                            'Email',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.cinzaTexto,
                            ),
                          ),
                          subtitle: Text(
                            auth.email ?? 'Não informado',
                            style: const TextStyle(
                              fontSize: 15,
                              color: AppColors.cinzaEscuro,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.favorite_outline,
                        color: Colors.red,
                      ),
                      title: const Text('Meus Favoritos'),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: AppColors.cinzaTexto,
                      ),
                      onTap: () => Navigator.pushNamed(context, '/favoritos'),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Botão logout
                  Center(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.logout, color: Colors.red),
                      label: const Text('Sair da conta'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      onPressed: () async {
                        await auth.logout();
                        if (!context.mounted) return;
                        Navigator.pushReplacementNamed(context, '/welcome');
                      },
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
