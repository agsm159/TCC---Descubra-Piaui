const authService = require('../services/auth.service');

module.exports = {
  async login(req, res) {
    try {
      const { email, senha } = req.body;
      const resultado = await authService.login(email, senha);
      return res.json(resultado);
    } catch (error) {
      return res.status(401).json({ erro: error.message });
    }
  },

  async registrar(req, res) {
    try {
      const usuario = await authService.registrar(req.body);
      return res.status(201).json(usuario);
    } catch (error) {
      return res.status(400).json({ erro: error.message });
    }
  }
};