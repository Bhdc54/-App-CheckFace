import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

const String baseUrl = 'https://checkface.up.railway.app';

class ApiService {
  // ============================================================
  // LOGIN
  // ============================================================
  static Future<Map<String, dynamic>> loginUsuario(
      String matricula, String senha) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login/usuario'),
      body: {'matricula': matricula, 'senha': senha},
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception(jsonDecode(response.body)['detail'] ?? 'Erro no login');
  }

  static Future<Map<String, dynamic>> loginAdmin(
      String siape, String senha) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login/admin'),
      body: {'siape': siape, 'senha': senha},
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception(jsonDecode(response.body)['detail'] ?? 'Erro no login');
  }

  // ============================================================
  // USUÁRIOS
  // ============================================================
  static Future<Map<String, dynamic>> cadastrarUsuario({
    required String nome,
    required String matricula,
    required String senha,
    required File foto,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/usuarios/cadastrar'),
    );
    request.fields['nome'] = nome;
    request.fields['matricula'] = matricula;
    request.fields['senha'] = senha;
    request.files.add(await http.MultipartFile.fromPath('foto', foto.path));
    final response = await request.send();
    final body = await response.stream.bytesToString();
    if (response.statusCode == 200) return jsonDecode(body);
    throw Exception(jsonDecode(body)['detail'] ?? 'Erro ao cadastrar');
  }

  static Future<List<dynamic>> listarUsuarios() async {
    final response = await http.get(Uri.parse('$baseUrl/usuarios'));
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Erro ao listar usuários');
  }

  // ============================================================
  // RECUPERAÇÃO DE SENHA — USUÁRIO
  // ============================================================
  static Future<Map<String, dynamic>> recuperarSenha({
    required String matricula,
    required String novaSenha,
    required File foto,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/usuarios/recuperar_senha'),
    );
    request.fields['matricula'] = matricula;
    request.fields['nova_senha'] = novaSenha;
    request.files.add(await http.MultipartFile.fromPath('foto', foto.path));
    final response = await request.send();
    final body = await response.stream.bytesToString();
    if (response.statusCode == 200) return jsonDecode(body);
    throw Exception(jsonDecode(body)['detail'] ?? 'Erro ao recuperar senha');
  }

  // ============================================================
  // RECUPERAÇÃO DE SENHA — PROFESSOR
  // ============================================================
  static Future<Map<String, dynamic>> recuperarSenhaProfessor({
    required String siape,
    required String novaSenha,
    required File foto,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/admin/recuperar_senha'),
    );
    request.fields['siape'] = siape;
    request.fields['nova_senha'] = novaSenha;
    request.files.add(await http.MultipartFile.fromPath('foto', foto.path));
    final response = await request.send();
    final body = await response.stream.bytesToString();
    if (response.statusCode == 200) return jsonDecode(body);
    throw Exception(jsonDecode(body)['detail'] ?? 'Erro ao recuperar senha');
  }

  // ============================================================
  // ACESSOS
  // ============================================================
  static Future<List<dynamic>> historicoUsuario(int usuarioId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/usuarios/$usuarioId/acessos'));
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Erro ao buscar histórico');
  }

  static Future<List<dynamic>> acessosHoje() async {
    final response = await http.get(Uri.parse('$baseUrl/acessos/hoje'));
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Erro ao buscar acessos');
  }

  static Future<List<dynamic>> acessosPorData(String data) async {
    final response =
        await http.get(Uri.parse('$baseUrl/acessos/data/$data'));
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Erro ao buscar acessos por data');
  }

  // ============================================================
  // ADMIN
  // ============================================================
  static Future<void> liberarAcesso(String matricula) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/liberar_acesso'),
      body: {'matricula': matricula},
    );
    if (response.statusCode != 200) {
      throw Exception(
          jsonDecode(response.body)['detail'] ?? 'Erro ao liberar acesso');
    }
  }

  static Future<void> revogarAcesso(String matricula) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/revogar_acesso'),
      body: {'matricula': matricula},
    );
    if (response.statusCode != 200) {
      throw Exception(
          jsonDecode(response.body)['detail'] ?? 'Erro ao revogar acesso');
    }
  }

  static Future<Map<String, dynamic>> cadastrarAdmin({
    required String nome,
    required String siape,
    required String senha,
    required File foto,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/admin/cadastrar'),
    );
    request.fields['nome'] = nome;
    request.fields['siape'] = siape;
    request.fields['senha'] = senha;
    request.files.add(await http.MultipartFile.fromPath('foto', foto.path));
    final response = await request.send();
    final body = await response.stream.bytesToString();
    if (response.statusCode == 200) return jsonDecode(body);
    throw Exception(jsonDecode(body)['detail'] ?? 'Erro ao cadastrar professor');
  }
}