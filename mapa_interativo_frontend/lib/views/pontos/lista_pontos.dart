import 'package:flutter/material.dart';
import '../../models/ponto_interesse.dart';

class ListaPontos extends StatelessWidget {
  final List<PontoInteresse> pontosFiltrados;
  final Function(PontoInteresse) onSelecionarPonto;

  const ListaPontos({
    super.key,
    required this.pontosFiltrados,
    required this.onSelecionarPonto,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: pontosFiltrados.length,
      itemBuilder: (context, index) {
        final ponto = pontosFiltrados[index];
        return ListTile(
          leading: ponto.imagens.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: ponto.imagens.first.startsWith('http')
                      ? Image.network(
                          ponto.imagens.first,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.image, size: 48),
                        )
                      : Image.asset(
                          ponto.imagens.first,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.image, size: 48),
                        ),
                )
              : const Icon(Icons.location_on, size: 48),
          title: Text(ponto.nome),
          subtitle: Text(
            ponto.descricao,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () => onSelecionarPonto(ponto),
        );
      },
    );
  }
}