const prisma = require('../prisma/client');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const crypto = require('crypto');   
const emailService = require('./email.service');

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
    const existente = await prisma.usuario.findUnique({ where: { email } });
    if (existente) throw new Error('Este email já está cadastrado');
    const senhaHash = await bcrypt.hash(senha, 10);
    return prisma.usuario.create({
      data: { email, senha: senhaHash, nome, isAdmin: isAdmin ?? false },
      select: { id: true, email: true, nome: true, isAdmin: true },
    });
  },

  async recuperarSenha(email) {
    const usuario = await prisma.usuario.findUnique({ where: { email } });

    // Sempre retorna sucesso para não revelar se o email existe.
    if (!usuario) {
      return { mensagem: 'Se o email estiver cadastrado, você receberá as instruções.' };
    }

    const token = crypto.randomBytes(32).toString('hex');
    const expiry = new Date(Date.now() + 60 * 60 * 1000); // 1 hora

    await prisma.usuario.update({
      where: { email },
      data: { resetToken: token, resetTokenExp: expiry },
    });

    await emailService.enviarEmailRecuperacao(email, token);

    return { mensagem: 'Se o email estiver cadastrado, você receberá as instruções.' };
  },

  async redefinirSenha(token, novaSenha) {
    const usuario = await prisma.usuario.findFirst({
      where: {
        resetToken: token,
        resetTokenExp: { gt: new Date() },
      },
    });

    if (!usuario) throw new Error('Link inválido ou expirado');

    const senhaHash = await bcrypt.hash(novaSenha, 10);

    await prisma.usuario.update({
      where: { id: usuario.id },
      data: {
        senha: senhaHash,
        resetToken: null,
        resetTokenExp: null,
      },
    });

    return { mensagem: 'Senha redefinida com sucesso' };
  },
};