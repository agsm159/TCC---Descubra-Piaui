import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/pontos_controller.dart';
import '../../models/ponto_interesse.dart';
import 'mapa_widget.dart';
import 'barra_acoes.dart';
import '../pontos/lista_pontos_view.dart';
import '../pontos/detalhes_ponto.dart';
import '../pontos/adicionar_ponto.dart';

class MapaView extends StatefulWidget {
  const MapaView({super.key});

  @override
  State<MapaView> createState() => _MapaViewState();
}

class _MapaViewState extends State<MapaView> {
  final MapController _mapController = MapController();
  final ValueNotifier<PontoInteresse?> _pontoSelecionado = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PontosController>().carregarPontos();
    });
  }

  void _abrirLista() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ListaPontosView()),
    );
  }

  void _abrirPerfil() {
    final auth = context.read<AuthController>();
    if (auth.isLogado) {
      Navigator.pushNamed(context, '/perfil');
    } else {
      Navigator.pushNamed(context, '/login');
    }
  }

  void _abrirAdicionarPonto() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AdicionarPonto()),
    );
  }

  Future<void> _mostrarInfo(PontoInteresse ponto) async {
    final resultado = await Navigator.push<PontoInteresse?>(
      context,
      MaterialPageRoute(builder: (_) => DetalhesPonto(ponto: ponto)),
    );
    if (resultado != null) {
      _mapController.move(
        LatLng(resultado.latitude, resultado.longitude),
        16.0,
      );
    }
    if (mounted) {
      context.read<PontosController>().carregarPontos();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final pontosController = context.watch<PontosController>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 600;

        return Scaffold(
          body: pontosController.carregando
              ? const Center(child: CircularProgressIndicator())
              : pontosController.erro != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(pontosController.erro!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => pontosController.carregarPontos(),
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                )
              : isMobile
              ? MapaWidget(
                  pontos: pontosController.todos,
                  pontoSelecionadoNotifier: _pontoSelecionado,
                  mapController: _mapController,
                  onAbrirDetalhes: _mostrarInfo,
                )
              : Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: MapaWidget(
                        pontos: pontosController.todos,
                        pontoSelecionadoNotifier: _pontoSelecionado,
                        mapController: _mapController,
                        onAbrirDetalhes: _mostrarInfo,
                      ),
                    ),
                  ],
                ),

          // Botão flutuante de adicionar — só para admin
          floatingActionButton: auth.isAdmin
              ? FloatingActionButton(
                  onPressed: _abrirAdicionarPonto,
                  backgroundColor: const Color(0xFF1B5E20),
                  child: const Icon(Icons.add, color: Colors.white),
                )
              : null,

          bottomNavigationBar: BarraAcoes(
            onAbrirLista: _abrirLista,
            onAbrirPerfil: _abrirPerfil,
            isLogado: auth.isLogado,
            isAdmin: auth.isAdmin,
          ),
        );
      },
    );
  }
}
