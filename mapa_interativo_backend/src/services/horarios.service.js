const prisma = require('../prisma/client');

module.exports = {
  async listarPorPonto(pontoId) {
    return prisma.horarioFuncionamento.findMany({
      where: { pontoId },
      orderBy: { diaSemana: 'asc' },
    });
  },

  async criar(pontoId, dados) {
    return prisma.horarioFuncionamento.create({
      data: { ...dados, pontoId },
    });
  },

  async atualizar(id, dados) {
    return prisma.horarioFuncionamento.update({
      where: { id },
      data: dados,
    });
  },

  async deletar(id) {
    return prisma.horarioFuncionamento.delete({
      where: { id },
    });
  },
};