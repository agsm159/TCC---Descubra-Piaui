const express = require('express');
const router = express.Router({ mergeParams: true });
const avaliacoesController = require('../controllers/avaliacoes.controller');
const authMiddleware = require('../middlewares/auth.middleware');

router.get('/', avaliacoesController.listar);
router.get('/minha', authMiddleware, avaliacoesController.minhaAvaliacao);
router.post('/', authMiddleware, avaliacoesController.avaliar);

module.exports = router;