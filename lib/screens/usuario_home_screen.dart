import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../main.dart';
import '../services/api_service.dart';

class UsuarioHomeScreen extends StatefulWidget {
  const UsuarioHomeScreen({super.key});

  @override
  State<UsuarioHomeScreen> createState() => _UsuarioHomeScreenState();
}

class _UsuarioHomeScreenState extends State<UsuarioHomeScreen> {
  List<dynamic> _acessos = [];
  bool _loading = true;
  bool _iniciado = false;
  late Map<String, dynamic> _usuario;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_iniciado) {
      _iniciado = true;
      _usuario = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      _carregarHistorico();
    }
  }

  Future<void> _carregarHistorico() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService.historicoUsuario(_usuario['id']);
      setState(() { _acessos = data; _loading = false; });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  void _sair() =>
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);

  Widget _buildMenuButton() {
    final iconColor = Theme.of(context).iconTheme.color;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: iconColor),
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) {
        if (value == 'tema') themeNotifier.toggle();
        if (value == 'atualizar') _carregarHistorico();
        if (value == 'sair') _sair();
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'tema',
          child: Row(children: [
            Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: iconColor,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              isDark ? 'Modo Claro' : 'Modo Escuro',
              style: TextStyle(color: textColor),
            ),
          ]),
        ),
        PopupMenuItem(
          value: 'atualizar',
          child: Row(children: [
            Icon(Icons.refresh, color: iconColor, size: 20),
            const SizedBox(width: 12),
            Text('Atualizar', style: TextStyle(color: textColor)),
          ]),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'sair',
          child: Row(children: [
            const Icon(Icons.logout, color: Colors.red, size: 20),
            const SizedBox(width: 12),
            const Text('Sair', style: TextStyle(color: Colors.red)),
          ]),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final secondaryColor = AppColorHelper.textSecondary(context);
    final cardColor = Theme.of(context).cardColor;
    final successColor = AppColorHelper.success(context);
    final successBg = AppColorHelper.successBg(context);
    final dangerColor = AppColorHelper.danger(context);
    final dangerBg = AppColorHelper.dangerBg(context);
    final bool acessoLiberado = _usuario['acesso_liberado'] ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Acesso'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [_buildMenuButton()],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bem-vindo, ${_usuario['nome']}!',
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 4),
            Text('RGA: ${_usuario['matricula']}',
                style: TextStyle(color: secondaryColor, fontSize: 13)),
            const SizedBox(height: 20),

            // STATUS DE ACESSO
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                color: acessoLiberado ? successBg : dangerBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: acessoLiberado ? successColor : dangerColor,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    acessoLiberado ? Icons.lock_open_rounded : Icons.lock_rounded,
                    color: acessoLiberado ? successColor : dangerColor,
                    size: 36,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        acessoLiberado ? 'Acesso Liberado' : 'Acesso Bloqueado',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: acessoLiberado ? successColor : dangerColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        acessoLiberado
                            ? 'Você pode acessar a sala.'
                            : 'Aguarde liberação do professor.',
                        style: TextStyle(color: secondaryColor, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),
            Text('Histórico de Entradas:',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600, color: textColor)),
            const SizedBox(height: 12),

            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _acessos.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.history,
                                  size: 48,
                                  color: secondaryColor.withOpacity(0.4)),
                              const SizedBox(height: 12),
                              Text('Nenhuma entrada registrada ainda.',
                                  style: TextStyle(color: secondaryColor)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _acessos.length,
                          itemBuilder: (context, index) {
                            final a = _acessos[index];
                            if (a['status'] != 'liberado')
                              return const SizedBox.shrink();
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color: successColor.withOpacity(0.4)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.check_circle_rounded,
                                      color: successColor, size: 28),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Entrada registrada',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                              color: textColor)),
                                      const SizedBox(height: 4),
                                      Text('${a['data']} às ${a['hora']}',
                                          style: TextStyle(
                                              color: secondaryColor,
                                              fontSize: 12)),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}