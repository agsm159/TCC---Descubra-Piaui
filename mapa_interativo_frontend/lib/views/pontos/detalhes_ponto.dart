import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:mapa_interativo/views/pontos/adicionar_ponto.dart';
import '../../controllers/pontos_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/favoritos_controller.dart';
import '../../controllers/horarios_controller.dart';
import '../../controllers/atividades_controller.dart';
import '../../controllers/eventos_controller.dart';
import '../../controllers/avaliacoes_controller.dart';
import '../../controllers/comentarios_controller.dart';
import '../../models/ponto_interesse.dart';
import '../../models/acessibilidade.dart';

class DetalhesPonto extends StatefulWidget {
  final PontoInteresse ponto;

  const DetalhesPonto({super.key, required this.ponto});

  @override
  State<DetalhesPonto> createState() => _DetalhesPontoState();
}

class _DetalhesPontoState extends State<DetalhesPonto> {
  final PageController _pageController = PageController();
  int _paginaAtual = 0;
  late PontoInteresse _ponto;

  @override
  void initState() {
    super.initState();
    _ponto = widget.ponto;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final id = _ponto.id;
      context.read<HorariosController>().carregarHorarios(id);
      context.read<AtividadesController>().carregarAtividades(id);
      context.read<EventosController>().carregarEventos(id);
      context.read<AvaliacoesController>().carregarAvaliacoes(id);
      context.read<AvaliacoesController>().carregarMinhaAvaliacao(id);
      context.read<ComentariosController>().carregarComentarios(id);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _confirmarExclusao() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir ponto'),
        content: Text(
          'Tem certeza que deseja excluir "${widget.ponto.nome}"? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    final pontosController = context.read<PontosController>();
    final sucesso = await pontosController.excluir(widget.ponto.id);

    if (!mounted) return;

    if (sucesso) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ponto excluído com sucesso')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(pontosController.erro ?? 'Erro ao excluir ponto'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  IconData _iconeAcessibilidade(Acessibilidade tipo) {
    switch (tipo) {
      case Acessibilidade.rampa:
        return Icons.accessible_forward;
      case Acessibilidade.elevador:
        return Icons.elevator;
      case Acessibilidade.braille:
        return Icons.line_weight;
      case Acessibilidade.audioGuia:
        return Icons.hearing;
      case Acessibilidade.pisoTatil:
        return Icons.blur_on;
      case Acessibilidade.interpreteLibras:
        return Icons.sign_language;
      case Acessibilidade.outro:
        return Icons.accessibility_new;
    }
  }

  String _nomeAcessibilidade(Acessibilidade tipo) {
    switch (tipo) {
      case Acessibilidade.rampa:
        return 'Rampa';
      case Acessibilidade.elevador:
        return 'Elevador';
      case Acessibilidade.braille:
        return 'Braille';
      case Acessibilidade.audioGuia:
        return 'Áudio Guia';
      case Acessibilidade.pisoTatil:
        return 'Piso Tátil';
      case Acessibilidade.interpreteLibras:
        return 'Libras';
      case Acessibilidade.outro:
        return 'Outro';
    }
  }

  Widget _buildImagem(String path) {
    if (path.startsWith('http')) {
      return Image.network(
        path,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 80),
      );
    } else if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 80),
      );
    } else {
      return Image.memory(
        Uri.parse(path).data!.contentAsBytes(),
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 80),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final favoritosController = context.watch<FavoritosController>();
    final isFavorito = favoritosController.isFavorito(_ponto.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(_ponto.nome),
        actions: [
          // Botão de editar
          if (auth.isAdmin) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Editar ponto',
              onPressed: () async {
                final pontoAtualizado = await Navigator.push<PontoInteresse?>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AdicionarPonto(pontoParaEditar: _ponto),
                  ),
                );

                if (pontoAtualizado != null && mounted) {
                  setState(() => _ponto = pontoAtualizado);
                }
              },
            ),
            //Botão excluir
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              tooltip: 'Excluir ponto',
              onPressed: _confirmarExclusao,
            ),
          ],

          // Botão favoritar
          if (auth.isLogado)
            IconButton(
              icon: Icon(
                isFavorito ? Icons.favorite : Icons.favorite_outline,
                color: isFavorito ? Colors.red : null,
              ),
              onPressed: () async {
                await favoritosController.toggleFavorito(_ponto);
              },
            ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Carrossel de imagens
                  if (_ponto.imagens.isEmpty)
                    Container(
                      height: 200,
                      color: Colors.grey[300],
                      alignment: Alignment.center,
                      child: const Text('Sem imagens disponíveis'),
                    )
                  else
                    SizedBox(
                      height: 220,
                      child: Stack(
                        children: [
                          ScrollConfiguration(
                            behavior: ScrollConfiguration.of(context).copyWith(
                              dragDevices: {
                                PointerDeviceKind.touch,
                                PointerDeviceKind.mouse,
                              },
                            ),
                            child: PageView.builder(
                              controller: _pageController,
                              itemCount: _ponto.imagens.length,
                              onPageChanged: (index) {
                                setState(() => _paginaAtual = index);
                              },
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: _buildImagem(_ponto.imagens[index]),
                                  ),
                                );
                              },
                            ),
                          ),

                          if (_ponto.imagens.length > 1)
                            Positioned(
                              bottom: 8,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  _ponto.imagens.length,
                                  (index) => AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    width: _paginaAtual == index ? 16 : 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: _paginaAtual == index
                                          ? const Color(0xFF1B5E20)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 16),

                  Text(
                    _ponto.nome,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(_ponto.descricao, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 24),

                  if (_ponto.acessibilidade.isNotEmpty) ...[
                    const Text(
                      'Acessibilidade:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _ponto.acessibilidade.map((tipo) {
                        return Chip(
                          avatar: Icon(_iconeAcessibilidade(tipo), size: 20),
                          label: Text(_nomeAcessibilidade(tipo)),
                        );
                      }).toList(),
                    ),
                  ],

                  const SizedBox(height: 24),
                  _SecaoHorarios(pontoId: _ponto.id),

                  const SizedBox(height: 24),
                  _SecaoAtividades(pontoId: _ponto.id),

                  const SizedBox(height: 24),
                  _SecaoEventos(pontoId: _ponto.id),

                  const SizedBox(height: 24),
                  _SecaoAvaliacoes(pontoId: _ponto.id),

                  const SizedBox(height: 24),
                  _SecaoComentarios(pontoId: _ponto.id),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// SEÇÃO HORÁRIOS

