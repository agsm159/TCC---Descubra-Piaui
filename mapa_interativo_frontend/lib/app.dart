import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'controllers/auth_controller.dart';
import 'core/theme.dart';
import 'views/welcome/welcome_view.dart';
import 'views/mapa/mapa_view.dart';
import 'views/login/login_view.dart';
import 'views/perfil/perfil_view.dart';
import 'views/favoritos/favoritos_view.dart';
import 'views/admin/gerenciar_localizacoes_view.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Descobre Piauí',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      initialRoute: '/welcome',
      routes: {
        '/welcome': (context) => const WelcomeView(),
        '/login': (context) => const LoginView(),
        '/mapa': (context) => const MapaView(),
        '/perfil': (context) => const PerfilView(),
        '/favoritos': (context) => const FavoritosView(),
        '/gerenciar-localizacoes': (context) => const GerenciarLocalizacoesView(),
      },

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('pt', 'BR')],
    );
  }
}
