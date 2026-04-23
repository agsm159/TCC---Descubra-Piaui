import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';
import '../../controllers/pontos_controller.dart';
import '../../controllers/cidades_controller.dart';
import '../../models/ponto_interesse.dart';
import '../../models/cidade.dart';
import '../../models/zona.dart';
import '../../models/acessibilidade.dart';
import '../../core/validators.dart';
import '../../core/theme.dart';
import '../../core/api_service.dart';
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
  double? _previewLat;
  double? _previewLng;

  final _nomeCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _latCtrl = TextEditingController();
  final _longCtrl = TextEditingController();
  final _linkMapaCtrl = TextEditingController();
  final _previewMapController = MapController();

  List<XFile> _imagensSelecionadas = [];
  List<Uint8List> _imagensBytes = [];
  final List<Acessibilidade> _acessibilidadesSelecionadas = [];

  @override
  void initState() {
    super.initState();

    _latCtrl.addListener(_atualizarPreview);
    _longCtrl.addListener(_atualizarPreview);

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
    _latCtrl.removeListener(_atualizarPreview);
    _longCtrl.removeListener(_atualizarPreview);
    _previewMapController.dispose();
    _nomeCtrl.dispose();
    _descCtrl.dispose();
    _latCtrl.dispose();
    _longCtrl.dispose();
    _linkMapaCtrl.dispose();
    super.dispose();
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
        return 'Intérprete de Libras';
      case Acessibilidade.outro:
        return 'Outro';
    }
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

  void _atualizarPreview() {
    final lat = double.tryParse(_latCtrl.text.trim());
    final lng = double.tryParse(_longCtrl.text.trim());
    if (lat != null && lng != null) {
      final jaExibia = _previewLat != null && _previewLng != null;
      setState(() {
        _previewLat = lat;
        _previewLng = lng;
      });
      if (jaExibia) {
        try {
          _previewMapController.move(LatLng(lat, lng), 15);
        } catch (_) {}
      }
    } else {
      setState(() {
        _previewLat = null;
        _previewLng = null;
      });
    }
  }

  // Extrair coordenadas de links do google maps
  Future<void> _extrairCoordenadas() async {
    final link = _linkMapaCtrl.text.trim();
    if (link.isEmpty) return;

    String urlFinal = link;

    if (link.contains('goo.gl') || link.contains('share.google')) {
      try {
        final api = context.read<ApiService>();
        final response = await api.get(
          '/utils/resolver-link',
          params: {'url': link},
        );
        urlFinal = response.data['urlFinal'] ?? link;
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao resolver o link. Verifique sua conexão.'),
            backgroundColor: AppColors.erro,
          ),
        );
        return;
      }
    }

    double? lat;
    double? lng;

    // Formato 1: /maps/search/-5.085,-42.79
    final regexSearch = RegExp(r'maps/search/(-?\d+\.?\d*),\+?(-?\d+\.?\d*)');
    final matchSearch = regexSearch.firstMatch(urlFinal);
    if (matchSearch != null) {
      lat = double.tryParse(matchSearch.group(1)!);
      lng = double.tryParse(matchSearch.group(2)!);
    }

    // Formato 2: @-5.0892,-42.8019
    if (lat == null) {
      final regexAt = RegExp(r'@(-?\d+\.?\d*),(-?\d+\.?\d*)');
      final matchAt = regexAt.firstMatch(urlFinal);
      if (matchAt != null) {
        lat = double.tryParse(matchAt.group(1)!);
        lng = double.tryParse(matchAt.group(2)!);
      }
    }

    // Formato 3: ?q=-5.0892,-42.8019
    if (lat == null) {
      final regexQ = RegExp(r'[?&]q=(-?\d+\.?\d*),(-?\d+\.?\d*)');
      final matchQ = regexQ.firstMatch(urlFinal);
      if (matchQ != null) {
        lat = double.tryParse(matchQ.group(1)!);
        lng = double.tryParse(matchQ.group(2)!);
      }
    }

    // Formato 4: !3d-5.0892!4d-42.8019
    if (lat == null) {
      final regexPlace = RegExp(r'!3d(-?\d+\.?\d*)!4d(-?\d+\.?\d*)');
      final matchPlace = regexPlace.firstMatch(urlFinal);
      if (matchPlace != null) {
        lat = double.tryParse(matchPlace.group(1)!);
        lng = double.tryParse(matchPlace.group(2)!);
      }
    }

    if (!mounted) return;

    if (lat != null && lng != null) {
      setState(() {
        _latCtrl.text = lat.toString();
        _longCtrl.text = lng.toString();
        _linkMapaCtrl.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Coordenadas extraídas com sucesso!'),
          backgroundColor: AppColors.sucesso,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível extrair as coordenadas deste link.'),
          backgroundColor: AppColors.erro,
        ),
      );
    }
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
      Navigator.pop(context);

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
    final isEdicao = widget.pontoParaEditar != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdicao ? 'Editar Ponto' : 'Adicionar Ponto'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Cabeçalho
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              decoration: const BoxDecoration(
                color: AppColors.verdePrincipal,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Text(
                isEdicao
                    ? 'Edite as informações do ponto'
                    : 'Preencha as informações do novo ponto turístico',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.branco.withOpacity(0.9),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Localização
                    _cabecalhoSecao(
                      Icons.location_city_outlined,
                      'Localização',
                    ),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Cidade',
                        prefixIcon: Icon(Icons.location_city_outlined),
                      ),
                      value: _cidadeSelecionada?.id,
                      items: _cidades
                          .map(
                            (c) => DropdownMenuItem(
                              value: c.id,
                              child: Text(c.nome),
                            ),
                          )
                          .toList(),
                      onChanged: _onCidadeChanged,
                      validator: (v) =>
                          v == null ? 'Selecione uma cidade' : null,
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Nova cidade'),
                        onPressed: _mostrarModalAddCidade,
                      ),
                    ),

                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Zona',
                        prefixIcon: Icon(Icons.map_outlined),
                      ),
                      value: _zonaSelecionada?.id,
                      items: _zonas
                          .map(
                            (z) => DropdownMenuItem(
                              value: z.id,
                              child: Text(z.nome),
                            ),
                          )
                          .toList(),
                      onChanged: _onZonaChanged,
                      validator: (v) => v == null ? 'Selecione uma zona' : null,
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Nova zona'),
                        onPressed: _mostrarModalAddZona,
                      ),
                    ),

                    const SizedBox(height: 8),
                    const Divider(),
                    const SizedBox(height: 8),

                    // Informações
                    _cabecalhoSecao(Icons.info_outline, 'Informações'),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _nomeCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nome do ponto',
                        prefixIcon: Icon(Icons.place_outlined),
                      ),
                      validator: Validators.validarTexto,
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _descCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Descrição',
                        prefixIcon: Icon(Icons.description_outlined),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 3,
                      validator: Validators.validarTexto,
                    ),

                    const SizedBox(height: 8),
                    const Divider(),
                    const SizedBox(height: 8),

                    // Coordenadas
                    _cabecalhoSecao(Icons.my_location, 'Coordenadas'),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _linkMapaCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Colar link do Google Maps',
                              prefixIcon: Icon(Icons.link),
                              hintText: 'https://maps.google.com/...',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(
                            Icons.my_location,
                            color: AppColors.verdePrincipal,
                          ),
                          tooltip: 'Extrair coordenadas',
                          onPressed: _extrairCoordenadas,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _latCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Latitude',
                            ),
                            keyboardType: TextInputType.number,
                            validator: Validators.validarCoordenada,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _longCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Longitude',
                            ),
                            keyboardType: TextInputType.number,
                            validator: Validators.validarCoordenada,
                          ),
                        ),
                      ],
                    ),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        icon: const Icon(Icons.my_location, size: 16),
                        label: const Text('Usar localização atual'),
                        onPressed: _usarLocalizacaoAtual,
                      ),
                    ),

                    if (_previewLat != null && _previewLng != null) ...[
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          height: 180,
                          child: FlutterMap(
                            mapController: _previewMapController,
                            options: MapOptions(
                              initialCenter: LatLng(_previewLat!, _previewLng!),
                              initialZoom: 15,
                              interactionOptions: const InteractionOptions(
                                flags: InteractiveFlag.none,
                              ),
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.exemplo.app',
                                tileProvider: CancellableNetworkTileProvider(),
                              ),
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: LatLng(_previewLat!, _previewLng!),
                                    width: 40,
                                    height: 40,
                                    child: const Icon(
                                      Icons.location_on,
                                      size: 40,
                                      color: AppColors.verdePrincipal,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Center(
                        child: Text(
                          'Preview da localização',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.cinzaTexto,
                          ),
                        ),
                      ),
                    ],

                    const Divider(),
                    const SizedBox(height: 8),

                    // Imagens

                    // Imagens
                    _cabecalhoSecao(Icons.photo_library_outlined, 'Imagens'),
                    const SizedBox(height: 12),

                    OutlinedButton.icon(
                      icon: const Icon(Icons.add_photo_alternate_outlined),
                      label: const Text('Selecionar imagens'),
                      onPressed: _selecionarImagens,
                    ),
                    if (_imagensSelecionadas.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _imagensSelecionadas.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.memory(
                                  _imagensBytes[index],
                                  width: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],

                    const SizedBox(height: 8),
                    const Divider(),
                    const SizedBox(height: 8),

                    // Acessibilidades
                    _cabecalhoSecao(Icons.accessibility_new, 'Acessibilidades'),
                    const SizedBox(height: 4),

                    ...Acessibilidade.values.map((ac) {
                      final selecionado = _acessibilidadesSelecionadas.contains(
                        ac,
                      );
                      return CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          _nomeAcessibilidade(ac),
                          style: const TextStyle(fontSize: 14),
                        ),
                        value: selecionado,
                        activeColor: AppColors.verdePrincipal,
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (val) {
                          setState(() {
                            if (val == true) {
                              _acessibilidadesSelecionadas.add(ac);
                            } else {
                              _acessibilidadesSelecionadas.remove(ac);
                            }
                          });
                        },
                      );
                    }),

                    const SizedBox(height: 24),

                    // Botão salvar
                    Center(
                      child: ElevatedButton.icon(
                        icon: Icon(isEdicao ? Icons.save : Icons.add_location),
                        label: Text(
                          isEdicao ? 'Salvar alterações' : 'Adicionar ponto',
                        ),
                        onPressed: _salvar,
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cabecalhoSecao(IconData icone, String titulo) {
    return Row(
      children: [
        Icon(icone, size: 18, color: AppColors.verdePrincipal),
        const SizedBox(width: 8),
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.verdePrincipal,
          ),
        ),
      ],
    );
  }
}