class _SecaoHorarios extends StatelessWidget {
  final String pontoId;
  const _SecaoHorarios({required this.pontoId});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<HorariosController>();
    final auth = context.watch<AuthController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Horário de Funcionamento',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (auth.isAdmin)
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                tooltip: 'Adicionar horário',
                onPressed: () => _mostrarFormulario(context),
              ),
          ],
        ),
        if (controller.carregando)
          const Center(child: CircularProgressIndicator())
        else if (controller.horarios.isEmpty)
          const Text(
            'Nenhum horário cadastrado.',
            style: TextStyle(color: Colors.grey),
          )
        else
          ...controller.horarios.map(
            (h) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.access_time, color: Color(0xFF1B5E20)),
              title: Text(h.diaSemana),
              subtitle: Text('${h.abertura} – ${h.fechamento}'),
              trailing: auth.isAdmin
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          onPressed: () =>
                              _mostrarFormulario(context, horario: h),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            size: 20,
                            color: Colors.red,
                          ),
                          onPressed: () async {
                            await context.read<HorariosController>().deletar(
                              pontoId,
                              h.id,
                            );
                          },
                        ),
                      ],
                    )
                  : null,
            ),
          ),
      ],
    );
  }

  void _mostrarFormulario(BuildContext context, {horario}) {
    final diaCtrl = TextEditingController(text: horario?.diaSemana ?? '');
    TimeOfDay abertura = horario != null
        ? TimeOfDay(
            hour: int.parse(horario.abertura.split(':')[0]),
            minute: int.parse(horario.abertura.split(':')[1]),
          )
        : const TimeOfDay(hour: 8, minute: 0);
    TimeOfDay fechamento = horario != null
        ? TimeOfDay(
            hour: int.parse(horario.fechamento.split(':')[0]),
            minute: int.parse(horario.fechamento.split(':')[1]),
          )
        : const TimeOfDay(hour: 18, minute: 0);

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text(horario == null ? 'Adicionar Horário' : 'Editar Horário'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: diaCtrl,
                decoration: const InputDecoration(
                  labelText: 'Dia da semana',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
              ),
              const SizedBox(height: 16),

              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.wb_sunny_outlined,
                  color: Color(0xFF1B5E20),
                ),
                title: const Text('Abertura'),
                subtitle: Text(abertura.format(context)),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: abertura,
                    builder: (context, child) => MediaQuery(
                      data: MediaQuery.of(
                        context,
                      ).copyWith(alwaysUse24HourFormat: true),
                      child: child!,
                    ),
                  );
                  if (picked != null) {
                    setStateDialog(() => abertura = picked);
                  }
                },
              ),

              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.nights_stay_outlined,
                  color: Color(0xFF1B5E20),
                ),
                title: const Text('Fechamento'),
                subtitle: Text(fechamento.format(context)),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: fechamento,
                    builder: (context, child) => MediaQuery(
                      data: MediaQuery.of(
                        context,
                      ).copyWith(alwaysUse24HourFormat: true),
                      child: child!,
                    ),
                  );
                  if (picked != null) {
                    setStateDialog(() => fechamento = picked);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final aberturaStr =
                    '${abertura.hour.toString().padLeft(2, '0')}:${abertura.minute.toString().padLeft(2, '0')}';
                final fechamentoStr =
                    '${fechamento.hour.toString().padLeft(2, '0')}:${fechamento.minute.toString().padLeft(2, '0')}';

                final dados = {
                  'diaSemana': diaCtrl.text.trim(),
                  'abertura': aberturaStr,
                  'fechamento': fechamentoStr,
                };
                final ctrl = context.read<HorariosController>();
                if (horario == null) {
                  await ctrl.adicionar(pontoId, dados);
                } else {
                  await ctrl.atualizar(pontoId, horario.id, dados);
                }
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}

