import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/favoritos_controller.dart';
import '../../core/theme.dart';
import '../../models/ponto_interesse.dart';
import '../pontos/detalhes_ponto.dart';

class FavoritosView extends StatefulWidget {
  const FavoritosView({super.key});

  @override
  State<FavoritosView> createState() => _FavoritosViewState();
}

class _FavoritosViewState extends State<FavoritosView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavoritosController>().carregarFavoritos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<FavoritosController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Meus Favoritos')),
      body: controller.carregando
          ? const Center(child: CircularProgressIndicator())
          : controller.erro != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: AppColors.erro,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    controller.erro!,
                    style: const TextStyle(color: AppColors.cinzaTexto),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => controller.carregarFavoritos(),
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            )
          : controller.favoritos.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.verdeSutil,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite_outline_rounded,
                      size: 64,
                      color: AppColors.verdePrincipal,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Nenhum favorito ainda',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.cinzaEscuro,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 48),
                    child: Text(
                      'Explore o mapa e favorite os pontos que gostar!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.cinzaTexto),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
              itemCount: controller.favoritos.length,
              itemBuilder: (context, index) {
                final ponto = controller.favoritos[index];
                return _CardFavorito(
                  ponto: ponto,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetalhesPonto(ponto: ponto),
                      ),
                    );
                  },
                  onDesfavoritar: () async {
                    await controller.toggleFavorito(ponto);
                  },
                );
              },
            ),
    );
  }
}

class _CardFavorito extends StatelessWidget {
  final PontoInteresse ponto;
  final VoidCallback onTap;
  final VoidCallback onDesfavoritar;

  const _CardFavorito({
    required this.ponto,
    required this.onTap,
    required this.onDesfavoritar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            SizedBox(
              width: 110,
              height: 110,
              child: ponto.imagens.isNotEmpty
                  ? Image.network(
                      ponto.imagens.first,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholderImagem(),
                    )
                  : _placeholderImagem(),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ponto.nome,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.cinzaEscuro,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ponto.descricao,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.cinzaTexto,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),

            // Botão desfavoritar
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: const Icon(Icons.favorite_rounded, color: Colors.red),
                tooltip: 'Remover dos favoritos',
                onPressed: onDesfavoritar,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderImagem() {
    return Container(
      color: AppColors.verdeSutil,
      child: const Center(
        child: Icon(
          Icons.photo_camera_outlined,
          color: AppColors.verdeClaro,
          size: 36,
        ),
      ),
    );
  }
}
