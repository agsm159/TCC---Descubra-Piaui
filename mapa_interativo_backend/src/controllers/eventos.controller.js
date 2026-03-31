const eventosService = require('../services/eventos.service');

module.exports = {
  async listar(req, res) {
    try {
      const eventos = await eventosService.listarPorPonto(req.params.pontoId);
      return res.json(eventos);
    } catch (error) {
      return res.status(500).json({ erro: error.message });
    }
  },

  async criar(req, res) {
    try {
      const evento = await eventosService.criar(req.params.pontoId, req.body);
      return res.status(201).json(evento);
    } catch (error) {
      return res.status(400).json({ erro: error.message });
    }
  },

  async atualizar(req, res) {
    try {
      const evento = await eventosService.atualizar(req.params.id, req.body);
      return res.json(evento);
    } catch (error) {
      return res.status(400).json({ erro: error.message });
    }
  },

  async deletar(req, res) {
    try {
      await eventosService.deletar(req.params.id);
      return res.status(204).send();
    } catch (error) {
      return res.status(400).json({ erro: error.message });
    }
  },
};