// SEÇÃO ATIVIDADES

class _SecaoAtividades extends StatelessWidget {
  final String pontoId;
  const _SecaoAtividades({required this.pontoId});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AtividadesController>();
    final auth = context.watch<AuthController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Atividades',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (auth.isAdmin)
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                tooltip: 'Adicionar atividade',
                onPressed: () => _mostrarFormulario(context),
              ),
          ],
        ),
        if (controller.carregando)
          const Center(child: CircularProgressIndicator()),

        if (!controller.carregando && controller.atividades.isEmpty)
          const Text(
            'Nenhuma atividade cadastrada.',
            style: TextStyle(color: Colors.grey),
          ),

        if (!controller.carregando && controller.atividades.isNotEmpty)
          ...controller.atividades.map(
            (a) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.local_activity,
                color: Color(0xFF1B5E20),
              ),
              title: Text(a.nome),
              subtitle: Text(a.descricao),
              trailing: auth.isAdmin
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          onPressed: () =>
                              _mostrarFormulario(context, atividade: a),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            size: 20,
                            color: Colors.red,
                          ),
                          onPressed: () async {
                            await context.read<AtividadesController>().deletar(
                              pontoId,
                              a.id,
                            );
                          },
                        ),
                      ],
                    )
                  : null,
            ),
          ),
      ],
    );
  }

  void _mostrarFormulario(BuildContext context, {atividade}) {
    final nomeCtrl = TextEditingController(text: atividade?.nome ?? '');
    final descCtrl = TextEditingController(text: atividade?.descricao ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          atividade == null ? 'Adicionar Atividade' : 'Editar Atividade',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nomeCtrl,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: 'Descrição'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final dados = {
                'nome': nomeCtrl.text.trim(),
                'descricao': descCtrl.text.trim(),
              };
              final ctrl = context.read<AtividadesController>();
              if (atividade == null) {
                await ctrl.adicionar(pontoId, dados);
              } else {
                await ctrl.atualizar(pontoId, atividade.id, dados);
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}

// SEÇÃO EVENTOS

class _SecaoEventos extends StatelessWidget {
  final String pontoId;
  const _SecaoEventos({required this.pontoId});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<EventosController>();
    final auth = context.watch<AuthController>();
    final fmt = DateFormat('dd/MM/yyyy HH:mm', 'pt_BR');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Eventos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (auth.isAdmin)
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                tooltip: 'Adicionar evento',
                onPressed: () => _mostrarFormulario(context),
              ),
          ],
        ),
        if (controller.carregando)
          const Center(child: CircularProgressIndicator()),

        if (!controller.carregando && controller.eventos.isEmpty)
          const Text(
            'Nenhum evento cadastrado.',
            style: TextStyle(color: Colors.grey),
          ),

        if (!controller.carregando && controller.eventos.isNotEmpty)
          ...controller.eventos.map(
            (e) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event, color: Color(0xFF1B5E20)),
              title: Text(e.nome),
              subtitle: Text('${e.descricao}\n${fmt.format(e.data.toLocal())}'),
              isThreeLine: true,
              trailing: auth.isAdmin
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          onPressed: () =>
                              _mostrarFormulario(context, evento: e),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            size: 20,
                            color: Colors.red,
                          ),
                          onPressed: () async {
                            await context.read<EventosController>().deletar(
                              pontoId,
                              e.id,
                            );
                          },
                        ),
                      ],
                    )
                  : null,
            ),
          ),
      ],
    );
  }

  void _mostrarFormulario(BuildContext context, {evento}) {
    final nomeCtrl = TextEditingController(text: evento?.nome ?? '');
    final descCtrl = TextEditingController(text: evento?.descricao ?? '');

    DateTime dataSelecionada = evento?.data.toLocal() ?? DateTime.now();
    TimeOfDay horaSelecionada = evento != null
        ? TimeOfDay.fromDateTime(evento.data.toLocal())
        : const TimeOfDay(hour: 9, minute: 0);

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text(evento == null ? 'Adicionar Evento' : 'Editar Evento'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nomeCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nome',
                    prefixIcon: Icon(Icons.title),
                  ),
                ),
                const SizedBox(height: 8),

                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Descrição',
                    prefixIcon: Icon(Icons.description_outlined),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.calendar_month,
                    color: Color(0xFF1B5E20),
                  ),
                  title: const Text('Data'),
                  subtitle: Text(
                    DateFormat('dd/MM/yyyy').format(dataSelecionada),
                  ),
                  trailing: const Icon(Icons.edit_calendar),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: dataSelecionada,
                      firstDate: DateTime.now().subtract(
                        const Duration(days: 365),
                      ),
                      lastDate: DateTime.now().add(
                        const Duration(days: 365 * 3),
                      ),
                      locale: const Locale('pt', 'BR'),
                    );
                    if (picked != null) {
                      setStateDialog(() => dataSelecionada = picked);
                    }
                  },
                ),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.schedule, color: Color(0xFF1B5E20)),
                  title: const Text('Hora'),
                  subtitle: Text(horaSelecionada.format(context)),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: horaSelecionada,
                      builder: (context, child) => MediaQuery(
                        data: MediaQuery.of(
                          context,
                        ).copyWith(alwaysUse24HourFormat: true),
                        child: child!,
                      ),
                    );
                    if (picked != null) {
                      setStateDialog(() => horaSelecionada = picked);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final dataHora = DateTime(
                  dataSelecionada.year,
                  dataSelecionada.month,
                  dataSelecionada.day,
                  horaSelecionada.hour,
                  horaSelecionada.minute,
                );

                final dados = {
                  'nome': nomeCtrl.text.trim(),
                  'descricao': descCtrl.text.trim(),
                  'data': dataHora.toIso8601String(),
                };
                final ctrl = context.read<EventosController>();
                if (evento == null) {
                  await ctrl.adicionar(pontoId, dados);
                } else {
                  await ctrl.atualizar(pontoId, evento.id, dados);
                }
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}

