const prisma = require('../prisma/client');

module.exports = {
  async listarPorPonto(pontoId) {
    return prisma.avaliacao.findMany({
      where: { pontoId },
      include: {
        usuario: {
          select: { id: true, nome: true },
        },
      },
      orderBy: { criadoEm: 'desc' },
    });
  },

  async mediaAvaliacao(pontoId) {
    const resultado = await prisma.avaliacao.aggregate({
      where: { pontoId },
      _avg: { estrelas: true },
      _count: { estrelas: true },
    });
    return {
      media: resultado._avg.estrelas ?? 0,
      total: resultado._count.estrelas,
    };
  },

  async criar(usuarioId, pontoId, estrelas) {
    return prisma.avaliacao.create({
      data: { usuarioId, pontoId, estrelas },
      include: {
        usuario: {
          select: { id: true, nome: true },
        },
      },
    });
  },

  async atualizar(usuarioId, pontoId, estrelas) {
    return prisma.avaliacao.update({
      where: {
        usuarioId_pontoId: { usuarioId, pontoId },
      },
      data: { estrelas },
      include: {
        usuario: {
          select: { id: true, nome: true },
        },
      },
    });
  },

  async buscarDoUsuario(usuarioId, pontoId) {
    return prisma.avaliacao.findUnique({
      where: {
        usuarioId_pontoId: { usuarioId, pontoId },
      },
    });
  },
};