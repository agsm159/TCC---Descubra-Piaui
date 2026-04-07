import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/pontos_controller.dart';
import '../../core/theme.dart';
import '../../models/ponto_interesse.dart';
import 'mapa_widget.dart';
import 'barra_acoes.dart';
import '../pontos/lista_pontos_view.dart';
import '../pontos/detalhes_ponto.dart';

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
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.verdePrincipal,
                  ),
                )
              : pontosController.erro != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.wifi_off_rounded,
                          size: 64,
                          color: AppColors.cinzaBorda,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Não foi possível carregar os pontos',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.cinzaEscuro,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          pontosController.erro!,
                          style: const TextStyle(
                            color: AppColors.cinzaTexto,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => pontosController.carregarPontos(),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
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
