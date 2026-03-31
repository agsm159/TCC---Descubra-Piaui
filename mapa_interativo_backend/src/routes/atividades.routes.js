const express = require('express');
const router = express.Router({ mergeParams: true });
const atividadesController = require('../controllers/atividades.controller');
const authMiddleware = require('../middlewares/auth.middleware');
const adminMiddleware = require('../middlewares/admin.middleware');

router.get('/', atividadesController.listar);
router.post('/', authMiddleware, adminMiddleware, atividadesController.criar);
router.put('/:id', authMiddleware, adminMiddleware, atividadesController.atualizar);
router.delete('/:id', authMiddleware, adminMiddleware, atividadesController.deletar);

module.exports = router;