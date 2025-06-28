import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Player Test',
      theme: ThemeData.dark(),
      home: const VideoTestScreen(),
    );
  }
}

class VideoTestScreen extends StatefulWidget {
  const VideoTestScreen({super.key});

  @override
  State<VideoTestScreen> createState() => _VideoTestScreenState();
}

class _VideoTestScreenState extends State<VideoTestScreen> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool isLoading = true;
  bool hasError = false;

  final String testVideoUrl =
      "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4";

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    _videoPlayerController = VideoPlayerController.network(
      testVideoUrl,
      httpHeaders: {
        'Range': 'bytes=0-',
      },
    );

    try {
      await _videoPlayerController.initialize();
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: true,
        looping: false,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              'Error playing video: $errorMessage',
              style: const TextStyle(color: Colors.red),
            ),
          );
        },
      );
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error initializing video: $e');
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Player Test'),
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : hasError
            ? Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Failed to load video.',
              style: TextStyle(color: Colors.red, fontSize: 18),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _initializePlayer,
              child: const Text('Retry'),
            ),
          ],
        )
            : Chewie(controller: _chewieController!),
      ),
    );
  }
}
