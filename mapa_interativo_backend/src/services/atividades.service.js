const prisma = require('../prisma/client');

module.exports = {
  async listarPorPonto(pontoId) {
    return prisma.atividade.findMany({
      where: { pontoId },
      orderBy: { nome: 'asc' },
    });
  },

  async criar(pontoId, dados) {
    return prisma.atividade.create({
      data: { ...dados, pontoId },
    });
  },

  async atualizar(id, dados) {
    return prisma.atividade.update({
      where: { id },
      data: dados,
    });
  },

  async deletar(id) {
    return prisma.atividade.delete({
      where: { id },
    });
  },
};