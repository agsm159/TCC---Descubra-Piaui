const atividadesService = require('../services/atividades.service');

module.exports = {
  async listar(req, res) {
    try {
      const atividades = await atividadesService.listarPorPonto(req.params.pontoId);
      return res.json(atividades);
    } catch (error) {
      return res.status(500).json({ erro: error.message });
    }
  },

  async criar(req, res) {
    try {
      const atividade = await atividadesService.criar(req.params.pontoId, req.body);
      return res.status(201).json(atividade);
    } catch (error) {
      return res.status(400).json({ erro: error.message });
    }
  },

  async atualizar(req, res) {
    try {
      const atividade = await atividadesService.atualizar(req.params.id, req.body);
      return res.json(atividade);
    } catch (error) {
      return res.status(400).json({ erro: error.message });
    }
  },

  async deletar(req, res) {
    try {
      await atividadesService.deletar(req.params.id);
      return res.status(204).send();
    } catch (error) {
      return res.status(400).json({ erro: error.message });
    }
  },
};