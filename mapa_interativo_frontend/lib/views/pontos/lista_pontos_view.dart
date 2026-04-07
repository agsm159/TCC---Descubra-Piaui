import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/pontos_controller.dart';
import '../../controllers/cidades_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../core/theme.dart';
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
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Pontos de Interesse'),
        actions: [
          IconButton(
            icon: Icon(
              _mostrarFiltros ? Icons.filter_list_off : Icons.filter_list,
            ),
            tooltip: 'Mostrar/Ocultar filtros',
            onPressed: () {
              setState(() => _mostrarFiltros = !_mostrarFiltros);
            },
          ),
        ],
      ),
      floatingActionButton: auth.isAdmin
          ? FloatingActionButton(
              onPressed: _abrirFormulario,
              backgroundColor: AppColors.verdePrincipal,
              foregroundColor: AppColors.branco,
              child: const Icon(Icons.add),
            )
          : null,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
              child: BarraPesquisa(
                onResultado: _atualizarLista,
                idZona: _zonaSelecionada,
              ),
            ),
          ),

          if (_mostrarFiltros)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.branco,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.cinzaBorda),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.filter_alt_outlined,
                          color: AppColors.verdePrincipal,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Filtrar por',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.verdePrincipal,
                          ),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          icon: const Icon(Icons.clear, size: 16),
                          label: const Text('Limpar'),
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
                      ],
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Cidade',
                        prefixIcon: Icon(Icons.location_city_outlined),
                      ),
                      value: _cidadeSelecionada?.id,
                      items: cidadesController.todasCidades.map((cidade) {
                        return DropdownMenuItem(
                          value: cidade.id,
                          child: Text(cidade.nome),
                        );
                      }).toList(),
                      onChanged: _selecionarCidade,
                    ),
                    if (_cidadeSelecionada != null) ...[
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Zona',
                          prefixIcon: Icon(Icons.map_outlined),
                        ),
                        value: _zonaSelecionada,
                        items: _cidadeSelecionada!.zonas.map((zona) {
                          return DropdownMenuItem(
                            value: zona.id,
                            child: Text(zona.nome),
                          );
                        }).toList(),
                        onChanged: _selecionarZona,
                      ),
                    ],
                  ],
                ),
              ),
            ),

          if (_pontos.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off_rounded,
                      size: 72,
                      color: AppColors.cinzaBorda,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Nenhum ponto encontrado',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.cinzaTexto,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tente ajustar os filtros ou a busca',
                      style: TextStyle(color: AppColors.cinzaTexto),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final ponto = _pontos[index];
                  return _CardPonto(
                    ponto: ponto,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetalhesPonto(ponto: ponto),
                        ),
                      ).then((_) {
                        final pontosController = context
                            .read<PontosController>();
                        setState(() {
                          _pontos = pontosController.todos
                            ..sort((a, b) => a.nome.compareTo(b.nome));
                        });
                      });
                    },
                  );
                }, childCount: _pontos.length),
              ),
            ),
        ],
      ),
    );
  }
}

class _CardPonto extends StatelessWidget {
  final PontoInteresse ponto;
  final VoidCallback onTap;

  const _CardPonto({required this.ponto, required this.onTap});

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
                    const SizedBox(height: 8),

                    if (ponto.acessibilidade.isNotEmpty)
                      Wrap(
                        spacing: 4,
                        children: ponto.acessibilidade
                            .take(2)
                            .map(
                              (a) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.verdeSutil,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  a.name,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.verdePrincipal,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                  ],
                ),
              ),
            ),

            // Seta
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(Icons.chevron_right, color: AppColors.cinzaTexto),
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
