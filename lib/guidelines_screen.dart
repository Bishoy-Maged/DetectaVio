import 'package:flutter/material.dart';

class GuidelinesScreen extends StatefulWidget {
  const GuidelinesScreen({super.key});

  @override
  State<GuidelinesScreen> createState() => _GuidelinesScreenState();
}

class _GuidelinesScreenState extends State<GuidelinesScreen> {
  final List<Map<String, String>> guidelines = [
    {
      'title': 'Stay Neutral',
      'image': 'images/Guidelines/guideline1.jpg',
      'description': 'If you are a bystander in a fight try to de-escalate the situation or separate the parties calmly.'
    },
    {
      'title': 'Let It Slide',
      'image': 'images/Guidelines/guideline2.jpg',
      'description': "If the conflict is minor, try to let it go and walk away. Keeping your cool is strength."
    },
    {
      'title': 'Seek Justice',
      'image': 'images/Guidelines/guideline3.jpg',
      'description': "If you're involved in the conflict and it's serious, consider taking legal action instead of responding with violence."
    },
    {
      'title': 'Avoid Strangers',
      'image': 'images/Guidelines/guideline4.jpg',
      'description': "Avoid engaging with people in public if their behavior seems suspicious or makes you feel unsafe."
    },
    {
      'title': 'Stay Alert',
      'image': 'images/Guidelines/guideline5.jpg',
      'description': "Always stay aware of your surroundings, especially in unfamiliar or isolated areas."
    },
    {
      'title': 'Trust Instincts',
      'image': 'images/Guidelines/guideline6.jpg',
      'description': "Trust your instincts—if something feels wrong , remove yourself from the situation."
    },
    {
      'title': 'Stay Calm',
      'image': 'images/Guidelines/guideline7.jpg',
      'description': "Avoid provoking or challenging aggressive individuals; staying calm."
    },
    {
      'title': 'Call the Police',
      'image': 'images/Guidelines/guideline8.jpg',
      'description': "Contact authorities immediately in emergencies."
    },
    {
      'title': 'Protect yourself',
      'image': 'images/Guidelines/guideline9.jpg',
      'description': "If you're recording an incident for evidence, stay at a safe distance and protect your identity."
    },
  ];

  void _showGuidelineDialog(String title, String description) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0B2545),
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFFEEF4ED),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          description,
          style: const TextStyle(
            color: Colors.white70,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: Color(0xFFEEF4ED)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B2545),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0B2545), Color(0xFF134074)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 20.0, bottom: 10),
                child: Center(
                  child: Text(
                    'Safety Guidelines',
                    style: const TextStyle(
                      color: Color(0xFFEEF4ED),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(12),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final item = guidelines[index];
                    return GestureDetector(
                      onTap: () => _showGuidelineDialog(
                        item['title']!,
                        item['description']!,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF0B2545),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                                child: Image.asset(
                                  item['image']!,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        color: Colors.grey[300],
                                        child: const Center(
                                          child: Icon(Icons.broken_image),
                                        ),
                                      ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                item['title']!,
                                style: const TextStyle(
                                  color: Color(0xFFEEF4ED),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: guidelines.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 3 / 2.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
