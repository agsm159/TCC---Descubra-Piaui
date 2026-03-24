const express = require('express');
const router = express.Router();
const favoritosController = require('../controllers/favoritos.controller');
const authMiddleware = require('../middlewares/auth.middleware');

// Todas as rotas de favoritos exigem login
router.use(authMiddleware);

router.get('/', favoritosController.listar);
router.post('/:pontoId', favoritosController.adicionar);
router.delete('/:pontoId', favoritosController.remover);
router.get('/verificar/:pontoId', favoritosController.verificar);

module.exports = router;