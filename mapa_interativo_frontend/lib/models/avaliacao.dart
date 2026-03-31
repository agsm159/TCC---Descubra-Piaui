class Avaliacao {
  final String id;
  final int estrelas;
  final String usuarioId;
  final String nomeUsuario;
  final String pontoId;
  final DateTime criadoEm;

  Avaliacao({
    required this.id,
    required this.estrelas,
    required this.usuarioId,
    required this.nomeUsuario,
    required this.pontoId,
    required this.criadoEm,
  });

  factory Avaliacao.fromJson(Map<String, dynamic> json) {
    return Avaliacao(
      id: json['id'],
      estrelas: json['estrelas'],
      usuarioId: json['usuarioId'],
      nomeUsuario: json['usuario']?['nome'] ?? 'Usuário',
      pontoId: json['pontoId'],
      criadoEm: DateTime.parse(json['criadoEm']),
    );
  }
}