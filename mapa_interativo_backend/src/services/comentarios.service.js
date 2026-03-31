const prisma = require('../prisma/client');

module.exports = {
  async listarPorPonto(pontoId) {
    return prisma.comentario.findMany({
      where: { pontoId },
      include: {
        usuario: {
          select: { id: true, nome: true },
        },
      },
      orderBy: { criadoEm: 'desc' },
    });
  },

  async criar(usuarioId, pontoId, texto) {
    return prisma.comentario.create({
      data: { usuarioId, pontoId, texto },
      include: {
        usuario: {
          select: { id: true, nome: true },
        },
      },
    });
  },

  async atualizar(id, usuarioId, texto) {
    // Verifica se o comentário pertence ao usuário
    const comentario = await prisma.comentario.findUnique({ where: { id } });
    if (!comentario) throw new Error('Comentário não encontrado');
    if (comentario.usuarioId !== usuarioId) throw new Error('Sem permissão para editar este comentário');

    return prisma.comentario.update({
      where: { id },
      data: { texto },
      include: {
        usuario: {
          select: { id: true, nome: true },
        },
      },
    });
  },

  async deletar(id, usuarioId, isAdmin) {
    const comentario = await prisma.comentario.findUnique({ where: { id } });
    if (!comentario) throw new Error('Comentário não encontrado');

    // Admin pode deletar qualquer comentário, usuário só o próprio
    if (!isAdmin && comentario.usuarioId !== usuarioId) {
      throw new Error('Sem permissão para deletar este comentário');
    }

    return prisma.comentario.delete({ where: { id } });
  },
};