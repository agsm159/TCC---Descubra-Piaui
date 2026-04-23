import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/cidades_controller.dart';
import '../../core/theme.dart';
import '../../models/cidade.dart';
import '../../models/zona.dart';

class GerenciarLocalizacoesView extends StatefulWidget {
  const GerenciarLocalizacoesView({super.key});

  @override
  State<GerenciarLocalizacoesView> createState() =>
      _GerenciarLocalizacoesViewState();
}

class _GerenciarLocalizacoesViewState extends State<GerenciarLocalizacoesView> {
  Cidade? _cidadeSelecionada;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CidadesController>().carregarCidades();
    });
  }

  Future<void> _mostrarDialogoCidade({Cidade? cidade}) async {
    final ctrl = TextEditingController(text: cidade?.nome ?? '');
    final isEdicao = cidade != null;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isEdicao ? 'Editar cidade' : 'Nova cidade'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Nome da cidade',
            prefixIcon: Icon(Icons.location_city_outlined),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final nome = ctrl.text.trim();
              if (nome.isEmpty) return;
              final cidadesController = context.read<CidadesController>();
              bool sucesso;
              if (isEdicao) {
                sucesso = await cidadesController.editarCidade(cidade.id, nome);
              } else {
                sucesso = await cidadesController.adicionarCidade(nome);
              }
              if (!context.mounted) return;
              Navigator.pop(context);
              if (!sucesso) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      cidadesController.erro ?? 'Erro ao salvar cidade',
                    ),
                    backgroundColor: AppColors.erro,
                  ),
                );
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmarExclusaoCidade(Cidade cidade) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir cidade'),
        content: Text(
          'Tem certeza que deseja excluir "${cidade.nome}"?\n\n'
          'Isso só é possível se não houver zonas vinculadas a ela.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.erro),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    final cidadesController = context.read<CidadesController>();
    final sucesso = await cidadesController.excluirCidade(cidade.id);

    if (!mounted) return;
    if (sucesso) {
      if (_cidadeSelecionada?.id == cidade.id) {
        setState(() => _cidadeSelecionada = null);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cidade excluída com sucesso')),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          icon: const Icon(Icons.block, color: AppColors.erro, size: 40),
          title: const Text('Não foi possível excluir'),
          content: const Text(
            'Esta cidade possui zonas cadastradas.\n\n'
            'Exclua todas as zonas desta cidade antes de excluí-la.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Entendido'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _mostrarDialogoZona({Zona? zona}) async {
    if (_cidadeSelecionada == null) return;
    final ctrl = TextEditingController(text: zona?.nome ?? '');
    final isEdicao = zona != null;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isEdicao ? 'Editar zona' : 'Nova zona'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Nome da zona',
            prefixIcon: Icon(Icons.map_outlined),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final nome = ctrl.text.trim();
              if (nome.isEmpty) return;
              final cidadesController = context.read<CidadesController>();
              bool sucesso;
              if (isEdicao) {
                sucesso = await cidadesController.editarZona(
                  _cidadeSelecionada!.id,
                  zona.id,
                  nome,
                );
              } else {
                sucesso = await cidadesController.adicionarZona(
                  nome,
                  _cidadeSelecionada!.id,
                );
              }
              if (!context.mounted) return;
              Navigator.pop(context);
              if (!sucesso) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      cidadesController.erro ?? 'Erro ao salvar zona',
                    ),
                    backgroundColor: AppColors.erro,
                  ),
                );
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmarExclusaoZona(Zona zona) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir zona'),
        content: Text(
          'Tem certeza que deseja excluir "${zona.nome}"?\n\n'
          'Isso só é possível se não houver pontos vinculados a ela.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.erro),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    final cidadesController = context.read<CidadesController>();
    final sucesso = await cidadesController.excluirZona(
      _cidadeSelecionada!.id,
      zona.id,
    );

    if (!mounted) return;
    if (sucesso) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Zona excluída com sucesso')),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          icon: const Icon(Icons.block, color: AppColors.erro, size: 40),
          title: const Text('Não foi possível excluir'),
          content: const Text(
            'Esta zona possui pontos cadastrados.\n\n'
            'Exclua todos os pontos desta zona antes de excluí-la.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Entendido'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cidadesController = context.watch<CidadesController>();
    final cidades = cidadesController.todasCidades;
    final zonas = _cidadeSelecionada?.zonas ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('Gerenciar Localizações')),
      body: Column(
        children: [
          // Cabeçalho
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
            decoration: const BoxDecoration(
              color: AppColors.verdePrincipal,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Text(
              'Gerencie as cidades e zonas cadastradas no sistema',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.branco.withOpacity(0.9),
              ),
            ),
          ),

          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_city_outlined,
                                  size: 16,
                                  color: AppColors.verdePrincipal,
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'Cidades',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.cinzaEscuro,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.add_circle_outline,
                                color: AppColors.verdePrincipal,
                              ),
                              tooltip: 'Nova cidade',
                              onPressed: () => _mostrarDialogoCidade(),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: cidadesController.carregando
                            ? const Center(child: CircularProgressIndicator())
                            : cidades.isEmpty
                            ? const Center(
                                child: Text(
                                  'Nenhuma cidade cadastrada',
                                  style: TextStyle(color: AppColors.cinzaTexto),
                                ),
                              )
                            : ListView.separated(
                                itemCount: cidades.length,
                                separatorBuilder: (_, __) =>
                                    const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final cidade = cidades[index];
                                  final selecionada =
                                      _cidadeSelecionada?.id == cidade.id;
                                  return ListTile(
                                    selected: selecionada,
                                    selectedTileColor: AppColors.verdeSutil,
                                    selectedColor: AppColors.verdePrincipal,
                                    title: Text(
                                      cidade.nome,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: selecionada
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                    ),
                                    subtitle: Text(
                                      '${cidade.zonas.length} zona(s)',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit_outlined,
                                            size: 18,
                                          ),
                                          onPressed: () =>
                                              _mostrarDialogoCidade(
                                                cidade: cidade,
                                              ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            size: 18,
                                            color: AppColors.erro,
                                          ),
                                          onPressed: () =>
                                              _confirmarExclusaoCidade(cidade),
                                        ),
                                      ],
                                    ),
                                    onTap: () {
                                      setState(() {
                                        _cidadeSelecionada = selecionada
                                            ? null
                                            : cidade;
                                      });
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),

                const VerticalDivider(width: 1),

                Expanded(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.map_outlined,
                                  size: 16,
                                  color: AppColors.verdePrincipal,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _cidadeSelecionada != null
                                      ? _cidadeSelecionada!.nome
                                      : 'Zonas',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.cinzaEscuro,
                                  ),
                                ),
                              ],
                            ),
                            if (_cidadeSelecionada != null)
                              IconButton(
                                icon: const Icon(
                                  Icons.add_circle_outline,
                                  color: AppColors.verdePrincipal,
                                ),
                                tooltip: 'Nova zona',
                                onPressed: () => _mostrarDialogoZona(),
                              ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: _cidadeSelecionada == null
                            ? const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.touch_app_outlined,
                                      size: 40,
                                      color: AppColors.cinzaBorda,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Selecione uma cidade\npara ver suas zonas',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: AppColors.cinzaTexto,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : zonas.isEmpty
                            ? const Center(
                                child: Text(
                                  'Nenhuma zona cadastrada',
                                  style: TextStyle(color: AppColors.cinzaTexto),
                                ),
                              )
                            : ListView.separated(
                                itemCount: zonas.length,
                                separatorBuilder: (_, __) =>
                                    const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final zona = zonas[index];
                                  return ListTile(
                                    title: Text(
                                      zona.nome,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit_outlined,
                                            size: 18,
                                          ),
                                          onPressed: () =>
                                              _mostrarDialogoZona(zona: zona),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            size: 18,
                                            color: AppColors.erro,
                                          ),
                                          onPressed: () =>
                                              _confirmarExclusaoZona(zona),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
