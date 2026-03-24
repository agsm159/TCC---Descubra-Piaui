import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/favoritos_controller.dart';
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
      appBar: AppBar(
        title: const Text('Meus Favoritos'),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      body: controller.carregando
          ? const Center(child: CircularProgressIndicator())
          : controller.erro != null
              ? Center(child: Text(controller.erro!))
              : controller.favoritos.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.favorite_outline,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Nenhum favorito ainda.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Explore o mapa e favorite os pontos que gostar!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: controller.favoritos.length,
                      itemBuilder: (context, index) {
                        final ponto = controller.favoritos[index];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: const Icon(
                              Icons.location_on,
                              color: Color(0xFF1B5E20),
                            ),
                            title: Text(ponto.nome),
                            subtitle: Text(
                              ponto.descricao,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.favorite,
                                color: Colors.red,
                              ),
                              onPressed: () async {
                                await controller.toggleFavorito(ponto);
                              },
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DetalhesPonto(ponto: ponto),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
    );
  }
}