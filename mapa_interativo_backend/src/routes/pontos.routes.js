const express = require('express');
const router = express.Router();
const pontosController = require('../controllers/pontos.controller');
const authMiddleware = require('../middlewares/auth.middleware');
const adminMiddleware = require('../middlewares/admin.middleware');

router.get('/', pontosController.listarTodos);
router.get('/:id', pontosController.buscarPorId);
router.post('/', authMiddleware, adminMiddleware, pontosController.criar);
router.put('/:id', authMiddleware, adminMiddleware, pontosController.atualizar);
router.delete('/:id', authMiddleware, adminMiddleware, pontosController.deletar);

module.exports = router;