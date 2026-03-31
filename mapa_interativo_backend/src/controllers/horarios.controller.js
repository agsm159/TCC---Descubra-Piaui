const horariosService = require('../services/horarios.service');

module.exports = {
  async listar(req, res) {
    try {
      const horarios = await horariosService.listarPorPonto(req.params.pontoId);
      return res.json(horarios);
    } catch (error) {
      return res.status(500).json({ erro: error.message });
    }
  },

  async criar(req, res) {
    try {
      const horario = await horariosService.criar(req.params.pontoId, req.body);
      return res.status(201).json(horario);
    } catch (error) {
      return res.status(400).json({ erro: error.message });
    }
  },

  async atualizar(req, res) {
    try {
      const horario = await horariosService.atualizar(req.params.id, req.body);
      return res.json(horario);
    } catch (error) {
      return res.status(400).json({ erro: error.message });
    }
  },

  async deletar(req, res) {
    try {
      await horariosService.deletar(req.params.id);
      return res.status(204).send();
    } catch (error) {
      return res.status(400).json({ erro: error.message });
    }
  },
};