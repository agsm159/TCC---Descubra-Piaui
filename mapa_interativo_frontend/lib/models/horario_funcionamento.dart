class HorarioFuncionamento {
  final String id;
  final String diaSemana;
  final String abertura;
  final String fechamento;
  final String pontoId;

  HorarioFuncionamento({
    required this.id,
    required this.diaSemana,
    required this.abertura,
    required this.fechamento,
    required this.pontoId,
  });

  factory HorarioFuncionamento.fromJson(Map<String, dynamic> json) {
    return HorarioFuncionamento(
      id: json['id'],
      diaSemana: json['diaSemana'],
      abertura: json['abertura'],
      fechamento: json['fechamento'],
      pontoId: json['pontoId'],
    );
  }

  Map<String, dynamic> toJson() => {
    'diaSemana': diaSemana,
    'abertura': abertura,
    'fechamento': fechamento,
  };
}