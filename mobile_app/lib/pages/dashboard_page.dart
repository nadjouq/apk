import 'package:flutter/material.dart';
import 'vehicle_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord'),
        backgroundColor: const Color(0xFF002866),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec le nom de l'utilisateur
            const Card(
              color: Color(0xFFD3D31B),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Color(0xFF002866),
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bienvenue',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF002866),
                          ),
                        ),
                        Text(
                          'Tableau de bord NAFTAL',
                          style: TextStyle(
                            color: Color(0xFF002866),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Section des statistiques rapides
            const Text(
              'Statistiques rapides',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF002866),
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildStatCard(
                  'Véhicules',
                  '12',
                  Icons.directions_car,
                  Colors.blue,
                ),
                _buildStatCard(
                  'Alertes',
                  '5',
                  Icons.warning,
                  Colors.orange,
                ),
                _buildStatCard(
                  'Documents',
                  '8',
                  Icons.description,
                  Colors.green,
                ),
                _buildStatCard(
                  'Demandes',
                  '3',
                  Icons.pending_actions,
                  Colors.purple,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Section des actions rapides
            const Text(
              'Actions rapides',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF002866),
              ),
            ),
            const SizedBox(height: 16),
            _buildActionButton(
              context,
              'Gérer les véhicules',
              Icons.directions_car,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const VehiclePage()),
                );
              },
            ),
            const SizedBox(height: 8),
            _buildActionButton(
              context,
              'Voir les alertes',
              Icons.warning,
              () {
                // TODO: Navigation vers les alertes
              },
            ),
            const SizedBox(height: 8),
            _buildActionButton(
              context,
              'Documents',
              Icons.description,
              () {
                // TODO: Navigation vers les documents
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF002866),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(title),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF002866),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
