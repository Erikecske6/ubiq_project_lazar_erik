import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Add this import

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Start with an empty list instead of hardcoded data
  List<String> _myPlants = [];
  final TextEditingController _plantNameController = TextEditingController();

  // 1. When the screen first loads, tell it to fetch saved data
  @override
  void initState() {
    super.initState();
    _loadPlants();
  }

  // 2. Function to load data from the phone's hard drive
  Future<void> _loadPlants() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Look for a saved list called 'my_plants'. If it doesn't exist, return an empty list.
      _myPlants = prefs.getStringList('my_plants') ?? [];
    });
  }

  // 3. Function to save data to the phone's hard drive
  Future<void> _savePlants() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('my_plants', _myPlants);
  }

  void _showAddPlantDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add a New Plant'),
          content: TextField(
            controller: _plantNameController,
            decoration: const InputDecoration(hintText: "E.g., Aloe Vera"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_plantNameController.text.isNotEmpty) {
                  setState(() {
                    _myPlants.add(_plantNameController.text);
                  });
                  _savePlants(); // <-- Save to phone after adding
                  _plantNameController.clear();
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: _myPlants.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.local_florist, color: Colors.green),
              title: Text(_myPlants[index]),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: () {
                  setState(() {
                    _myPlants.removeAt(index);
                  });
                  _savePlants(); // <-- Save to phone after deleting
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPlantDialog,
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}