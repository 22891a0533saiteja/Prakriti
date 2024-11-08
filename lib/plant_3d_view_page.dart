import 'package:flutter/material.dart';
import 'package:flutter_cube/flutter_cube.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:vector_math/vector_math_64.dart' as vm;

class Plant3DViewPage extends StatefulWidget {
  final String modelPath;
  final String mtlPath;
  final String pngPath;

  const Plant3DViewPage({
    Key? key,
    required this.modelPath,
    required this.mtlPath,
    required this.pngPath,
  }) : super(key: key);

  @override
  _Plant3DViewPageState createState() => _Plant3DViewPageState();
}

class _Plant3DViewPageState extends State<Plant3DViewPage> {
  late String localModelPath;
  late String localMtlPath;
  late String localPngPath;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    downloadFiles();
  }

  Future<void> downloadFiles() async {
    Directory tempDir = await getTemporaryDirectory();
    localModelPath = '${tempDir.path}/model.obj';
    localMtlPath = '${tempDir.path}/model.mtl';
    localPngPath = '${tempDir.path}/texture.png';

    await _downloadFile(widget.modelPath, localModelPath);
    await _downloadFile(widget.mtlPath, localMtlPath);
    await _downloadFile(widget.pngPath, localPngPath);

    setState(() {
      isLoading = false; // Update loading status
    });
  }

  Future<void> _downloadFile(String url, String localPath) async {
    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        File file = File(localPath);
        await file.writeAsBytes(response.bodyBytes);
        print('Downloaded file: $localPath');

        // Check if file exists and print its size
        if (await file.exists()) {
          final fileSize = await file.length();
          print('File size: $fileSize bytes');
        }
      } else {
        setState(() {
          errorMessage = "Failed to download file: $url (Status Code: ${response.statusCode})";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error downloading file: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('3D View'),
        backgroundColor: Colors.black,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(child: Text(errorMessage!, style: TextStyle(color: Colors.red)))
          : Cube(
        onSceneCreated: (scene) {
          scene.world.add(Object(
            fileName: localModelPath,
            scale: vm.Vector3(1.0, 1.0, 1.0),
          ));
          scene.camera.position.z = 5;

          // Make sure the MTL file is referenced correctly in the OBJ file
        },
      ),
    );
  }
}
