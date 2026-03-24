import 'acessibilidade.dart';

class PontoInteresse {
  final String id;
  final String nome;
  final String descricao;
  final double latitude;
  final double longitude;
  final List<String> imagens;
  final List<Acessibilidade> acessibilidade;
  final String idZona; 

  PontoInteresse({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.latitude,
    required this.longitude,
    required this.imagens,
    required this.acessibilidade,
    required this.idZona,
  });

  factory PontoInteresse.fromJson(Map<String, dynamic> json) {
    return PontoInteresse(
      id: json['id'],
      nome: json['nome'],
      descricao: json['descricao'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      imagens: List<String>.from(json['imagens'] ?? []),
      idZona: json['zonaId'],
      acessibilidade: (json['acessibilidades'] as List?)
          ?.map((a) => Acessibilidade.fromString(a['tipo'] as String))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
    'nome': nome,
    'descricao': descricao,
    'latitude': latitude,
    'longitude': longitude,
    'imagens': imagens,
    'zonaId': idZona,
    'acessibilidades': acessibilidade.map((a) => a.name).toList(),
  };
}