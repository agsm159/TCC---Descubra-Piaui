const prisma = require('../prisma/client');

module.exports = {
  async listarPorPonto(pontoId) {
    return prisma.evento.findMany({
      where: { pontoId },
      orderBy: { data: 'asc' },
    });
  },

  async criar(pontoId, dados) {
    return prisma.evento.create({
      data: {
        ...dados,
        data: new Date(dados.data),
        pontoId,
      },
    });
  },

  async atualizar(id, dados) {
    return prisma.evento.update({
      where: { id },
      data: {
        ...dados,
        ...(dados.data && { data: new Date(dados.data) }),
      },
    });
  },

  async deletar(id) {
    return prisma.evento.delete({
      where: { id },
    });
  },
};