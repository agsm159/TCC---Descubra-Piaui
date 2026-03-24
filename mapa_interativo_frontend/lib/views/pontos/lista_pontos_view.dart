import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/pontos_controller.dart';
import '../../controllers/cidades_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/ponto_interesse.dart';
import '../../models/cidade.dart';
import 'barra_pesquisa.dart';
import 'adicionar_ponto.dart';
import 'detalhes_ponto.dart';

class ListaPontosView extends StatefulWidget {
  const ListaPontosView({super.key});

  @override
  State<ListaPontosView> createState() => _ListaPontosViewState();
}

class _ListaPontosViewState extends State<ListaPontosView> {
  Cidade? _cidadeSelecionada;
  String? _zonaSelecionada;
  List<PontoInteresse> _pontos = [];
  bool _mostrarFiltros = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pontosController = context.read<PontosController>();
      final cidadesController = context.read<CidadesController>();
      cidadesController.carregarCidades();
      setState(() {
        _pontos = pontosController.todos
          ..sort((a, b) => a.nome.compareTo(b.nome));
      });
    });
  }

  void _selecionarCidade(String? id) {
    final cidadesController = context.read<CidadesController>();
    setState(() {
      _cidadeSelecionada = cidadesController.buscarCidadePorId(id!);
      _zonaSelecionada = null;
      _pontos = [];
    });
  }

  void _selecionarZona(String? idZona) {
    final pontosController = context.read<PontosController>();
    setState(() {
      _zonaSelecionada = idZona;
      if (idZona != null) {
        _pontos = pontosController.buscarPorZona(idZona)
          ..sort((a, b) => a.nome.compareTo(b.nome));
      } else {
        _pontos = [];
      }
    });
  }

  void _atualizarLista(List<PontoInteresse> resultados) {
    setState(() => _pontos = resultados);
  }

  void _abrirFormulario() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AdicionarPonto()),
    ).then((_) {
      final pontosController = context.read<PontosController>();
      setState(() {
        _pontos = pontosController.todos
          ..sort((a, b) => a.nome.compareTo(b.nome));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final cidadesController = context.watch<CidadesController>();
    final auth = context.watch<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pontos de Interesse'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Mostrar/Ocultar filtros',
            onPressed: () {
              setState(() => _mostrarFiltros = !_mostrarFiltros);
            },
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Barra de pesquisa
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: BarraPesquisa(
                onResultado: _atualizarLista,
                idZona: _zonaSelecionada,
              ),
            ),
          ),

          // Filtros
          if (_mostrarFiltros)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Cidade'),
                      value: _cidadeSelecionada?.id,
                      items: cidadesController.todasCidades.map((cidade) {
                        return DropdownMenuItem(
                          value: cidade.id,
                          child: Text(cidade.nome),
                        );
                      }).toList(),
                      onChanged: _selecionarCidade,
                    ),
                    const SizedBox(height: 8),
                    if (_cidadeSelecionada != null)
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Zona'),
                        value: _zonaSelecionada,
                        items: _cidadeSelecionada!.zonas.map((zona) {
                          return DropdownMenuItem(
                            value: zona.id,
                            child: Text(zona.nome),
                          );
                        }).toList(),
                        onChanged: _selecionarZona,
                      ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.clear),
                      label: const Text('Limpar filtros'),
                      onPressed: () {
                        final pontosController = context
                            .read<PontosController>();
                        setState(() {
                          _cidadeSelecionada = null;
                          _zonaSelecionada = null;
                          _pontos = pontosController.todos
                            ..sort((a, b) => a.nome.compareTo(b.nome));
                          _mostrarFiltros = false;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

          // Lista vazia
          if (_pontos.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Center(
                  child: Column(
                    children: const [
                      Icon(Icons.search_off, size: 64, color: Colors.grey),
                      SizedBox(height: 12),
                      Text(
                        'Nenhum ponto encontrado.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final ponto = _pontos[index];
                return ListTile(
                  title: Text(ponto.nome),
                  subtitle: Text(
                    ponto.descricao,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetalhesPonto(ponto: ponto),
                      ),
                    ).then((_) {
                      final pontosController = context.read<PontosController>();
                      setState(() {
                        _pontos = pontosController.todos
                          ..sort((a, b) => a.nome.compareTo(b.nome));
                      });
                    });
                  },
                );
              }, childCount: _pontos.length),
            ),

          // Botão adicionar — apenas admin
          if (auth.isAdmin)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: FilledButton.icon(
                    onPressed: _abrirFormulario,
                    icon: const Icon(Icons.add),
                    label: const Text('Adicionar Ponto'),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
