import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'plant_3d_view_page.dart'; // Import the 3D view page

class PlantDetailPage extends StatefulWidget {
  final String herbName;

  const PlantDetailPage({
    Key? key,
    required this.herbName,
  }) : super(key: key);

  @override
  _PlantDetailPageState createState() => _PlantDetailPageState();
}

class _PlantDetailPageState extends State<PlantDetailPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _currentIndex = 0;
  Map<String, dynamic>? plantData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPlantDetails();
  }

  Future<void> fetchPlantDetails() async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('plantDetails').doc(widget.herbName).get();

      if (snapshot.exists) {
        setState(() {
          plantData = snapshot.data() as Map<String, dynamic>;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching plant details: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (plantData == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            'No details available for ${widget.herbName}.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final images = List<String>.from(plantData!['images'] ?? []);
    final leafInfo = plantData!['leafInfo'] ?? 'No leaf information available';
    final rootInfo = plantData!['rootInfo'] ?? 'No root information available';
    final stemInfo = plantData!['stemInfo'] ?? 'No stem information available';
    final modelPath = plantData!['modelPath'];
    final mtlPath = plantData!['mtlPath'];
    final pngPath = plantData!['pngPath'];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(widget.herbName, style: TextStyle(color: Color(0xFFF39C12))),
        actions: [
          IconButton(
            icon: Icon(Icons.threed_rotation, color: Color(0xFFF39C12)),
            onPressed: () {
              List<String> missingFiles = [];
              if (modelPath == null) missingFiles.add('3D model (OBJ)');
              if (mtlPath == null) missingFiles.add('Material file (MTL)');
              if (pngPath == null) missingFiles.add('Texture file (PNG)');

              if (missingFiles.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Missing files: ${missingFiles.join(', ')}')),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Plant3DViewPage(
                      modelPath: modelPath,
                      mtlPath: mtlPath,
                      pngPath: pngPath,
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (images.isNotEmpty)
                Column(
                  children: [
                    CarouselSlider.builder(
                      itemCount: images.length,
                      itemBuilder: (context, index, realIndex) {
                        return CachedNetworkImage(
                          imageUrl: images[index],
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) {
                            print('Failed to load image: $url');
                            return Container(
                              color: Colors.grey,
                              child: Center(child: Text('Image not available')),
                            );
                          },
                        );
                      },
                      options: CarouselOptions(
                        height: 200.0,
                        autoPlay: true,
                        enlargeCenterPage: true,
                        enableInfiniteScroll: true,
                        onPageChanged: (index, reason) {
                          setState(() {
                            _currentIndex = index;
                          });
                        },
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(images.length, (index) {
                          return Container(
                            width: 30.0,
                            height: 4.0,
                            margin: EdgeInsets.symmetric(horizontal: 2.0),
                            decoration: BoxDecoration(
                              color: _currentIndex == index ? Colors.orange : Colors.grey,
                            ),
                          );
                        })),
                    SizedBox(height: 16.0),
                  ],
                )
              else
                Container(
                  height: 200.0,
                  color: Colors.grey,
                  child: Center(child: Text('No images available')),
                ),
              SizedBox(height: 16.0),
              _buildSection('Leaves', leafInfo, images.isNotEmpty ? images[0] : null),
              SizedBox(height: 16.0),
              _buildSection('Roots', rootInfo, images.length > 1 ? images[1] : null),
              SizedBox(height: 16.0),
              _buildSection('Stem', stemInfo, images.length > 2 ? images[2] : null),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String label, String info, String? imageUrl) {
    return Row(
      children: [
        if (imageUrl != null)
          Expanded(
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              height: 150,
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) {
                print('Failed to load image: $url');
                return Container(
                  height: 150,
                  color: Colors.grey,
                  child: Center(child: Text('Image not available')),
                );
              },
            ),
          ),
        SizedBox(width: 16.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 18.0,
                  color: Color(0xFFF39C12),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.0),
              Text(
                info,
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
