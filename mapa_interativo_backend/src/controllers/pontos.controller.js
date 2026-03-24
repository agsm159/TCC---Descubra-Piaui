const pontosService = require('../services/pontos.service');

module.exports = {
  async listarTodos(req, res) {
    try {
      const { cidadeId, zonaId } = req.query;
      const pontos = await pontosService.listarTodos({ cidadeId, zonaId });
      return res.json(pontos);
    } catch (error) {
      return res.status(500).json({ erro: error.message });
    }
  },

  async buscarPorId(req, res) {
    try {
      const ponto = await pontosService.buscarPorId(req.params.id);
      if (!ponto) return res.status(404).json({ erro: 'Ponto não encontrado' });
      return res.json(ponto);
    } catch (error) {
      return res.status(500).json({ erro: error.message });
    }
  },

  async criar(req, res) {
    try {
      const ponto = await pontosService.criar(req.body);
      return res.status(201).json(ponto);
    } catch (error) {
      return res.status(400).json({ erro: error.message });
    }
  },

  async atualizar(req, res) {
    try {
      const ponto = await pontosService.atualizar(req.params.id, req.body);
      return res.json(ponto);
    } catch (error) {
      return res.status(400).json({ erro: error.message });
    }
  },

  async deletar(req, res) {
    try {
      await pontosService.deletar(req.params.id);
      return res.status(204).send();
    } catch (error) {
      return res.status(400).json({ erro: error.message });
    }
  }
};