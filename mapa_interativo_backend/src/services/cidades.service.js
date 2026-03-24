const prisma = require('../prisma/client');

module.exports = {
  async listarTodas() {
    return prisma.cidade.findMany({
      include: { zonas: true }
    });
  },

  async buscarPorId(id) {
    return prisma.cidade.findUnique({
      where: { id },
      include: { zonas: true }
    });
  },

  async criar({ nome }) {
    return prisma.cidade.create({
      data: { nome }
    });
  },

  async atualizar(id, { nome }) {
    return prisma.cidade.update({
      where: { id },
      data: { nome }
    });
  },

  async deletar(id) {
    return prisma.cidade.delete({
      where: { id }
    });
  }
};