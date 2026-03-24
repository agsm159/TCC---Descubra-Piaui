import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/pontos_controller.dart';
import '../../models/ponto_interesse.dart';

class BarraPesquisa extends StatefulWidget {
  final Function(List<PontoInteresse>) onResultado;
  final String? idZona;

  const BarraPesquisa({
    super.key,
    required this.onResultado,
    this.idZona,
  });

  @override
  State<BarraPesquisa> createState() => _BarraPesquisaState();
}

class _BarraPesquisaState extends State<BarraPesquisa> {
  final TextEditingController _pesquisaCtrl = TextEditingController();

  void _buscar() {
    final controller = context.read<PontosController>();
    final termo = _pesquisaCtrl.text.trim();
    final resultado = controller.buscarPorNomeEmZona(termo, widget.idZona);
    widget.onResultado(resultado);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _pesquisaCtrl,
            decoration: const InputDecoration(
              hintText: 'Pesquisar ponto...',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => _buscar(),
          ),
        ),
        IconButton(icon: const Icon(Icons.search), onPressed: _buscar),
      ],
    );
  }
}