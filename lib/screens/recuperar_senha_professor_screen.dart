import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../core/app_theme.dart';
import '../widgets/theme_toggle_button.dart';
import '../widgets/gradient_button.dart';
import '../services/api_service.dart';

class RecuperarSenhaProfessorScreen extends StatefulWidget {
  const RecuperarSenhaProfessorScreen({super.key});

  @override
  State<RecuperarSenhaProfessorScreen> createState() =>
      _RecuperarSenhaProfessorScreenState();
}

class _RecuperarSenhaProfessorScreenState
    extends State<RecuperarSenhaProfessorScreen> {
  final _siapeController = TextEditingController();
  final _novaSenhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  File? _foto;
  bool _loading = false;

  @override
  void dispose() {
    _siapeController.dispose();
    _novaSenhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  Future<void> _tirarFoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 90,
      preferredCameraDevice: CameraDevice.front,
    );
    if (picked != null) setState(() => _foto = File(picked.path));
  }

  Future<void> _recuperar() async {
    final siape = _siapeController.text.trim();
    final novaSenha = _novaSenhaController.text.trim();
    final confirmar = _confirmarSenhaController.text.trim();
    if (siape.isEmpty) { _showError('Digite seu SIAPE.'); return; }
    if (_foto == null) { _showError('Tire uma foto para verificar sua identidade.'); return; }
    if (novaSenha.isEmpty || confirmar.isEmpty) { _showError('Preencha a nova senha.'); return; }
    if (novaSenha != confirmar) { _showError('As senhas não coincidem.'); return; }
    if (novaSenha.length < 6) { _showError('A senha deve ter pelo menos 6 caracteres.'); return; }
    setState(() => _loading = true);
    try {
      final result = await ApiService.recuperarSenhaProfessor(
          siape: siape, novaSenha: novaSenha, foto: _foto!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Senha redefinida! Bem-vindo, ${result['nome']}!'),
        backgroundColor: Colors.green,
      ));
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      Navigator.pop(context);
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
    final secondaryColor = AppColorHelper.textSecondary(context);
    final purpleColor = AppColorHelper.blue(context);
    final inputColor = AppColorHelper.input(context);
    final successColor = AppColorHelper.success(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recuperar Senha'),
        centerTitle: true,
        actions: const [ThemeToggleButton()],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: purpleColor, width: 2),
                color: purpleColor.withOpacity(0.1),
              ),
              child: Icon(Icons.lock_reset, color: purpleColor, size: 36),
            ),
            const SizedBox(height: 12),
            Text('Verificação por Reconhecimento Facial',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: secondaryColor)),
            const SizedBox(height: 8),
            Text(
              'Informe seu SIAPE, tire uma selfie e defina a nova senha.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: secondaryColor),
            ),
            const SizedBox(height: 32),

            TextField(
              controller: _siapeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'SIAPE*',
                prefixIcon: Icon(Icons.badge_outlined, color: purpleColor),
              ),
            ),
            const SizedBox(height: 20),

            GestureDetector(
              onTap: _tirarFoto,
              child: Container(
                width: 120, height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: inputColor,
                  border: Border.all(
                    color: _foto != null ? successColor : purpleColor,
                    width: 2,
                  ),
                  image: _foto != null
                      ? DecorationImage(
                          image: FileImage(_foto!), fit: BoxFit.cover)
                      : null,
                ),
                child: _foto == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt, color: purpleColor, size: 32),
                          const SizedBox(height: 4),
                          Text('Tirar Selfie',
                              style: TextStyle(
                                  fontSize: 11, color: secondaryColor)),
                        ],
                      )
                    : null,
              ),
            ),
            if (_foto != null) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _tirarFoto,
                icon: Icon(Icons.refresh, size: 16, color: purpleColor),
                label: Text('Tirar outra foto',
                    style: TextStyle(fontSize: 12, color: purpleColor)),
              ),
            ],
            const SizedBox(height: 24),

            TextField(
              controller: _novaSenhaController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Nova Senha*',
                prefixIcon: Icon(Icons.lock_outline, color: purpleColor),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmarSenhaController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirmar Nova Senha*',
                prefixIcon: Icon(Icons.lock_outline, color: purpleColor),
              ),
            ),
            const SizedBox(height: 32),

            _loading
                ? const CircularProgressIndicator()
                : GradientButton(text: 'Redefinir Senha', onPressed: _recuperar),
          ],
        ),
      ),
    );
  }
}