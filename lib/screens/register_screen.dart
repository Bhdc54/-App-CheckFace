import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../core/app_theme.dart';
import '../widgets/theme_toggle_button.dart';
import '../widgets/gradient_button.dart';
import '../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nomeController = TextEditingController();
  final _rgaController = TextEditingController();
  final _senhaController = TextEditingController();
  File? _foto;
  bool _loading = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _rgaController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _tirarFoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      imageQuality: 85,
    );
    if (picked != null) setState(() => _foto = File(picked.path));
  }

  Future<void> _cadastrar() async {
    final nome = _nomeController.text.trim();
    final rga = _rgaController.text.trim();
    final senha = _senhaController.text.trim();
    if (nome.isEmpty || rga.isEmpty || senha.isEmpty) {
      _showError('Preencha todos os campos.');
      return;
    }
    if (_foto == null) {
      _showError('Tire uma foto para o cadastro facial.');
      return;
    }
    setState(() => _loading = true);
    try {
      await ApiService.cadastrarUsuario(
          nome: nome, matricula: rga, senha: senha, foto: _foto!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Cadastro realizado! Aguarde liberação do professor.'),
        backgroundColor: Colors.green,
      ));
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
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final secondaryColor = AppColorHelper.textSecondary(context);
    final inputColor = AppColorHelper.input(context);
    final blueColor = AppColorHelper.blue(context);
    final successColor = AppColorHelper.success(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Aluno'),
        centerTitle: true,
        actions: const [ThemeToggleButton()],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            // 1. CÍRCULO DE FOTO
            GestureDetector(
              onTap: _tirarFoto,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _foto != null ? successColor : blueColor,
                    width: 2,
                  ),
                  color: inputColor,
                  image: _foto != null
                      ? DecorationImage(
                          image: FileImage(_foto!), fit: BoxFit.cover)
                      : null,
                ),
                child: _foto == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt, color: blueColor, size: 32),
                          const SizedBox(height: 4),
                          Text('Tirar foto',
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
                icon: Icon(Icons.refresh, size: 16, color: blueColor),
                label: Text('Tirar outra foto',
                    style: TextStyle(fontSize: 12, color: blueColor)),
              ),
            ],
            const SizedBox(height: 8),

            // 2. TEXTO AUXILIAR
            Text(
              'Foto obrigatória para reconhecimento facial',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: secondaryColor),
            ),
            const SizedBox(height: 24),

            // 3. SUBTÍTULO
            Text(
              'Novo Aluno',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 24),

            // 4. CAMPOS
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(labelText: 'Nome Completo*'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _rgaController,
              decoration: const InputDecoration(labelText: 'RGA*'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _senhaController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Senha*'),
            ),
            const SizedBox(height: 24),

            // 5. BOTÃO
            _loading
                ? const CircularProgressIndicator()
                : GradientButton(text: 'CADASTRAR', onPressed: _cadastrar),
            const SizedBox(height: 16),

            // 6. TEXTO INFORMATIVO
            Text(
              'Após o cadastro, aguarde a liberação do professor.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: secondaryColor),
            ),
          ],
        ),
      ),
    );
  }
}