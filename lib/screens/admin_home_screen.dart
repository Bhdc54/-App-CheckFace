import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../main.dart';
import '../services/api_service.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen>
    with SingleTickerProviderStateMixin {
  List<dynamic> _acessosDia = [];
  List<dynamic> _usuarios = [];
  bool _loading = true;
  bool _iniciado = false;
  late Map<String, dynamic> _admin;
  late TabController _tabController;
  final _rgaController = TextEditingController();
  DateTime _dataSelecionada = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_iniciado) {
      _iniciado = true;
      _admin = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      _carregar();
    }
  }

  @override
  void dispose() {
    _rgaController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  String get _dataFormatada =>
      '${_dataSelecionada.year}-${_dataSelecionada.month.toString().padLeft(2, '0')}-${_dataSelecionada.day.toString().padLeft(2, '0')}';

  String get _dataExibicao {
    final hoje = DateTime.now();
    if (_dataSelecionada.day == hoje.day &&
        _dataSelecionada.month == hoje.month &&
        _dataSelecionada.year == hoje.year) return 'Hoje';
    return '${_dataSelecionada.day.toString().padLeft(2, '0')}/${_dataSelecionada.month.toString().padLeft(2, '0')}/${_dataSelecionada.year}';
  }

  Future<void> _carregar() async {
    setState(() => _loading = true);
    try {
      final acessos = await ApiService.acessosPorData(_dataFormatada);
      final usuarios = await ApiService.listarUsuarios();
      setState(() {
        _acessosDia = acessos;
        _usuarios = usuarios;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _selecionarData() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final picked = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: isDark
              ? const ColorScheme.dark(
                  primary: AppColors.blue,
                  surface: AppColors.card,
                )
              : ColorScheme.light(
                  primary: AppColorsLight.blue,
                  surface: AppColorsLight.card,
                ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _dataSelecionada = picked);
      await _carregar();
    }
  }

  void _mostrarDialogAcesso(bool liberar) {
    _rgaController.clear();
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final secondaryColor = Theme.of(context).textTheme.bodySmall?.color;
    final cardColor = Theme.of(context).cardColor;
    final actionColor = liberar
        ? AppColorHelper.success(context)
        : AppColorHelper.danger(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardColor,
        title: Text(
          liberar ? 'Liberar Acesso' : 'Revogar Acesso',
          style: TextStyle(color: textColor),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              liberar ? 'Digite o RGA para liberar:' : 'Digite o RGA para revogar:',
              style: TextStyle(color: secondaryColor, fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _rgaController,
              decoration: const InputDecoration(labelText: 'RGA*'),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancelar', style: TextStyle(color: secondaryColor)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              liberar ? _liberarAcesso() : _revogarAcesso();
            },
            child: Text(
              liberar ? 'Liberar' : 'Revogar',
              style: TextStyle(color: actionColor, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _liberarAcesso() async {
    final rga = _rgaController.text.trim();
    if (rga.isEmpty) return;
    try {
      await ApiService.liberarAcesso(rga);
      _showSnack('Acesso liberado!', AppColorHelper.success(context));
      await _carregar();
    } catch (e) {
      _showSnack(e.toString().replaceAll('Exception: ', ''), AppColorHelper.danger(context));
    }
  }

  Future<void> _revogarAcesso() async {
    final rga = _rgaController.text.trim();
    if (rga.isEmpty) return;
    try {
      await ApiService.revogarAcesso(rga);
      _showSnack('Acesso revogado.', Colors.orange);
      await _carregar();
    } catch (e) {
      _showSnack(e.toString().replaceAll('Exception: ', ''), AppColorHelper.danger(context));
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  void _sair() =>
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);

  // ============================================================
  // POPUP MENU — substitui os 3 botões do AppBar
  // ============================================================
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
        if (value == 'atualizar') _carregar();
        if (value == 'sair') _sair();
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'tema',
          child: Row(
            children: [
              Icon(
                isDark ? Icons.light_mode : Icons.dark_mode,
                color: iconColor,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                isDark ? 'Modo Claro' : 'Modo Escuro',
                style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'atualizar',
          child: Row(
            children: [
              Icon(Icons.refresh, color: iconColor, size: 20),
              const SizedBox(width: 12),
              Text(
                'Atualizar',
                style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'sair',
          child: Row(
            children: [
              const Icon(Icons.logout, color: Colors.red, size: 20),
            const SizedBox(width: 12),
            const Text('Sair', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final secondaryColor = Theme.of(context).textTheme.bodySmall?.color;
    final cardColor = Theme.of(context).cardColor;
    final successColor = AppColorHelper.success(context);
    final successBgColor = AppColorHelper.successBg(context);
    final dangerColor = AppColorHelper.danger(context);
    final blueColor = AppColorHelper.blue(context);

    final usuariosLiberados =
        _usuarios.where((u) => u['acesso_liberado'] == true).toList();
    final acessosLiberados =
        _acessosDia.where((a) => a['status'] == 'liberado').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Professor'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [_buildMenuButton()],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.lock_open), text: 'Acesso'),
            Tab(icon: Icon(Icons.door_front_door), text: 'Entradas'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // CABEÇALHO
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bem-vindo, ${_admin['nome']}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // BOTÕES LIBERAR / REVOGAR
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: successBgColor,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                side: BorderSide(color: successColor, width: 1.5),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25)),
                                elevation: 0,
                              ),
                              icon: Icon(Icons.lock_open, color: successColor, size: 18),
                              label: Text('LIBERAR',
                                  style: TextStyle(
                                      color: successColor,
                                      fontWeight: FontWeight.bold)),
                              onPressed: () => _mostrarDialogAcesso(true),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColorHelper.dangerBg(context),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                side: BorderSide(color: dangerColor, width: 1.5),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25)),
                                elevation: 0,
                              ),
                              icon: Icon(Icons.lock, color: dangerColor, size: 18),
                              label: Text('REVOGAR',
                                  style: TextStyle(
                                      color: dangerColor,
                                      fontWeight: FontWeight.bold)),
                              onPressed: () => _mostrarDialogAcesso(false),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ABAS
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // ABA 1 — USUÁRIOS COM ACESSO
                      usuariosLiberados.isEmpty
                          ? Center(
                              child: Text(
                                'Nenhum usuário com acesso liberado.',
                                style: TextStyle(color: secondaryColor),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              itemCount: usuariosLiberados.length,
                              itemBuilder: (context, index) {
                                final u = usuariosLiberados[index];
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
                                      Icon(Icons.person,
                                          color: successColor, size: 28),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(u['nome'] ?? '',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                  color: textColor)),
                                          Text('RGA: ${u['matricula'] ?? ''}',
                                              style: TextStyle(
                                                  color: secondaryColor,
                                                  fontSize: 12)),
                                        ],
                                      ),
                                      const Spacer(),
                                      Icon(Icons.lock_open,
                                          color: successColor, size: 18),
                                    ],
                                  ),
                                );
                              },
                            ),

                      // ABA 2 — ENTRADAS COM SELETOR DE DATA
                      Column(
                        children: [
                          // SELETOR DE DATA
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
                            child: GestureDetector(
                              onTap: _selecionarData,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF1A1A2E)
                                      : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: blueColor.withOpacity(0.4)),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.calendar_today,
                                            color: blueColor, size: 18),
                                        const SizedBox(width: 10),
                                        Text(
                                          _dataExibicao,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                              color: textColor),
                                        ),
                                      ],
                                    ),
                                    Icon(Icons.arrow_drop_down,
                                        color: secondaryColor),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // LISTA DE ENTRADAS
                          Expanded(
                            child: acessosLiberados.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.door_front_door,
                                            size: 48,
                                            color: secondaryColor
                                                ?.withOpacity(0.3)),
                                        const SizedBox(height: 12),
                                        Text(
                                          'Nenhuma entrada em $_dataExibicao.',
                                          style:
                                              TextStyle(color: secondaryColor),
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 4),
                                    itemCount: acessosLiberados.length,
                                    itemBuilder: (context, index) {
                                      final a = acessosLiberados[index];
                                      return Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 10),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 14),
                                        decoration: BoxDecoration(
                                          color: cardColor,
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          border: Border.all(
                                              color:
                                                  blueColor.withOpacity(0.3)),
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
                                                Text(
                                                  a['nome'] ?? 'Desconhecido',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 14,
                                                      color: textColor),
                                                ),
                                                Text(
                                                  'Entrou às ${a['hora']}',
                                                  style: TextStyle(
                                                      color: secondaryColor,
                                                      fontSize: 12),
                                                ),
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
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}