import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'plant_detail_page.dart';

class CategoryDetailPage extends StatefulWidget {
  final String category;
  final List<String> herbs;

  const CategoryDetailPage({
    Key? key,
    required this.category,
    required this.herbs,
  }) : super(key: key);

  @override
  _CategoryDetailPageState createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Future<Map<String, dynamic>> _herbDetailsFuture;

  @override
  void initState() {
    super.initState();
    _herbDetailsFuture = _fetchHerbDetails();
  }

  Future<Map<String, dynamic>> _fetchHerbDetails() async {
    final herbDetails = <String, dynamic>{};
    for (var herb in widget.herbs) {
      final docSnapshot = await _firestore.collection('plantDetails').doc(herb).get();
      herbDetails[herb] = docSnapshot.data();
    }
    return herbDetails;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFFF39C12)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(widget.category, style: TextStyle(color: Color(0xFFF39C12))),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _herbDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.white)));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No details available.', style: TextStyle(color: Colors.white)));
          }

          final herbDetails = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: widget.herbs.length,
              itemBuilder: (context, index) {
                final herbName = widget.herbs[index];
                final details = herbDetails[herbName] ?? {};

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      color: Colors.grey[800],
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundImage: details['images'] != null && details['images'].isNotEmpty
                              ? AssetImage(details['images'][0])
                              : AssetImage('assets/herbi.png'),
                          backgroundColor: Colors.transparent,
                        ),
                        title: Text(
                          herbName,
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PlantDetailPage(
                                herbName: herbName, // Passing the herb name to PlantDetailPage
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
