import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:url_launcher/url_launcher.dart';

class PinnedScreen extends StatefulWidget {
  const PinnedScreen({super.key});

  @override
  State<PinnedScreen> createState() => _PinnedScreenState();
}

class _PinnedScreenState extends State<PinnedScreen> {
  List<dynamic> pinnedVideos = [];
  Set<String> pinnedIds = {};
  Map<String, Uint8List?> videoThumbnails = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPinnedVideos();
  }

  Future<void> loadPinnedVideos() async {
    setState(() {
      isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList('pinned')?.toSet() ?? {};
    print("📌 Loaded pinned video IDs: $ids");

    final response = await http.get(Uri.parse(
        "https://eed2-2c0f-fc89-8090-bc7c-8440-5205-f15d-b3d4.ngrok-free.app/Graduation%20project/Backend/Login/get_videos_api.php"));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data["status"] == "success") {
        final allVideos = data["videos"];
        final filtered = allVideos.where((video) {
          final vid = video["video_id"].toString();
          return ids.contains(vid);
        }).toList();

        setState(() {
          pinnedVideos = filtered;
          pinnedIds = ids;
          isLoading = false;
        });

        // Generate thumbnails
        for (var video in filtered) {
          final url = video["video_url"];
          final id = video["video_id"].toString();
          _generateThumbnail(url, id);
        }
      } else {
        print("❌ Error: ${data["message"]}");
      }
    } else {
      print("❌ HTTP error: ${response.statusCode}");
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
      print('Error generating thumbnail: $e');
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch video URL')),
      );
    }
  }

  Future<void> unpinVideo(String videoId) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      pinnedIds.remove(videoId);
      prefs.setStringList('pinned', pinnedIds.toList());
    });
    loadPinnedVideos();
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
          color: const Color(0xFF0B2545),
          backgroundColor: const Color(0xFFEEF4ED),
          onRefresh: loadPinnedVideos,
          child: ListView.builder(
            itemCount: pinnedVideos.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: Center(
                    child: Text(
                      "Pinned Videos",
                      style: TextStyle(
                        color: Color(0xFFEEF4ED),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }

              final video = pinnedVideos[index - 1];
              final videoId = video["video_id"].toString();
              final thumbnail = videoThumbnails[videoId];

              return GestureDetector(
                onTap: () => _openVideoInBrowser(video["video_url"]),
                child: Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
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
                            borderRadius:
                            BorderRadius.circular(8.0),
                            child: Image.memory(
                              thumbnail,
                              fit: BoxFit.cover,
                            ),
                          )
                              : const Icon(Icons.videocam,
                              color: Colors.white),
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
                                    icon: const Icon(
                                      Icons.remove_circle,
                                      color: Colors.redAccent,
                                    ),
                                    onPressed: () {
                                      unpinVideo(videoId);
                                    },
                                  ),
                                ],
                              ),
                              Text("ID: $videoId",
                                  style: const TextStyle(
                                      color: Color(0xFFEEF4ED))),
                              Text(
                                  "Alert Time: ${video["alert_time"] ?? "N/A"}",
                                  style: const TextStyle(
                                      color: Color(0xFFEEF4ED))),
                              if (video["comment_text"] != null)
                                Text("Comment: ${video["comment_text"]}",
                                    style: const TextStyle(
                                        color: Color(0xFFEEF4ED))),
                              if (video["report_text"] != null)
                                Text(
                                    "Violence Report: ${video["report_text"]}",
                                    style: const TextStyle(
                                        color: Color(0xFFEEF4ED))),
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