// SEÇÃO AVALIAÇÕES

class _SecaoAvaliacoes extends StatelessWidget {
  final String pontoId;
  const _SecaoAvaliacoes({required this.pontoId});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AvaliacoesController>();
    final auth = context.watch<AuthController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Avaliações',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        // Média geral
        Row(
          children: [
            Icon(Icons.star_rounded, color: Colors.amber[700], size: 28),
            const SizedBox(width: 4),
            Text(
              controller.media.toStringAsFixed(1),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Text(
              '(${controller.total} ${controller.total == 1 ? 'avaliação' : 'avaliações'})',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),

        if (auth.isLogado) ...[
          const SizedBox(height: 12),
          const Text('Sua avaliação:'),
          const SizedBox(height: 4),
          Row(
            children: List.generate(5, (index) {
              final estrela = index + 1;
              return IconButton(
                icon: Icon(
                  estrela <= (controller.minhaAvaliacao ?? 0)
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  color: Colors.amber[700],
                  size: 32,
                ),
                onPressed: () async {
                  await controller.avaliar(pontoId, estrela);
                },
              );
            }),
          ),
        ],
      ],
    );
  }
}

// SEÇÃO COMENTÁRIOS

class _SecaoComentarios extends StatefulWidget {
  final String pontoId;
  const _SecaoComentarios({required this.pontoId});

