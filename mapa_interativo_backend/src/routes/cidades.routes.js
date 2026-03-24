const express = require('express');
const router = express.Router();
const cidadesController = require('../controllers/cidades.controller');
const authMiddleware = require('../middlewares/auth.middleware');
const adminMiddleware = require('../middlewares/admin.middleware');

router.get('/', cidadesController.listarTodas);
router.get('/:id', cidadesController.buscarPorId);
router.post('/', authMiddleware, adminMiddleware, cidadesController.criar);
router.put('/:id', authMiddleware, adminMiddleware, cidadesController.atualizar);
router.delete('/:id', authMiddleware, adminMiddleware, cidadesController.deletar);

module.exports = router;