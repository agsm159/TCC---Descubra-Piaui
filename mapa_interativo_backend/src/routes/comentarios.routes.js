const express = require('express');
const router = express.Router({ mergeParams: true });
const comentariosController = require('../controllers/comentarios.controller');
const authMiddleware = require('../middlewares/auth.middleware');

router.get('/', comentariosController.listar);
router.post('/', authMiddleware, comentariosController.criar);
router.put('/:id', authMiddleware, comentariosController.atualizar);
router.delete('/:id', authMiddleware, comentariosController.deletar);

module.exports = router;