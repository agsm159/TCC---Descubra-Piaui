class Evento {
  final String id;
  final String nome;
  final String descricao;
  final DateTime data;
  final String pontoId;

  Evento({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.data,
    required this.pontoId,
  });

  factory Evento.fromJson(Map<String, dynamic> json) {
    return Evento(
      id: json['id'],
      nome: json['nome'],
      descricao: json['descricao'],
      data: DateTime.parse(json['data']),
      pontoId: json['pontoId'],
    );
  }

  Map<String, dynamic> toJson() => {
    'nome': nome,
    'descricao': descricao,
    'data': data.toIso8601String(),
  };
}