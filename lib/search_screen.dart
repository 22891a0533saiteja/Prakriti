import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> _allPlants = []; // Store all plant names
  List<String> _searchResults = []; // Store filtered search results
  bool _isRetrieving = false; // Track if data is being retrieved
  bool _isSearching = false; // Track if user is searching

  @override
  void initState() {
    super.initState();
    _fetchAllPlants(); // Fetch all plants on initialization
  }

  Future<void> _fetchAllPlants() async {
    setState(() {
      _isRetrieving = true; // Start retrieving data
    });

    try {
      final snapshot = await _firestore.collection('plantDetails').get();
      setState(() {
        _allPlants = snapshot.docs.map((doc) => doc.id).toList(); // Store plant names
        _searchResults = _allPlants; // Initially show all plants
        _isRetrieving = false; // Finished retrieving data
      });
    } catch (e) {
      print("Error fetching plants: $e");
      setState(() {
        _isRetrieving = false; // Finished retrieving data even if there was an error
      });
    }
  }

  void _searchPlants(String query) {
    setState(() {
      _isSearching = query.isNotEmpty; // If there's a query, the user is searching
      if (query.isEmpty) {
        _searchResults = _allPlants; // Show all plants if query is empty
      } else {
        _searchResults = _allPlants
            .where((plant) =>
            plant.toLowerCase().contains(query.toLowerCase())) // Filter plants based on query
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Plants'),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: _searchPlants,
              decoration: InputDecoration(
                hintText: 'Search for a plant...',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[800],
                suffixIcon: _isSearching
                    ? CircularProgressIndicator() // Show loader when searching
                    : null,
              ),
              style: TextStyle(color: Colors.white),
              cursorColor: Colors.orange,
            ),
          ),
          Expanded(
            child: _isRetrieving
                ? Center(
              child: Text(
                'Retrieving data...',
                style: TextStyle(color: Colors.white),
              ),
            )
                : _searchResults.isEmpty
                ? Center(
              child: Text(
                'No matching plants found.',
                style: TextStyle(color: Colors.white),
              ),
            )
                : ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    _searchResults[index],
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    // Navigate to PlantDetailPage or other details here
                    // Example: Navigator.push(context, MaterialPageRoute(builder: (context) => PlantDetailPage(herbName: _searchResults[index])));
                  },
                );
              },
            ),
          ),
        ],
      ),
      backgroundColor: Colors.black,
    );
  }
}
