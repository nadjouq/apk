import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';

class User {
  final int id;
  final String nom;
  final String prenom;
  final String email;
  final String role;
  final String droits;
  final String structure;
  final String username;
  final String telephone;
  final String methodeAuth;
  final bool estAdmin;

  User({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.role,
    required this.droits,
    required this.structure,
    required this.username,
    required this.telephone,
    required this.methodeAuth,
    required this.estAdmin,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      nom: json['nom'] ?? '',
      prenom: json['prenom'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      droits: json['droits'] ?? '',
      structure: json['structure'] ?? '',
      username: json['username'] ?? '',
      telephone: json['telephone'] ?? '',
      methodeAuth: json['methodeAuth'] ?? '',
      estAdmin: json['estAdmin'] ?? false,
    );
  }
}

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  List<User> users = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        print('Token manquant');
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        }
        return;
      }

      print('Tentative de connexion à l\'API utilisateurs...');
      print('Token présent: ${token.isNotEmpty}');

      final response = await http.get(
        Uri.parse('http://192.168.8.110:3001/api/mobile/users'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Code de réponse: ${response.statusCode}');
      print('Réponse du serveur: ${response.body}');

      if (response.statusCode == 401) {
        print('Session expirée, redirection vers la page de connexion');
        await prefs.clear();
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        }
        return;
      }

      if (response.statusCode != 200) {
        throw Exception(
            'Erreur lors de la récupération des utilisateurs: ${response.statusCode}');
      }

      final List<dynamic> data = json.decode(response.body);
      setState(() {
        users = data.map((json) => User.fromJson(json)).toList();
        isLoading = false;
      });
    } catch (e) {
      print('Erreur détaillée: $e');
      setState(() {
        error = 'Erreur lors de la récupération des utilisateurs: $e';
        isLoading = false;
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'actif':
        return Colors.green;
      case 'inactif':
        return Colors.red;
      case 'bloqué':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Gestion des Utilisateurs',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF002866),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: fetchUsers,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: fetchUsers,
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF002866)),
                ),
              )
            : error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          error!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: fetchUsers,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF002866),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  )
                : users.isEmpty
                    ? const Center(
                        child: Text(
                          'Aucun utilisateur trouvé',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final user = users[index];
                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white,
                                    Colors.blue.shade50,
                                  ],
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '${user.prenom} ${user.nom}',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF002866),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: user.estAdmin
                                                ? Colors.green.withOpacity(0.1)
                                                : Colors.blue.withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(
                                              color: user.estAdmin
                                                  ? Colors.green
                                                  : Colors.blue,
                                            ),
                                          ),
                                          child: Text(
                                            user.estAdmin
                                                ? 'Administrateur'
                                                : 'Utilisateur',
                                            style: TextStyle(
                                              color: user.estAdmin
                                                  ? Colors.green
                                                  : Colors.blue,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    _buildInfoRow(
                                      Icons.email,
                                      'Email',
                                      user.email,
                                    ),
                                    const SizedBox(height: 8),
                                    _buildInfoRow(
                                      Icons.work,
                                      'Rôle',
                                      user.role,
                                    ),
                                    const SizedBox(height: 8),
                                    _buildInfoRow(
                                      Icons.security,
                                      'Droits',
                                      user.droits,
                                    ),
                                    const SizedBox(height: 8),
                                    _buildInfoRow(
                                      Icons.business,
                                      'Structure',
                                      user.structure,
                                    ),
                                    const SizedBox(height: 8),
                                    _buildInfoRow(
                                      Icons.person,
                                      'Nom d\'utilisateur',
                                      user.username,
                                    ),
                                    const SizedBox(height: 8),
                                    _buildInfoRow(
                                      Icons.phone,
                                      'Téléphone',
                                      user.telephone,
                                    ),
                                    const SizedBox(height: 8),
                                    _buildInfoRow(
                                      Icons.security,
                                      'Méthode d\'authentification',
                                      user.methodeAuth,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: const Color(0xFF002866),
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
