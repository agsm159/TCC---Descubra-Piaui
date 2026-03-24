const zonasService = require('../services/zonas.service');

module.exports = {
  async listarTodas(req, res) {
    try {
      const { cidadeId } = req.query;
      const zonas = await zonasService.listarTodas(cidadeId);
      return res.json(zonas);
    } catch (error) {
      return res.status(500).json({ erro: error.message });
    }
  },

  async buscarPorId(req, res) {
    try {
      const zona = await zonasService.buscarPorId(req.params.id);
      if (!zona) return res.status(404).json({ erro: 'Zona não encontrada' });
      return res.json(zona);
    } catch (error) {
      return res.status(500).json({ erro: error.message });
    }
  },

  async criar(req, res) {
    try {
      const zona = await zonasService.criar(req.body);
      return res.status(201).json(zona);
    } catch (error) {
      return res.status(400).json({ erro: error.message });
    }
  },

  async atualizar(req, res) {
    try {
      const zona = await zonasService.atualizar(req.params.id, req.body);
      return res.json(zona);
    } catch (error) {
      return res.status(400).json({ erro: error.message });
    }
  },

  async deletar(req, res) {
    try {
      await zonasService.deletar(req.params.id);
      return res.status(204).send();
    } catch (error) {
      return res.status(400).json({ erro: error.message });
    }
  }
};