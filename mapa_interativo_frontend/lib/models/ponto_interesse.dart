import 'acessibilidade.dart';
import 'horario_funcionamento.dart';
import 'atividade.dart';
import 'evento.dart';

class PontoInteresse {
  final String id;
  final String nome;
  final String descricao;
  final double latitude;
  final double longitude;
  final List<String> imagens;
  final List<Acessibilidade> acessibilidade;
  final String idZona;
  final List<HorarioFuncionamento> horarios;
  final List<Atividade> atividades;
  final List<Evento> eventos;

  PontoInteresse({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.latitude,
    required this.longitude,
    required this.imagens,
    required this.acessibilidade,
    required this.idZona,
    this.horarios = const [],
    this.atividades = const [],
    this.eventos = const [],
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
      acessibilidade:
          (json['acessibilidades'] as List?)
            ?.map((a) => Acessibilidade.fromString(a['tipo'] as String)).toList() ?? [],
      horarios:
          (json['horarios'] as List?)
            ?.map((h) => HorarioFuncionamento.fromJson(h)).toList() ?? [],
      atividades:
          (json['atividades'] as List?)
            ?.map((a) => Atividade.fromJson(a)).toList() ?? [],
      eventos:
          (json['eventos'] as List?)
            ?.map((e) => Evento.fromJson(e)).toList() ?? [],
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
