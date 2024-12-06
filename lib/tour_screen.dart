import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'CategoryDetailPage.dart'; // Import the new page

class TourPage extends StatefulWidget {
  @override
  _TourPageState createState() => _TourPageState();
}

class _TourPageState extends State<TourPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Future<Map<String, List<String>>> _categoryHerbsFuture;

  @override
  void initState() {
    super.initState();
    _categoryHerbsFuture = _fetchCategoryHerbs();
  }

  Future<Map<String, List<String>>> _fetchCategoryHerbs() async {
    final categoryHerbs = <String, List<String>>{};
    final snapshot = await _firestore.collection('herbCategories').get();

    for (var doc in snapshot.docs) {
      final category = doc.id;
      final herbs = List<String>.from(doc.data()['herbs'] ?? []);
      categoryHerbs[category] = herbs;
    }
    return categoryHerbs;
  }

  @override
  @override
Widget build(BuildContext context) {
  final List<String> gifPaths = [
    'assets/gif1.gif', // Path to the first GIF
    'assets/gif2.gif', // Path to the second GIF
    'assets/gif3.gif', // Path to the third GIF
    'assets/gif4.gif', // Path to the fourth GIF
  ];

  return Scaffold(
    backgroundColor: const Color(0xFF000000),
    appBar: AppBar(
      title: const Text("Herb Plant Categories"),
      backgroundColor: Colors.black,
    ),
    body: FutureBuilder<Map<String, List<String>>>(
      future: _categoryHerbsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No categories found'));
        }

        final categoryHerbs = snapshot.data!;
        final herbCategories = categoryHerbs.keys.toList();

        return Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: herbCategories.asMap().entries.map((entry) {
                int index = entry.key;
                String category = entry.value;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30.0), // Space between categories
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CategoryDetailPage(
                                category: category,
                                herbs: categoryHerbs[category] ?? [],
                              ),
                            ),
                          );
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircleAvatar(
                              radius: 60, // Increased radius for bigger button
                              backgroundColor: Colors.orangeAccent.withOpacity(0.8),
                              child: ClipOval(
                                child: Image.asset(
                                  gifPaths[index % gifPaths.length], // Cycle through the GIFs
                                  fit: BoxFit.cover,
                                  width: 120, // Match the CircleAvatar size
                                  height: 120,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        category,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    ),
  );
}
}
