const prisma = require('../prisma/client');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

module.exports = {
  async login(email, senha) {
    const usuario = await prisma.usuario.findUnique({ where: { email } });
    if (!usuario) throw new Error('Credenciais inválidas');

    const senhaValida = await bcrypt.compare(senha, usuario.senha);
    if (!senhaValida) throw new Error('Credenciais inválidas');

    const token = jwt.sign(
      { id: usuario.id, isAdmin: usuario.isAdmin },
      process.env.JWT_SECRET,
      { expiresIn: '7d' }
    );

    return { token, isAdmin: usuario.isAdmin, nome: usuario.nome };
  },

  async registrar({ email, senha, nome, isAdmin }) {
    const senhaHash = await bcrypt.hash(senha, 10);
    return prisma.usuario.create({
      data: { email, senha: senhaHash, nome, isAdmin: isAdmin ?? false },
      select: { id: true, email: true, nome: true, isAdmin: true }
    });
  }
};