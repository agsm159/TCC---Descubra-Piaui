import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/api_service.dart';
import 'controllers/auth_controller.dart';
import 'controllers/pontos_controller.dart';
import 'controllers/cidades_controller.dart';
import 'controllers/favoritos_controller.dart';
import 'data/pontos_repository.dart';
import 'data/cidades_repository.dart';
import 'data/upload_repository.dart';
import 'data/favoritos_repository.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final apiService = ApiService();

  runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>(create: (_) => apiService),

        ChangeNotifierProvider(
          create: (_) => AuthController(apiService),
        ),

        ChangeNotifierProvider(
          create: (_) => CidadesController(
            CidadesRepository(apiService),
          ),
        ),

        ChangeNotifierProvider(
          create: (_) => PontosController(
            PontosRepository(apiService),
          ),
        ),

        ChangeNotifierProvider(
          create: (_) => FavoritosController(
            FavoritosRepository(apiService),
          ),
        ),

        Provider<UploadRepository>(
          create: (_) => UploadRepository(apiService),
        ),
      ],
      child: const App(),
    ),
  );
}