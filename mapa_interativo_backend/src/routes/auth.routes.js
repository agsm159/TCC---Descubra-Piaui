const express = require('express');
const router = express.Router();
const authController = require('../controllers/auth.controller');

router.post('/login', authController.login);
router.post('/registrar', authController.registrar);
router.post('/recuperar-senha', authController.recuperarSenha);

module.exports = router;