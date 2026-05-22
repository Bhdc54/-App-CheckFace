import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../main.dart';
import '../widgets/gradient_button.dart';
import '../widgets/theme_toggle_button.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _idController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _isAdmin = false;
  bool _loading = false;

  @override
  void dispose() {
    _idController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final id = _idController.text.trim();
    final senha = _senhaController.text.trim();
    if (id.isEmpty || senha.isEmpty) {
      _showError('Preencha todos os campos.');
      return;
    }
    setState(() => _loading = true);
    try {
      if (_isAdmin) {
        final data = await ApiService.loginAdmin(id, senha);
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/admin', arguments: data);
      } else {
        final data = await ApiService.loginUsuario(id, senha);
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/usuario', arguments: data);
      }
    } catch (e) {
      _showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final secondaryColor = AppColorHelper.textSecondary(context);
    final inputColor = AppColorHelper.input(context);
    final blueColor = AppColorHelper.blue(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: const [ThemeToggleButton()],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // LOGO — anéis concêntricos + símbolo com gradiente
              SizedBox(
                width: 110,
                height: 110,
                child: CustomPaint(
                  painter: _CheckFaceLogoPainter(isDark: isDark),
                ),
              ),
              const SizedBox(height: 14),
              ShaderMask(
                shaderCallback: (rect) => LinearGradient(
                  colors: [blueColor, AppColorHelper.blue(context)],
                ).createShader(rect),
                child: Text(
                  'CHECKFACE',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text('Controle de Acesso',
                  style: TextStyle(fontSize: 11, color: secondaryColor)),
              const SizedBox(height: 32),

              // SELETOR ALUNO / PROFESSOR
              Container(
                decoration: BoxDecoration(
                  color: inputColor,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isAdmin = false),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            gradient: !_isAdmin
                                ? const LinearGradient(
                                    colors: [AppColors.blue, AppColors.purple])
                                : null,
                          ),
                          child: Center(
                            child: Text('Aluno',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: !_isAdmin ? Colors.white : secondaryColor,
                                )),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isAdmin = true),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            gradient: _isAdmin
                                ? const LinearGradient(
                                    colors: [AppColors.blue, AppColors.purple])
                                : null,
                          ),
                          child: Center(
                            child: Text('Professor',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: _isAdmin ? Colors.white : secondaryColor,
                                )),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              TextField(
                controller: _idController,
                decoration: InputDecoration(labelText: _isAdmin ? 'SIAPE' : 'RGA'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _senhaController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Senha'),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    _isAdmin ? '/recuperar_senha_professor' : '/recuperar_senha',
                  ),
                  child: Text('Esqueci minha senha',
                      style: TextStyle(fontSize: 12, color: blueColor)),
                ),
              ),
              _loading
                  ? const CircularProgressIndicator()
                  : GradientButton(text: 'Entrar', onPressed: _login),
              const SizedBox(height: 12),
              if (!_isAdmin)
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                  child: Text('CADASTRAR-SE',
                      style: TextStyle(
                          fontSize: 12,
                          color: textColor,
                          decoration: TextDecoration.underline,
                          decorationColor: textColor)),
                )
              else
                TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/register_admin'),
                  child: Text('CADASTRAR-SE',
                      style: TextStyle(
                          fontSize: 12,
                          color: textColor,
                          decoration: TextDecoration.underline,
                          decorationColor: textColor)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// LOGO CHECKFACE — anéis concêntricos + símbolo com gradiente
// ============================================================
class _CheckFaceLogoPainter extends CustomPainter {
  final bool isDark;
  const _CheckFaceLogoPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * 0.5;
    final cy = size.height * 0.5;
    final center = Offset(cx, cy);
    final rect = Offset.zero & size;

    final colorA = isDark ? const Color(0xFF00A3FF) : const Color(0xFF0077EE);
    final colorB = isDark ? const Color(0xFF7C3AED) : const Color(0xFF6D28D9);

    // Anel externo (muito sutil)
    canvas.drawCircle(
      center,
      size.width * 0.48,
      Paint()
        ..color = colorA.withOpacity(0.06)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.6,
    );

    // Anel médio
    canvas.drawCircle(
      center,
      size.width * 0.40,
      Paint()
        ..color = colorA.withOpacity(0.10)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.6,
    );

    // Anel interno (borda do logo) — gradiente fino
    final borderPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [colorA, colorB],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(center, size.width * 0.32, borderPaint);

    // Gradiente compartilhado para o símbolo
    final gradShader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [colorA, colorB],
    ).createShader(rect);

    // Arco do "C" — fino
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: size.width * 0.20),
      0.45,
      5.38,
      false,
      Paint()
        ..shader = gradShader
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.030
        ..strokeCap = StrokeCap.round,
    );

    // Olhos — pequenos
    final eyePaint = Paint()
      ..shader = gradShader
      ..style = PaintingStyle.fill;

    final eyeR = size.width * 0.028;
    canvas.drawCircle(
        Offset(cx - size.width * 0.065, cy - size.height * 0.04), eyeR, eyePaint);
    canvas.drawCircle(
        Offset(cx + size.width * 0.065, cy - size.height * 0.04), eyeR, eyePaint);

    // Sorriso — fino
    canvas.drawArc(
      Rect.fromCircle(
          center: Offset(cx, cy + size.height * 0.02),
          radius: size.width * 0.075),
      0.2,
      2.75,
      false,
      Paint()
        ..shader = gradShader
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.028
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_CheckFaceLogoPainter old) => old.isDark != isDark;
}