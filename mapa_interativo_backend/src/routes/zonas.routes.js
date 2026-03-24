const express = require('express');
const router = express.Router();
const zonasController = require('../controllers/zonas.controller');
const authMiddleware = require('../middlewares/auth.middleware');
const adminMiddleware = require('../middlewares/admin.middleware');

router.get('/', zonasController.listarTodas);
router.get('/:id', zonasController.buscarPorId);
router.post('/', authMiddleware, adminMiddleware, zonasController.criar);
router.put('/:id', authMiddleware, adminMiddleware, zonasController.atualizar);
router.delete('/:id', authMiddleware, adminMiddleware, zonasController.deletar);

module.exports = router;