const favoritosService = require('../services/favoritos.service');

module.exports = {
  async listar(req, res) {
    try {
      const favoritos = await favoritosService.listarFavoritos(req.usuario.id);
      return res.json(favoritos);
    } catch (error) {
      return res.status(500).json({ erro: error.message });
    }
  },

  async adicionar(req, res) {
    try {
      const favorito = await favoritosService.adicionarFavorito(
        req.usuario.id,
        req.params.pontoId
      );
      return res.status(201).json(favorito);
    } catch (error) {
      return res.status(400).json({ erro: error.message });
    }
  },

  async remover(req, res) {
    try {
      await favoritosService.removerFavorito(
        req.usuario.id,
        req.params.pontoId
      );
      return res.status(204).send();
    } catch (error) {
      return res.status(400).json({ erro: error.message });
    }
  },

  async verificar(req, res) {
    try {
      const isFavorito = await favoritosService.isFavorito(
        req.usuario.id,
        req.params.pontoId
      );
      return res.json({ isFavorito });
    } catch (error) {
      return res.status(500).json({ erro: error.message });
    }
  }
};