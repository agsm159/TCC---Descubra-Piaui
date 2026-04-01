import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';
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
    final LatLng centroInicial = const LatLng(-5.0892, -42.8019);

    return FlutterMap(
      mapController: mapController,
      options: MapOptions(initialCenter: centroInicial, initialZoom: 7.0),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.exemplo.app',
          tileProvider: CancellableNetworkTileProvider(),
        ),
        MarkerLayer(
          markers: pontos.map((ponto) {
            return Marker(
              width: 40,
              height: 40,
              point: LatLng(ponto.latitude, ponto.longitude),
              child: GestureDetector(
                onTap: () => onAbrirDetalhes(ponto),
                child: const Icon(
                  Icons.location_on,
                  size: 36,
                  color: Colors.red,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
