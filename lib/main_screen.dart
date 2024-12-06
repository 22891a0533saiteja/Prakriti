import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

// Import your screens
import 'home_screen.dart';
import 'fav_screen.dart';
import 'search_screen.dart';
import 'chatbot_home.dart';
import 'tour_screen.dart';
import 'ProfileScreen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late stt.SpeechToText _speech; // Speech-to-text instance
  bool _isListening = false; // Track listening state
  String _command = ""; // Store spoken command

  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;

  final List<Widget> _pages = [
    HomePage(),
    FavoritesScreen(),
    SearchPage(),
    ChatBotScreen(),
    TourPage(),
    ProfilePage(),
  ];

  // Mapping voice commands to pages
  final Map<String, int> _voiceCommands = {
    "home": 0,
    "favourite": 1,
    "search": 2,
    "chatbot": 3,
    "tour": 4,
    "profile": 5,
  };

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _opacityAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Handle item tap (manual navigation)
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Start listening for voice commands
  void _startListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) => print('Status: $status'),
        onError: (error) => print('Error: $error'),
      );
      print("Speech-to-Text initialized: $available");

      if (available) {
        setState(() => _isListening = true);
        _speech.listen(onResult: (result) {
          print("Recognized words: ${result.recognizedWords}");
          setState(() {
            _command = result.recognizedWords.toLowerCase();
            _navigateByVoiceCommand(_command);
          });
        });
      } else {
        print("Speech recognition not available.");
      }
    }
  }

  // Stop listening
  void _stopListening() {
    if (_isListening) {
      _speech.stop();
      _animationController.reverse(); // Hide animation
      setState(() => _isListening = false);
    }
  }

  // Navigate based on voice command
  void _navigateByVoiceCommand(String command) {
    if (_voiceCommands.containsKey(command)) {
      setState(() {
        _selectedIndex = _voiceCommands[command]!;
        _stopListening(); // Stop listening after navigation
      });
    } else {
      print("Command not recognized: $command");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text(
      //     'Main Screen',
      //     style: TextStyle(color: Colors.orange),
      //     ),
      //   backgroundColor: Colors.black,
      // ),
      body: Stack(
        children: [
          _pages[_selectedIndex],
          
          Positioned(
            bottom: 50,
            right: 20,
            child: GestureDetector(
              onTap: () {
                if (_isListening) {
                  _stopListening();
                } else {
                  _startListening();
                }
              },
              child: AnimatedOpacity(
                opacity: _isListening ? 1.0 : 0.7,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _isListening ? Colors.grey : Colors.blueAccent,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 5,
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.mic,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isListening ? "Listening..." : "Voice",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat Bot',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.tour),
            label: 'Tour',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.verified_user),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
