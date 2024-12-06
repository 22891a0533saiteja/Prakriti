import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'chatbot_home.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _allPlants = [];
  List<Map<String, dynamic>> _searchResults = [];
  bool _isRetrieving = false;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _fetchAllPlants();
  }

  Future<void> _fetchAllPlants() async {
    setState(() {
      _isRetrieving = true;
    });

    try {
      final snapshotPlantDetails =
          await _firestore.collection('plantDetails').get();
      final snapshotHealthcare =
          await _firestore.collection('healthcare').get();

      setState(() {
        // Fetch data from 'plantDetails'
        final plantDetails = snapshotPlantDetails.docs.map((doc) {
          final advantages = doc.data()['advantages'] as String? ?? '';   
          final disadvantages = doc.data()['disadvantages'] as String? ?? '';
          return {
            'name': doc.id,
            'details':
                '$advantages $disadvantages', // Combine advantages and disadvantages
          };
        }).toList();

        // Fetch data from 'healthcare'
        final healthcareDetails = snapshotHealthcare.docs.map((doc) {
          final List<dynamic> treat =
              doc.data()['treat'] as List<dynamic>? ?? [];
          return {
            'name': doc.id,
            'details': treat.join(', '), // Join the list into a single string
          };
        }).toList();

        // Combine both collections
        _allPlants = [...plantDetails, ...healthcareDetails];
        _searchResults = _allPlants; // Initialize search results
        _isRetrieving = false;
      });
    } catch (e) {
      print("Error fetching plants: $e");
      setState(() {
        _isRetrieving = false;
      });
    }
  }

  void _searchPlants(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        if (query.isEmpty) {
          _searchResults = _allPlants;
        } else {
          _searchResults = _allPlants
              .where((plant) =>
                  plant['name']!.toLowerCase().contains(query.toLowerCase()) ||
                  plant['details']!.toLowerCase().contains(query.toLowerCase()))
              .toList();
        }
        _isSearching = false; // Stop the loading spinner
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Search Plants',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: _searchPlants,
              decoration: InputDecoration(
                hintText: 'Search for a plant or disease...',
                hintStyle:
                    TextStyle(color: const Color.fromARGB(255, 255, 207, 134)),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[800],
                suffixIcon: _isSearching
                    ? Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.orange),
                      )
                    : null,
              ),
              style: TextStyle(color: Colors.white),
              cursorColor: Colors.orange,
            ),
          ),
          Expanded(
            child: _isRetrieving
                ? Center(
                    child: CircularProgressIndicator(
                      color: Colors.orange,
                    ),
                  )
                : _searchResults.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'No matching plants found.',
                              style: TextStyle(color: Colors.white),
                            ),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                // Navigate to the chatbot page
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ChatBotScreen()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                              ),
                              child: Text('Ask the Chatbot'),
                            ),
                          ],
                        ),
                      )
                    : AnimationLimiter(
                        child: ListView.builder(
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            return AnimationConfiguration.staggeredList(
                              position: index,
                              duration: const Duration(milliseconds: 500),
                              child: SlideAnimation(
                                verticalOffset: 50.0,
                                child: FadeInAnimation(
                                  child: ListTile(
                                    title: Text(
                                      _searchResults[index]['name']!,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    subtitle: Text(
                                      _searchResults[index]['details']!,
                                      style: TextStyle(color: Colors.white70),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                    onTap: () {
                                      // Navigate to PlantDetailPage or other details
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      backgroundColor: Colors.black,
    );
  }
}
