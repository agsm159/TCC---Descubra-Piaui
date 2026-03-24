class Zona {
  final String id;
  final String nome;
  final String idCidade;

  Zona({
    required this.id,
    required this.nome,
    required this.idCidade,
  });

  factory Zona.fromJson(Map<String, dynamic> json) {
    return Zona(
      id: json['id'],
      nome: json['nome'],
      idCidade: json['cidadeId'],
    );
  }

  Map<String, dynamic> toJson() => {
    'nome': nome,
    'cidadeId': idCidade,
  };
}