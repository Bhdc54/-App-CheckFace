import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/register_admin_screen.dart';
import 'screens/usuario_home_screen.dart';
import 'screens/admin_home_screen.dart';
import 'screens/recuperar_senha_screen.dart';
import 'screens/recuperar_senha_professor_screen.dart';

// ============================================================
// NOTIFIER — controla o tema globalmente
// ============================================================
class ThemeNotifier extends ChangeNotifier {
  bool _isDark = true;

  bool get isDark => _isDark;

  void toggle() {
    _isDark = !_isDark;
    notifyListeners();
  }
}

// Instância global acessível em toda a app
final themeNotifier = ThemeNotifier();

// ============================================================
// MAIN
// ============================================================
void main() {
  runApp(const CheckFaceApp());
}

class CheckFaceApp extends StatefulWidget {
  const CheckFaceApp({super.key});

  @override
  State<CheckFaceApp> createState() => _CheckFaceAppState();
}

class _CheckFaceAppState extends State<CheckFaceApp> {
  @override
  void initState() {
    super.initState();
    themeNotifier.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    themeNotifier.removeListener(() => setState(() {}));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CheckFace',
      debugShowCheckedModeBanner: false,

      // Alterna entre tema escuro e claro
      theme: themeNotifier.isDark ? buildAppTheme() : buildAppThemeLight(),

      // Localização em português
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [
        Locale('pt', 'BR'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      initialRoute: '/splash',
      routes: {
        '/splash': (_) => const SplashScreen(),
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/register_admin': (_) => const RegisterAdminScreen(),
        '/usuario': (_) => const UsuarioHomeScreen(),
        '/admin': (_) => const AdminHomeScreen(),
        '/recuperar_senha': (_) => const RecuperarSenhaScreen(),
        '/recuperar_senha_professor': (_) => const RecuperarSenhaProfessorScreen(),
      },
    );
  }
}