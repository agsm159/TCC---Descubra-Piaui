const comentariosService = require('../services/comentarios.service');

module.exports = {
  async listar(req, res) {
    try {
      const comentarios = await comentariosService.listarPorPonto(req.params.pontoId);
      return res.json(comentarios);
    } catch (error) {
      return res.status(500).json({ erro: error.message });
    }
  },

  async criar(req, res) {
    try {
      const { texto } = req.body;
      if (!texto?.trim()) {
        return res.status(400).json({ erro: 'O comentário não pode ser vazio' });
      }

      const comentario = await comentariosService.criar(
        req.usuario.id,
        req.params.pontoId,
        texto.trim()
      );
      return res.status(201).json(comentario);
    } catch (error) {
      return res.status(400).json({ erro: error.message });
    }
  },

  async atualizar(req, res) {
    try {
      const { texto } = req.body;
      if (!texto?.trim()) {
        return res.status(400).json({ erro: 'O comentário não pode ser vazio' });
      }

      const comentario = await comentariosService.atualizar(
        req.params.id,
        req.usuario.id,
        texto.trim()
      );
      return res.json(comentario);
    } catch (error) {
      return res.status(400).json({ erro: error.message });
    }
  },

  async deletar(req, res) {
    try {
      await comentariosService.deletar(
        req.params.id,
        req.usuario.id,
        req.usuario.isAdmin
      );
      return res.status(204).send();
    } catch (error) {
      return res.status(400).json({ erro: error.message });
    }
  },
};