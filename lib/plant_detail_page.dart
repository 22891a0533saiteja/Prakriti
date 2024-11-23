import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'plant_3d_view_page.dart'; // Import the 3D view page

class PlantDetailPage extends StatefulWidget {
  final String herbName;

  const PlantDetailPage({
    super.key,
    required this.herbName,
  });

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
        print("Fetched plantData: $plantData"); // Debug log
      } else {
        setState(() {
          isLoading = false;
        });
        print("No data found for herbName: ${widget.herbName}");
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
      return const Scaffold(
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
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final images = List<String>.from(plantData!['images'] ?? []);
    final leafInfo = plantData!['leafInfo'] ?? 'No leaf information available';
    final rootInfo = plantData!['rootInfo'] ?? 'No root information available';
    final stemInfo = plantData!['stemInfo'] ?? 'No stem information available';
    final advantages = plantData!['advantages'] ?? 'No advantages information available';
    final disadvantages = plantData!['disadvantages'] ?? 'No disadvantages information available';
    final medicinalUses = plantData!['medicinalUses'] ?? 'No medicinal uses information available';
    final medicinalVideos = List<String>.from(plantData!['medicinalVideos'] ?? []);
    final modelPath = plantData!['modelPath'];
    final mtlPath = plantData!['mtlPath'];
    final pngPath = plantData!['pngPath'];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(widget.herbName, style: const TextStyle(color: Color(0xFFF39C12))),
        actions: [
          IconButton(
            icon: const Icon(Icons.threed_rotation, color: Color(0xFFF39C12)),
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
                          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) {
                            print('Failed to load image: $url');
                            return Container(
                              color: Colors.grey,
                              child: const Center(child: Text('Image not available')),
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
                    const SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(images.length, (index) {
                        return Container(
                          width: 30.0,
                          height: 4.0,
                          margin: const EdgeInsets.symmetric(horizontal: 2.0),
                          decoration: BoxDecoration(
                            color: _currentIndex == index ? Colors.orange : Colors.grey,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 16.0),
                  ],
                )
              else
                Container(
                  height: 200.0,
                  color: Colors.grey,
                  child: const Center(child: Text('No images available')),
                ),
              const SizedBox(height: 16.0),
              _buildSection('Latin Name', plantData!['latinName'] ?? 'No Latin name available', null),
              const SizedBox(height: 16.0),
              _buildSection('Leaves', leafInfo, images.isNotEmpty ? images[0] : null),
              const SizedBox(height: 16.0),
              _buildSection('Roots', rootInfo, images.length > 1 ? images[1] : null),
              const SizedBox(height: 16.0),
              _buildSection('Stem', stemInfo, images.length > 2 ? images[2] : null),
              const SizedBox(height: 16.0),
              _buildTextSection('Advantages', advantages),
              const SizedBox(height: 16.0),
              _buildTextSection('Disadvantages', disadvantages),
              const SizedBox(height: 16.0),
              _buildTextSection('Medicinal Uses', medicinalUses),
              const SizedBox(height: 16.0),
              if (medicinalVideos.isNotEmpty) _buildVideosSection(medicinalVideos),
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
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) {
                print('Failed to load image: $url');
                return Container(
                  height: 150,
                  color: Colors.grey,
                  child: const Center(child: Text('Image not available')),
                );
              },
            ),
          ),
        const SizedBox(width: 16.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 18.0,
                  color: Color(0xFFF39C12),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                info,
                style: const TextStyle(
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

  Widget _buildTextSection(String label, String info) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 18.0,
            color: Color(0xFFF39C12),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          info,
          style: const TextStyle(
            fontSize: 16.0,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildVideosSection(List<String> videoUrls) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Medicinal Videos',
          style: TextStyle(
            fontSize: 18.0,
            color: Color(0xFFF39C12),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8.0),
        Column(
          children: videoUrls.map((videoUrl) {
            final videoId = YoutubePlayer.convertUrlToId(videoUrl);
            if (videoId == null) {
              print("Invalid video URL: $videoUrl");
              return const Text('Invalid video URL');
            }
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: YoutubePlayer(
                controller: YoutubePlayerController(
                  initialVideoId: videoId,
                  flags: const YoutubePlayerFlags(
                    autoPlay: true,
                    mute: false,
                  ),
                ),
                showVideoProgressIndicator: true,
                progressIndicatorColor: Colors.amber,
                progressColors: ProgressBarColors(
                  playedColor: Colors.amber,
                  handleColor: Colors.amberAccent,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
