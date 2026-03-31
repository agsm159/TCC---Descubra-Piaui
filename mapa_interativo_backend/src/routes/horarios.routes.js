const express = require('express');
const router = express.Router({ mergeParams: true });
const horariosController = require('../controllers/horarios.controller');
const authMiddleware = require('../middlewares/auth.middleware');
const adminMiddleware = require('../middlewares/admin.middleware');

router.get('/', horariosController.listar);
router.post('/', authMiddleware, adminMiddleware, horariosController.criar);
router.put('/:id', authMiddleware, adminMiddleware, horariosController.atualizar);
router.delete('/:id', authMiddleware, adminMiddleware, horariosController.deletar);

module.exports = router;