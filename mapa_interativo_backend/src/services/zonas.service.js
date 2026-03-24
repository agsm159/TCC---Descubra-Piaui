const prisma = require('../prisma/client');

module.exports = {
  async listarTodas(cidadeId) {
    return prisma.zona.findMany({
      where: cidadeId ? { cidadeId } : undefined,
      include: { cidade: true }
    });
  },

  async buscarPorId(id) {
    return prisma.zona.findUnique({
      where: { id },
      include: { cidade: true }
    });
  },

  async criar({ nome, cidadeId }) {
    return prisma.zona.create({
      data: { nome, cidadeId },
      include: { cidade: true }
    });
  },

  async atualizar(id, { nome }) {
    return prisma.zona.update({
      where: { id },
      data: { nome },
      include: { cidade: true }
    });
  },

  async deletar(id) {
    return prisma.zona.delete({
      where: { id }
    });
  }
};