import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:mapa_interativo/views/pontos/adicionar_ponto.dart';
import '../../controllers/pontos_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/favoritos_controller.dart';
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
      Navigator.pop(context); // volta para a tela anterior
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
          // Botões de Admin
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
                                    child: _buildImagem(
                                      _ponto.imagens[index],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          // Indicadores de página
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
                  Text(
                    _ponto.descricao,
                    style: const TextStyle(fontSize: 16),
                  ),
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
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
