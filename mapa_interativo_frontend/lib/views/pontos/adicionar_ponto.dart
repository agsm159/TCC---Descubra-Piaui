import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../../controllers/pontos_controller.dart';
import '../../controllers/cidades_controller.dart';
import '../../models/ponto_interesse.dart';
import '../../models/cidade.dart';
import '../../models/zona.dart';
import '../../models/acessibilidade.dart';
import '../../core/validators.dart';
import '../../data/upload_repository.dart';

class AdicionarPonto extends StatefulWidget {
  final PontoInteresse? pontoParaEditar;

  const AdicionarPonto({super.key, this.pontoParaEditar});

  @override
  State<AdicionarPonto> createState() => _AdicionarPontoState();
}

class _AdicionarPontoState extends State<AdicionarPonto> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();

  List<Cidade> _cidades = [];
  List<Zona> _zonas = [];
  Cidade? _cidadeSelecionada;
  Zona? _zonaSelecionada;

  final _nomeCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _latCtrl = TextEditingController();
  final _longCtrl = TextEditingController();

  List<XFile> _imagensSelecionadas = [];
  List<Uint8List> _imagensBytes = [];
  final List<Acessibilidade> _acessibilidadesSelecionadas = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final cidadesController = context.read<CidadesController>();
      await cidadesController.carregarCidades();
      if (!mounted) return;

      final ponto = widget.pontoParaEditar;
      if (ponto != null) {
        _nomeCtrl.text = ponto.nome;
        _descCtrl.text = ponto.descricao;
        _latCtrl.text = ponto.latitude.toString();
        _longCtrl.text = ponto.longitude.toString();

        final zona = cidadesController.buscarZonaPorId(ponto.idZona);
        final cidade = zona != null
            ? cidadesController.buscarCidadePorId(zona.idCidade)
            : null;

        setState(() {
          _cidades = cidadesController.todasCidades;
          _cidadeSelecionada = cidade;
          _zonas = cidade != null
              ? cidadesController.buscarZonasPorCidade(cidade.id)
              : [];
          _zonaSelecionada = zona;
          _acessibilidadesSelecionadas
            ..clear()
            ..addAll(ponto.acessibilidade);
        });
      } else {
        setState(() => _cidades = cidadesController.todasCidades);
      }
    });
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _descCtrl.dispose();
    _latCtrl.dispose();
    _longCtrl.dispose();
    super.dispose();
  }

  Future<void> _mostrarModalAddCidade() async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Adicionar Cidade'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Nome da cidade'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final nome = controller.text.trim();
              if (nome.isNotEmpty) {
                final cidadesController = context.read<CidadesController>();
                await cidadesController.adicionarCidade(nome);
                if (!mounted) return;
                setState(() {
                  _cidades = cidadesController.todasCidades;
                  _cidadeSelecionada = _cidades.last;
                  _zonas = [];
                  _zonaSelecionada = null;
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Future<void> _mostrarModalAddZona() async {
    if (_cidadeSelecionada == null) return;
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Adicionar Zona'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Nome da zona'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final nome = controller.text.trim();
              if (nome.isNotEmpty && _cidadeSelecionada != null) {
                final cidadesController = context.read<CidadesController>();
                await cidadesController.adicionarZona(
                  nome,
                  _cidadeSelecionada!.id,
                );
                if (!mounted) return;
                setState(() {
                  _zonas = cidadesController.buscarZonasPorCidade(
                    _cidadeSelecionada!.id,
                  );
                  _zonaSelecionada = _zonas.isNotEmpty ? _zonas.last : null;
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _onCidadeChanged(String? id) {
    final cidadesController = context.read<CidadesController>();
    setState(() {
      _cidadeSelecionada = _cidades.firstWhere((c) => c.id == id);
      _zonas = cidadesController.buscarZonasPorCidade(id!);
      _zonaSelecionada = null;
    });
  }

  void _onZonaChanged(String? id) {
    setState(() {
      _zonaSelecionada = _zonas.firstWhere((z) => z.id == id);
    });
  }

  Future<void> _selecionarImagens() async {
    final picker = ImagePicker();
    final imgs = await picker.pickMultiImage();
    if (imgs.isEmpty) return;
    final bytesList = await Future.wait(imgs.map((x) => x.readAsBytes()));
    setState(() {
      _imagensSelecionadas = imgs;
      _imagensBytes = bytesList;
    });
  }

  Future<void> _usarLocalizacaoAtual() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Serviço de localização desativado')),
      );
      return;
    }
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.deniedForever) return;
    }
    final pos = await Geolocator.getCurrentPosition();
    _latCtrl.text = pos.latitude.toString();
    _longCtrl.text = pos.longitude.toString();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_cidadeSelecionada == null || _zonaSelecionada == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selecione cidade e zona')));
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final uploadRepository = context.read<UploadRepository>();
      final pontosController = context.read<PontosController>();

      List<String> urlsImagens = widget.pontoParaEditar?.imagens ?? [];

      if (_imagensSelecionadas.isNotEmpty) {
        urlsImagens = [];
        for (int i = 0; i < _imagensSelecionadas.length; i++) {
          final comprimido = await FlutterImageCompress.compressWithList(
            _imagensBytes[i],
            quality: 70,
            minWidth: 1024,
            minHeight: 1024,
          );
          final url = await uploadRepository.uploadImagem(
            comprimido,
            _imagensSelecionadas[i].name,
          );
          urlsImagens.add(url);
        }
      }

      final ponto = PontoInteresse(
        id: widget.pontoParaEditar?.id ?? _uuid.v4(),
        nome: _nomeCtrl.text.trim(),
        descricao: _descCtrl.text.trim(),
        latitude: double.parse(_latCtrl.text.trim()),
        longitude: double.parse(_longCtrl.text.trim()),
        imagens: urlsImagens,
        acessibilidade: _acessibilidadesSelecionadas,
        idZona: _zonaSelecionada!.id,
      );

      final bool sucesso;
      if (widget.pontoParaEditar != null) {
        sucesso = await pontosController.editar(ponto.id, ponto);
      } else {
        sucesso = await pontosController.adicionar(ponto);
      }

      if (!mounted) return;
      Navigator.pop(context); // fecha loading

      if (sucesso) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.pontoParaEditar != null
                  ? 'Ponto atualizado com sucesso'
                  : 'Ponto adicionado com sucesso',
            ),
          ),
        );
        Navigator.pop(context, widget.pontoParaEditar != null ? ponto : null);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(pontosController.erro ?? 'Erro ao salvar ponto'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // fecha loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao fazer upload: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.pontoParaEditar != null ? 'Editar Ponto' : 'Adicionar Ponto',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dropdown Cidade
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Cidade'),
                value: _cidadeSelecionada?.id,
                items: _cidades
                    .map(
                      (c) => DropdownMenuItem(value: c.id, child: Text(c.nome)),
                    )
                    .toList(),
                onChanged: _onCidadeChanged,
                validator: (v) => v == null ? 'Selecione uma cidade' : null,
              ),
              TextButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Adicionar Cidade'),
                onPressed: _mostrarModalAddCidade,
              ),
              const SizedBox(height: 16),

              // Dropdown Zona
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Zona'),
                value: _zonaSelecionada?.id,
                items: _zonas
                    .map(
                      (z) => DropdownMenuItem(value: z.id, child: Text(z.nome)),
                    )
                    .toList(),
                onChanged: _onZonaChanged,
                validator: (v) => v == null ? 'Selecione uma zona' : null,
              ),
              TextButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Adicionar Zona'),
                onPressed: _mostrarModalAddZona,
              ),
              const SizedBox(height: 16),

              // Nome
              TextFormField(
                controller: _nomeCtrl,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: Validators.validarTexto,
              ),
              const SizedBox(height: 12),

              // Descrição
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'Descrição'),
                maxLines: 3,
                validator: Validators.validarTexto,
              ),
              const SizedBox(height: 16),

              // Coordenadas
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latCtrl,
                      decoration: const InputDecoration(labelText: 'Latitude'),
                      keyboardType: TextInputType.number,
                      validator: Validators.validarCoordenada,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _longCtrl,
                      decoration: const InputDecoration(labelText: 'Longitude'),
                      keyboardType: TextInputType.number,
                      validator: Validators.validarCoordenada,
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  icon: const Icon(Icons.my_location),
                  label: const Text('Usar localização atual'),
                  onPressed: _usarLocalizacaoAtual,
                ),
              ),
              const SizedBox(height: 16),

              // Imagens
              FilledButton.icon(
                icon: const Icon(Icons.image),
                label: const Text('Selecionar imagens'),
                onPressed: _selecionarImagens,
              ),
              const SizedBox(height: 12),
              if (_imagensSelecionadas.isNotEmpty)
                SizedBox(
                  height: 160,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _imagensSelecionadas.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(
                            _imagensBytes[index],
                            width: 120,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 24),

              // Acessibilidades
              const Text(
                'Acessibilidades',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              ...Acessibilidade.values.map((ac) {
                return CheckboxListTile(
                  title: Text(ac.name),
                  value: _acessibilidadesSelecionadas.contains(ac),
                  onChanged: (selecionado) {
                    setState(() {
                      if (selecionado == true) {
                        _acessibilidadesSelecionadas.add(ac);
                      } else {
                        _acessibilidadesSelecionadas.remove(ac);
                      }
                    });
                  },
                );
              }),
              const SizedBox(height: 24),

              // Botão Salvar
              Center(
                child: FilledButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Salvar Ponto'),
                  onPressed: _salvar,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
