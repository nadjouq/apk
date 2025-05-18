import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';

class Vehicle {
  final String code;
  final String matricule;
  final String marque;
  final String type;
  final String statut;
  final String structure;
  final String kmTotal;
  final String derniereMaj;

  Vehicle({
    required this.code,
    required this.matricule,
    required this.marque,
    required this.type,
    required this.statut,
    required this.structure,
    required this.kmTotal,
    required this.derniereMaj,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      code: json['code'] ?? '',
      matricule: json['matricule'] ?? '',
      marque: json['marque'] ?? '',
      type: json['type'] ?? '',
      statut: json['statut'] ?? '',
      structure: json['structure'] ?? '',
      kmTotal: json['kmTotal'] ?? '',
      derniereMaj: json['derniereMaj'] ?? '',
    );
  }
}

class VehiclePage extends StatefulWidget {
  const VehiclePage({super.key});

  @override
  State<VehiclePage> createState() => _VehiclePageState();
}

class _VehiclePageState extends State<VehiclePage> {
  List<Vehicle> vehicles = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchVehicles();
  }

  Future<void> fetchVehicles() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final response = await http.get(
        Uri.parse('http://192.168.8.101:3001/api/mobile/vehicule'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          vehicles = data.map((json) => Vehicle.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Erreur lors de la récupération des véhicules';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Erreur de connexion au serveur';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Véhicules'),
        backgroundColor: const Color(0xFF002866),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchVehicles,
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        error!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: fetchVehicles,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: DataTable(
                      headingRowColor:
                          MaterialStateProperty.all(const Color(0xFF002866)),
                      headingTextStyle: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                      columns: const [
                        DataColumn(label: Text('Code')),
                        DataColumn(label: Text('Matricule')),
                        DataColumn(label: Text('Marque')),
                        DataColumn(label: Text('Type')),
                        DataColumn(label: Text('Statut')),
                        DataColumn(label: Text('Structure')),
                        DataColumn(label: Text('Km total')),
                        DataColumn(label: Text('Dernière MAJ')),
                      ],
                      rows: vehicles.map((vehicle) {
                        return DataRow(
                          cells: [
                            DataCell(Text(vehicle.code)),
                            DataCell(Text(vehicle.matricule)),
                            DataCell(Text(vehicle.marque)),
                            DataCell(Text(vehicle.type)),
                            DataCell(Text(vehicle.statut)),
                            DataCell(Text(vehicle.structure)),
                            DataCell(Text(vehicle.kmTotal)),
                            DataCell(Text(vehicle.derniereMaj)),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
    );
  }
}
