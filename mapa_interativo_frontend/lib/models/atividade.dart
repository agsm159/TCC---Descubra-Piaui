class Atividade {
  final String id;
  final String nome;
  final String descricao;
  final String pontoId;

  Atividade({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.pontoId,
  });

  factory Atividade.fromJson(Map<String, dynamic> json) {
    return Atividade(
      id: json['id'],
      nome: json['nome'],
      descricao: json['descricao'],
      pontoId: json['pontoId'],
    );
  }

  Map<String, dynamic> toJson() => {
    'nome': nome,
    'descricao': descricao,
  };
}