import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'dart:typed_data';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class VideosScreen extends StatefulWidget {
  const VideosScreen({super.key});

  @override
  State<VideosScreen> createState() => _VideosScreenState();
}

class _VideosScreenState extends State<VideosScreen> {
  List<dynamic> videos = [];
  Map<String, Uint8List?> videoThumbnails = {};
  Set<String> pinnedVideoIds = {};
  bool isLoading = true;
  StreamSubscription? _notificationSubscription;

  @override
  void initState() {
    super.initState();
    loadPinnedVideos();
    fetchVideos();
    _setupNotificationListener();
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }

  void _setupNotificationListener() {
    _notificationSubscription = FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.data['type'] == 'new_video') {
        // Refresh the video list when a new video notification is received
        fetchVideos();
      }
    });
  }

  Future<void> loadPinnedVideos() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      pinnedVideoIds = prefs.getStringList('pinned')?.toSet() ?? {};
    });
  }

  Future<void> togglePin(String videoId) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (pinnedVideoIds.contains(videoId)) {
        pinnedVideoIds.remove(videoId);
      } else {
        pinnedVideoIds.add(videoId);
      }
      prefs.setStringList('pinned', pinnedVideoIds.toList());
    });
  }

  Future<void> fetchVideos() async {
    try {
      setState(() {
        isLoading = true;
        videos.clear();
        videoThumbnails.clear();
      });

      final response = await http.get(Uri.parse(
          "https://eed2-2c0f-fc89-8090-bc7c-8440-5205-f15d-b3d4.ngrok-free.app/Graduation%20project/Backend/Login/get_videos_api.php"));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data["status"] == "success") {
          setState(() {
            videos = data["videos"];
            isLoading = false;
          });
          for (var video in data["videos"]) {
            _generateThumbnail(video["video_url"], video["video_id"].toString());
          }
        } else {
          throw Exception("Error: ${data["message"]}");
        }
      } else {
        throw Exception("Failed to load videos: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading videos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _generateThumbnail(String videoUrl, String videoId) async {
    try {
      final uint8list = await VideoThumbnail.thumbnailData(
        video: videoUrl,
        imageFormat: ImageFormat.PNG,
        maxWidth: 128,
        quality: 25,
      );
      if (mounted) {
        setState(() {
          videoThumbnails[videoId] = uint8list;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          videoThumbnails[videoId] = null;
        });
      }
    }
  }

  Future<void> _openVideoInBrowser(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch URL')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0B2545), Color(0xFF134074)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
            child: isLoading
                ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFEEF4ED)),
            )
                : RefreshIndicator(
              color: Color(0xFF0B2545),
              backgroundColor: Color(0xFFEEF4ED),
              onRefresh: fetchVideos,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: videos.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                      child: Center(
                        child: Text(
                          "Videos",
                          style: TextStyle(
                            color: Color(0xFFEEF4ED),
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }

                  final video = videos[index - 1];
                  final videoId = video["video_id"].toString();
                  final thumbnail = videoThumbnails[videoId];
                  final isPinned = pinnedVideoIds.contains(videoId);

                  return GestureDetector(
                    onTap: () {
                      _openVideoInBrowser(video["video_url"]);
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      color: const Color(0xFF1B3A5B),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 100,
                              height: 75,
                              decoration: BoxDecoration(
                                color: Colors.grey[700],
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: thumbnail != null
                                  ? ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.memory(thumbnail, fit: BoxFit.cover),
                              )
                                  : const Icon(Icons.videocam, color: Colors.white),
                            ),
                            const SizedBox(width: 12.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          video["video_name"],
                                          style: const TextStyle(
                                              color: Color(0xFFEEF4ED),
                                              fontWeight: FontWeight.bold),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                                          color: isPinned
                                              ? Colors.yellow
                                              : const Color(0xFFEEF4ED),
                                        ),
                                        onPressed: () {
                                          togglePin(videoId);
                                        },
                                      ),
                                    ],
                                  ),
                                  Text("ID: ${video["video_id"]}",
                                      style: const TextStyle(color: Color(0xFFEEF4ED))),
                                  Text("Alert Time: ${video["alert_time"] ?? "N/A"}",
                                      style: const TextStyle(color: Color(0xFFEEF4ED))),
                                  if (video["comment_text"] != null)
                                    Text("Comment: ${video["comment_text"]}",
                                        style: const TextStyle(color: Color(0xFFEEF4ED))),
                                  if (video["report_text"] != null)
                                    Text("Violence Report: ${video["report_text"]}",
                                        style: const TextStyle(color: Color(0xFFEEF4ED))),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            ),
        );
    }
}
