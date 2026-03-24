const cidadesService = require('../services/cidades.service');

module.exports = {
  async listarTodas(req, res) {
    try {
      const cidades = await cidadesService.listarTodas();
      return res.json(cidades);
    } catch (error) {
      return res.status(500).json({ erro: error.message });
    }
  },

  async buscarPorId(req, res) {
    try {
      const cidade = await cidadesService.buscarPorId(req.params.id);
      if (!cidade) return res.status(404).json({ erro: 'Cidade não encontrada' });
      return res.json(cidade);
    } catch (error) {
      return res.status(500).json({ erro: error.message });
    }
  },

  async criar(req, res) {
    try {
      const cidade = await cidadesService.criar(req.body);
      return res.status(201).json(cidade);
    } catch (error) {
      return res.status(400).json({ erro: error.message });
    }
  },

  async atualizar(req, res) {
    try {
      const cidade = await cidadesService.atualizar(req.params.id, req.body);
      return res.json(cidade);
    } catch (error) {
      return res.status(400).json({ erro: error.message });
    }
  },

  async deletar(req, res) {
    try {
      await cidadesService.deletar(req.params.id);
      return res.status(204).send();
    } catch (error) {
      return res.status(400).json({ erro: error.message });
    }
  }
};