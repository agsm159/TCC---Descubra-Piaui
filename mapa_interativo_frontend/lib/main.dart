import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/api_service.dart';
import 'controllers/auth_controller.dart';
import 'controllers/pontos_controller.dart';
import 'controllers/cidades_controller.dart';
import 'controllers/favoritos_controller.dart';
import 'controllers/horarios_controller.dart';
import 'controllers/atividades_controller.dart';
import 'controllers/eventos_controller.dart';
import 'controllers/avaliacoes_controller.dart';
import 'controllers/comentarios_controller.dart';
import 'data/pontos_repository.dart';
import 'data/cidades_repository.dart';
import 'data/upload_repository.dart';
import 'data/favoritos_repository.dart';
import 'data/horarios_repository.dart';
import 'data/atividades_repository.dart';
import 'data/eventos_repository.dart';
import 'data/avaliacoes_repository.dart';
import 'data/comentarios_repository.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('pt_BR', null);

  final apiService = ApiService();

  runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>(create: (_) => apiService),

        ChangeNotifierProvider(create: (_) => AuthController(apiService)),

        ChangeNotifierProvider(
          create: (_) => CidadesController(CidadesRepository(apiService)),
        ),

        ChangeNotifierProvider(
          create: (_) => PontosController(PontosRepository(apiService)),
        ),

        ChangeNotifierProvider(
          create: (_) => FavoritosController(FavoritosRepository(apiService)),
        ),

        Provider<UploadRepository>(create: (_) => UploadRepository(apiService)),

        ChangeNotifierProvider(
          create: (_) => HorariosController(HorariosRepository(apiService)),
        ),

        ChangeNotifierProvider(
          create: (_) => AtividadesController(AtividadesRepository(apiService)),
        ),

        ChangeNotifierProvider(
          create: (_) => EventosController(EventosRepository(apiService)),
        ),

        ChangeNotifierProvider(
          create: (_) => AvaliacoesController(AvaliacoesRepository(apiService)),
        ),

        ChangeNotifierProvider(
          create: (_) =>
              ComentariosController(ComentariosRepository(apiService)),
        ),
      ],
      child: const App(),
    ),
  );
}
