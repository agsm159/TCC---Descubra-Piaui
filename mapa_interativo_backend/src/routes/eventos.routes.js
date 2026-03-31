const express = require('express');
const router = express.Router({ mergeParams: true });
const eventosController = require('../controllers/eventos.controller');
const authMiddleware = require('../middlewares/auth.middleware');
const adminMiddleware = require('../middlewares/admin.middleware');

router.get('/', eventosController.listar);
router.post('/', authMiddleware, adminMiddleware, eventosController.criar);
router.put('/:id', authMiddleware, adminMiddleware, eventosController.atualizar);
router.delete('/:id', authMiddleware, adminMiddleware, eventosController.deletar);

module.exports = router;