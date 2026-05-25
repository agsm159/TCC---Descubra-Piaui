const express = require("express");
const router = express.Router();
const authController = require("../controllers/auth.controller");

router.post("/login", authController.login);
router.post("/registrar", authController.registrar);
router.post("/recuperar-senha", authController.recuperarSenha);
router.get("/redefinir-senha", authController.paginaRedefinirSenha);
router.post("/redefinir-senha", authController.redefinirSenha);

module.exports = router;
