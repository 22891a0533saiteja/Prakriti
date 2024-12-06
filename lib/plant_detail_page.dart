import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:translator/translator.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'plant_3d_view_page.dart';
import 'chatbot_home.dart';

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
  final translator = GoogleTranslator();

  Map<String, dynamic>? plantData;
  Map<String, dynamic>? originalPlantData;
  bool isLoading = true;

  String selectedLanguage = 'en';
  final Map<String, String> languageMap = {
    'English': 'en',
    'Spanish': 'es',
    'French': 'fr',
    'Hindi': 'hi',
    'Tamil': 'ta',
    'Kannada': 'kn',
  };

  List<QueryDocumentSnapshot>? treatments;
  Map<String, bool> expandedState = {}; // Tracks expanded state for treatments
  bool isLoadingTreatments = true;

  @override
  void initState() {
    super.initState();
    fetchPlantDetails();
  }

  Future<void> fetchPlantDetails() async {
    try {
      DocumentSnapshot snapshot = await _firestore
          .collection('plantDetails')
          .doc(widget.herbName)
          .get();

      if (snapshot.exists) {
        setState(() {
          originalPlantData = snapshot.data() as Map<String, dynamic>;
          plantData = Map<String, dynamic>.from(originalPlantData!);
          isLoading = false;
        });
        fetchTreatments();
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

  Future<void> fetchTreatments() async {
    try {
      final snapshot = await _firestore
          .collection('plantDetails')
          .doc(widget.herbName)
          .collection('treatments')
          .get();

      setState(() {
        treatments = snapshot.docs;
        isLoadingTreatments = false;
        for (var treatment in treatments!) {
          expandedState[treatment.id] = false;
        }
      });
    } catch (e) {
      print('Error fetching treatments: $e');
      setState(() {
        isLoadingTreatments = false;
      });
    }
  }

  Future<String> translateText(String text, String targetLang) async {
    try {
      const placeholder = '\n';
      final preprocessedText = text.replaceAll('trigger', placeholder);

      if (targetLang == 'en') {
        return preprocessedText.replaceAll(placeholder, 'trigger');
      }

      final translated = await translator.translate(preprocessedText, to: targetLang);

      return translated.text.replaceAll(placeholder, 'trigger');
    } catch (e) {
      print("Translation error: $e");
      return text; // Return original text if translation fails
    }
  }

  List<String> processText(String text) {
    return text.split('trigger').map((line) => line.trim()).toList();
  }

  Future<void> translateData() async {
    if (originalPlantData == null || selectedLanguage == 'en') {
      setState(() {
        plantData = Map<String, dynamic>.from(originalPlantData!);
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    plantData = {
      for (var entry in originalPlantData!.entries)
        entry.key: entry.value is String
            ? await translateText(entry.value as String, selectedLanguage)
            : entry.value is List<String>
            ? await translateList(entry.value as List<String>, selectedLanguage)
            : entry.value,
    };

    setState(() {
      isLoading = false;
    });
  }

  Future<List<String>> translateList(List<String> texts, String targetLang) async {
    return Future.wait(texts.map((text) => translateText(text, targetLang)));
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
    final leafInfo =
    processText(plantData!['leafInfo'] ?? 'No leaf information available');
    final rootInfo =
    processText(plantData!['rootInfo'] ?? 'No root information available');
    final stemInfo =
    processText(plantData!['stemInfo'] ?? 'No stem information available');
    final advantages = processText(
        plantData!['advantages'] ?? 'No advantages information available');
    final disadvantages = processText(plantData!['disadvantages'] ??
        'No disadvantages information available');
    final medicinalUses = processText(plantData!['medicinalUses'] ??
        'No medicinal uses information available');
    final growCultivate = processText(
        plantData!['growCultivate'] ?? 'No cultivation information available');
    final medicinalVideos =
    List<String>.from(plantData!['medicinalVideos'] ?? []);

    // Dropdown for language selection
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.green.shade800,
        title: Text(widget.herbName, style: const TextStyle(color: Color(0xFFF39C12) , fontWeight: FontWeight.bold)),
        actions: [
          DropdownButton<String>(
            value: selectedLanguage,
            icon: const Icon(Icons.language, color: Color(0xFFF39C12)),
            onChanged: (String? newValue) {
              setState(() {
                selectedLanguage = newValue!;
                isLoading = true;
              });
              translateData();
            },
            items: languageMap.keys.map<DropdownMenuItem<String>>((String lang) {
              return DropdownMenuItem<String>(
                value: languageMap[lang]!,
                child: Text(lang, style: const TextStyle(color: Colors.white)),
              );
            }).toList(),
          ),
          IconButton(
            icon: const Icon(Icons.threed_rotation, color: Color(0xFFF39C12)),
            onPressed: () {
              // Navigate to 3D view page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Plant3DViewPage(
                    herbName: widget.herbName,
                    modelPath: 'assets/${widget.herbName.toLowerCase()}/model.obj',
                    mtlPath: 'assets/${widget.herbName.toLowerCase()}/model.mtl',
                    pngPath: 'assets/${widget.herbName.toLowerCase()}/texture.png',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          if (images.isNotEmpty)
            CarouselSlider(
              items: images.map((image) {
                return GestureDetector(
                  onTap: () {
                    // Open image in full-screen viewer if needed
                  },
                  child: CachedNetworkImage(
                    imageUrl: image,
                    placeholder: (context, url) => const CircularProgressIndicator(),
                    errorWidget: (context, url, error) {
                      return const Center(child: Text('Image not available'));
                    },
                  ),
                );
              }).toList(),
              options: CarouselOptions(
                autoPlay: true,
                height: 200.0,
                enlargeCenterPage: true,
                aspectRatio: 16 / 9,
                viewportFraction: 0.8,
                scrollPhysics: BouncingScrollPhysics(),
              ),
            ),
          _buildSection('Leaf Information', leafInfo.join('\n')),
          _buildSection('Root Information', rootInfo.join('\n')),
          _buildSection('Stem Information', stemInfo.join('\n')),
          _buildSection('Advantages', advantages.join('\n')),
          _buildSection('Disadvantages', disadvantages.join('\n')),
          _buildSection('Medicinal Uses', medicinalUses.join('\n')),
          _buildSection('Grow & Cultivate', growCultivate.join('\n')),
          _buildVideosSection(medicinalVideos),
        ],
      ),
    );
  }

  Widget _buildSection(String label, String info) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          Text(info, style: const TextStyle(fontSize: 14, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildVideosSection(List<String> medicinalVideos) {
    if (medicinalVideos.isEmpty) {
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Medicinal Use Videos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          for (var videoUrl in medicinalVideos) _buildVideoPlayer(videoUrl),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer(String videoUrl) {
    final youtubeId = YoutubePlayer.convertUrlToId(videoUrl);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: youtubeId == null
          ? const Text('Invalid video URL')
          : YoutubePlayer(
        controller: YoutubePlayerController(
          initialVideoId: youtubeId,
          flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
        ),
      ),
    );
  }
}
