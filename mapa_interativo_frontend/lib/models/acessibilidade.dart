enum Acessibilidade {
  rampa,
  elevador,
  banheirosAdaptados,
  pisoTatil,
  braille,
  audioGuia,
  interpreteLibras,
  estacionamentoReservado;

  static Acessibilidade fromString(String valor) {
    return Acessibilidade.values.firstWhere(
      (a) => a.name == valor,
    );
  }
}