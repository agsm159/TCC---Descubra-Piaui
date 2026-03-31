const avaliacoesService = require('../services/avaliacoes.service');

module.exports = {
  async listar(req, res) {
    try {
      const avaliacoes = await avaliacoesService.listarPorPonto(req.params.pontoId);
      const media = await avaliacoesService.mediaAvaliacao(req.params.pontoId);
      return res.json({ avaliacoes, media });
    } catch (error) {
      return res.status(500).json({ erro: error.message });
    }
  },

  async avaliar(req, res) {
    try {
      const { estrelas } = req.body;

      if (!estrelas || estrelas < 1 || estrelas > 5) {
        return res.status(400).json({ erro: 'Avaliação deve ser entre 1 e 5 estrelas' });
      }

      // Verifica se já avaliou
      const jaAvaliou = await avaliacoesService.buscarDoUsuario(
        req.usuario.id,
        req.params.pontoId
      );

      const avaliacao = jaAvaliou
        ? await avaliacoesService.atualizar(req.usuario.id, req.params.pontoId, estrelas)
        : await avaliacoesService.criar(req.usuario.id, req.params.pontoId, estrelas);

      return res.status(jaAvaliou ? 200 : 201).json(avaliacao);
    } catch (error) {
      return res.status(400).json({ erro: error.message });
    }
  },

  async minhaAvaliacao(req, res) {
    try {
      const avaliacao = await avaliacoesService.buscarDoUsuario(
        req.usuario.id,
        req.params.pontoId
      );
      return res.json({ estrelas: avaliacao?.estrelas ?? null });
    } catch (error) {
      return res.status(500).json({ erro: error.message });
    }
  },
};