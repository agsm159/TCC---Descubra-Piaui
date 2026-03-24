import '../../models/cidade.dart';
import '../../models/zona.dart';

// ✅ Lista de cidades com zonas ajustadas com idCidade obrigatório
final List<Cidade> cidadesMock = [
  Cidade(
    id: 'teresina',
    nome: 'Teresina',
    zonas: [
      Zona(id: 'centro_the', nome: 'Centro', idCidade: 'teresina'),
      Zona(id: 'leste_the', nome: 'Zona Leste', idCidade: 'teresina'),
      Zona(id: 'sul_the', nome: 'Zona Sul', idCidade: 'teresina'),
      Zona(id: 'norte_the', nome: 'Zona Norte', idCidade: 'teresina'),
    ],
  ),
  Cidade(
    id: 'parnaiba',
    nome: 'Parnaíba',
    zonas: [
      Zona(id: 'centro_par', nome: 'Centro', idCidade: 'parnaiba'),
      Zona(id: 'bairro_pindorama', nome: 'Pindorama', idCidade: 'parnaiba'),
      Zona(id: 'bairro_ceara', nome: 'Ceará', idCidade: 'parnaiba'),
    ],
  ),
  Cidade(
    id: 'oeiras',
    nome: 'Oeiras',
    zonas: [
      Zona(id: 'centro', nome: 'Centro Histórico', idCidade: 'oeiras'),
      Zona(id: 'bairro_rosario', nome: 'Rosário', idCidade: 'oeiras'),
    ],
  ),
  Cidade(
    id: 'sao_raimundo',
    nome: 'São Raimundo Nonato',
    zonas: [
      Zona(id: 'centro_srn', nome: 'Centro', idCidade: 'sao_raimundo'),
      Zona(id: 'serra_capivara', nome: 'Serra da Capivara', idCidade: 'sao_raimundo'),
    ],
  ),
];
