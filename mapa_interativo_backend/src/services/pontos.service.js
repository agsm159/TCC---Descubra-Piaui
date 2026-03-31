const prisma = require("../prisma/client");

const incluirRelacoes = {
  zona: { include: { cidade: true } },
  acessibilidades: true,
  horarios: { orderBy: { diaSemana: "asc" } },
  atividades: { orderBy: { nome: "asc" } },
  eventos: { orderBy: { data: "asc" } },
};

module.exports = {
  async listarTodos({ cidadeId, zonaId } = {}) {
    return prisma.pontoInteresse.findMany({
      where: {
        zona: cidadeId ? { cidadeId } : undefined,
        zonaId: zonaId || undefined,
      },
      include: incluirRelacoes,
    });
  },

  async buscarPorId(id) {
    return prisma.pontoInteresse.findUnique({
      where: { id },
      include: incluirRelacoes,
    });
  },

  async criar(data) {
    const { acessibilidades, ...dadosPonto } = data;
    return prisma.pontoInteresse.create({
      data: {
        ...dadosPonto,
        acessibilidades: {
          create: acessibilidades?.map((tipo) => ({ tipo })) ?? [],
        },
      },
      include: {
        zona: { include: { cidade: true } },
        acessibilidades: true,
      },
    });
  },

  async atualizar(id, data) {
    const { acessibilidades, ...dadosPonto } = data;

    return prisma.$transaction(async (tx) => {
      const pontoAtualizado = await tx.pontoInteresse.update({
        where: { id },
        data: dadosPonto,
      });

      if (acessibilidades !== undefined) {
        await tx.acessibilidade.deleteMany({ where: { pontoId: id } });

        if (acessibilidades.length > 0) {
          await tx.acessibilidade.createMany({
            data: acessibilidades.map((tipo) => ({ tipo, pontoId: id })),
          });
        }
      }

      return tx.pontoInteresse.findUnique({
        where: { id },
        include: {
          zona: { include: { cidade: true } },
          acessibilidades: true,
        },
      });
    });
  },

  async deletar(id) {
    await prisma.acessibilidade.deleteMany({ where: { pontoId: id } });
    return prisma.pontoInteresse.delete({ where: { id } });
  },
};
