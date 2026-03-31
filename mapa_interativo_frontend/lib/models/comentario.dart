class Comentario {
  final String id;
  final String texto;
  final String usuarioId;
  final String nomeUsuario;
  final String pontoId;
  final DateTime criadoEm;

  Comentario({
    required this.id,
    required this.texto,
    required this.usuarioId,
    required this.nomeUsuario,
    required this.pontoId,
    required this.criadoEm,
  });

  factory Comentario.fromJson(Map<String, dynamic> json) {
    return Comentario(
      id: json['id'],
      texto: json['texto'],
      usuarioId: json['usuarioId'],
      nomeUsuario: json['usuario']?['nome'] ?? 'Usuário',
      pontoId: json['pontoId'],
      criadoEm: DateTime.parse(json['criadoEm']),
    );
  }
}