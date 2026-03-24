import '../../models/ponto_interesse.dart';
import '../../models/acessibilidade.dart';
import '../../models/zona.dart';


final List<Zona> zonasMock = [
  Zona(id: 'z1', nome: 'Zona Norte', idCidade: 'c1'),
  Zona(id: 'z2', nome: 'Zona Sul',   idCidade: 'c1'),
  Zona(id: 'z3', nome: 'Zona Leste', idCidade: 'c2'),
  Zona(id: 'z4', nome: 'Zona Oeste', idCidade: 'c2'),

];
final pontosMock = [
  PontoInteresse(
    id: 'p1',
    nome: 'Palácio de Karnak',
    descricao: 'Sede do governo estadual, construção histórica localizada em Teresina.',
    latitude: -5.0909,
    longitude: -42.8016,
    imagens: [
      'https://upload.wikimedia.org/wikipedia/commons/thumb/6/67/Karnak_Piau%C3%AD_palace.JPG/250px-Karnak_Piau%C3%AD_palace.JPG'
    ],
    acessibilidade: [
      Acessibilidade.rampa,
      Acessibilidade.braille,
    ],
    idZona: 'z2'
  ),
  PontoInteresse(
    id: 'p2',
    nome: 'Encontro dos Rios',
    descricao: 'Ponto turístico natural onde os rios Parnaíba e Poti se encontram.',
    latitude: -5.0571,
    longitude: -42.7571,
    imagens: [
      'https://upload.wikimedia.org/wikipedia/commons/thumb/4/45/Cabe%C3%A7a_de_cuia.jpg/250px-Cabe%C3%A7a_de_cuia.jpg'
    ],
    acessibilidade: [
      Acessibilidade.pisoTatil,
      Acessibilidade.elevador,
      Acessibilidade.interpreteLibras
    ],
    idZona: 'z4'
  ),
  PontoInteresse(
    id: 'p3',
    nome: 'Museu do Piauí',
    descricao: 'Museu histórico com acervo cultural do estado...',
    latitude: -5.0915,
    longitude: -42.8050,
    imagens: [
      'assets/images/museo.jpg', 'assets/images/museo2.jpg'
      ],
    acessibilidade: [
      Acessibilidade.braille,
      Acessibilidade.interpreteLibras,
    ],
    idZona: 'z3'
  ),
  PontoInteresse(
    id: 'p4',
    nome: 'Serra da Capivara',
    descricao: 'Parque nacional com sítios arqueológicos e pinturas rupestres.',
    latitude: -8.8391,
    longitude: -42.5580,
    imagens: [
      'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a1/Pedra_Furada_-_Serra_da_Capivara_I.jpg/330px-Pedra_Furada_-_Serra_da_Capivara_I.jpg',
      'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9c/SERRA_DA_CAPIVARA03.jpg/250px-SERRA_DA_CAPIVARA03.jpg'
    ],
    acessibilidade: [],
    idZona: 'z1'
  ),
];
