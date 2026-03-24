import 'zona.dart';

class Cidade {
  final String id;
  final String nome;
  final List<Zona> zonas;

  Cidade({
    required this.id,
    required this.nome,
    required this.zonas,
  });

  factory Cidade.fromJson(Map<String, dynamic> json) {
    return Cidade(
      id: json['id'],
      nome: json['nome'],
      zonas: (json['zonas'] as List?)
          ?.map((z) => Zona.fromJson(z))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
    'nome': nome,
  };
}