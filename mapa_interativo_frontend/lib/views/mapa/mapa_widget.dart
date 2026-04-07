import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';
import '../../core/theme.dart';
import '../../models/ponto_interesse.dart';

class MapaWidget extends StatelessWidget {
  final List<PontoInteresse> pontos;
  final ValueNotifier<PontoInteresse?> pontoSelecionadoNotifier;
  final MapController mapController;
  final Future<void> Function(PontoInteresse) onAbrirDetalhes;

  const MapaWidget({
    super.key,
    required this.pontos,
    required this.pontoSelecionadoNotifier,
    required this.mapController,
    required this.onAbrirDetalhes,
  });

  @override
  Widget build(BuildContext context) {
    const LatLng centroInicial = LatLng(-5.0892, -42.8019);

    return FlutterMap(
      mapController: mapController,
      options: const MapOptions(initialCenter: centroInicial, initialZoom: 7.0),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.exemplo.app',
          tileProvider: CancellableNetworkTileProvider(),
        ),
        MarkerLayer(
          markers: pontos.map((ponto) {
            return Marker(
              width: 44,
              height: 44,
              point: LatLng(ponto.latitude, ponto.longitude),
              child: GestureDetector(
                onTap: () => onAbrirDetalhes(ponto),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      bottom: 2,
                      child: Container(
                        width: 12,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.location_on,
                      size: 40,
                      color: AppColors.verdePrincipal,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
