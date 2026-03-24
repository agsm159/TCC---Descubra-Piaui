const prisma = require('../prisma/client');

module.exports = {
  async listarFavoritos(usuarioId) {
    return prisma.favorito.findMany({
      where: { usuarioId },
      include: {
        ponto: {
          include: {
            zona: { include: { cidade: true } },
            acessibilidades: true,
          }
        }
      }
    });
  },

  async adicionarFavorito(usuarioId, pontoId) {
    return prisma.favorito.create({
      data: { usuarioId, pontoId },
      include: { ponto: true }
    });
  },

  async removerFavorito(usuarioId, pontoId) {
    return prisma.favorito.deleteMany({
      where: { usuarioId, pontoId }
    });
  },

  async isFavorito(usuarioId, pontoId) {
    const favorito = await prisma.favorito.findFirst({
      where: { usuarioId, pontoId }
    });
    return favorito !== null;
  }
};