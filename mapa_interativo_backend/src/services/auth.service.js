const prisma = require("../prisma/client");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const { createClient } = require("@supabase/supabase-js");

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_KEY,
);

module.exports = {
  async login(email, senha) {
    const usuario = await prisma.usuario.findUnique({ where: { email } });
    if (!usuario) throw new Error("Credenciais inválidas");

    const senhaValida = await bcrypt.compare(senha, usuario.senha);
    if (!senhaValida) throw new Error("Credenciais inválidas");

    const token = jwt.sign(
      { id: usuario.id, isAdmin: usuario.isAdmin },
      process.env.JWT_SECRET,
      { expiresIn: "7d" },
    );

    return { token, isAdmin: usuario.isAdmin, nome: usuario.nome };
  },

  async registrar({ email, senha, nome, isAdmin }) {
    const existente = await prisma.usuario.findUnique({ where: { email } });
    if (existente) throw new Error("Este email já está cadastrado");

    const senhaHash = await bcrypt.hash(senha, 10);
    return prisma.usuario.create({
      data: { email, senha: senhaHash, nome, isAdmin: isAdmin ?? false },
      select: { id: true, email: true, nome: true, isAdmin: true },
    });
  },

  async recuperarSenha(email) {
    const { error } = await supabase.auth.resetPasswordForEmail(email, {
      redirectTo: "http://localhost:3000/redefinir-senha",
    });
    if (error) throw new Error(error.message);
    return { mensagem: "Email de recuperação enviado com sucesso" };
  },
};