  @override
  State<_SecaoComentarios> createState() => _SecaoComentariosState();
}

class _SecaoComentariosState extends State<_SecaoComentarios> {
  final _textoCtrl = TextEditingController();

  @override
  void dispose() {
    _textoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ComentariosController>();
    final auth = context.watch<AuthController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Comentários',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        if (auth.isLogado) ...[
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textoCtrl,
                  decoration: InputDecoration(
                    hintText: 'Escreva um comentário...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  maxLines: 2,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send, color: Color(0xFF1B5E20)),
                onPressed: () async {
                  final texto = _textoCtrl.text.trim();
                  if (texto.isEmpty) return;
                  final sucesso = await controller.adicionar(
                    widget.pontoId,
                    texto,
                  );
                  if (sucesso) _textoCtrl.clear();
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],

        // Lista de comentários
        if (controller.carregando)
          const Center(child: CircularProgressIndicator()),

        if (!controller.carregando && controller.comentarios.isEmpty)
          const Text(
            'Nenhum comentário criado.',
            style: TextStyle(color: Colors.grey),
          ),

        if (!controller.carregando && controller.comentarios.isNotEmpty)
          ...controller.comentarios.map(
            (c) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          c.nomeUsuario,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (auth.isAdmin ||
                            auth.isLogado && c.usuarioId == auth.email)
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              size: 18,
                              color: Colors.red,
                            ),
                            onPressed: () async {
                              await controller.deletar(widget.pontoId, c.id);
                            },
                          ),
                      ],
                    ),
                    Text(c.texto),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat(
                        'dd/MM/yyyy HH:mm',
                      ).format(c.criadoEm.toLocal()),
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
