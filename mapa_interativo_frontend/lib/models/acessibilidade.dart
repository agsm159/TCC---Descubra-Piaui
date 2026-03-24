enum Acessibilidade {
  rampa,
  elevador,
  braille,
  audioGuia,
  pisoTatil,
  interpreteLibras,
  outro;

  static Acessibilidade fromString(String valor) {
    return Acessibilidade.values.firstWhere(
      (a) => a.name == valor,
      orElse: () => Acessibilidade.outro,
    );
  }
}