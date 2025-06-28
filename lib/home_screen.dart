import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final List<String> imageUrls = [
    "https://esaweb.org/wp-content/uploads/2019/05/stop-violence.png",
    "https://shakirycharity.org/admin1/uploads/1523451076/op1.jpg",
    "https://sirixmonitoring.com/wp-content/uploads/2024/04/violence-detection-ai-graphics-01-660e75a6ce66f-scaled.webp",
  ];

  final List<BusinessCard> businessCards = const [
    BusinessCard(
      imageUrl: "https://www.gizchina.com/wp-content/uploads/images/2023/10/copilot-win-11-ftr-1200x764.webp",
      title: "DetectaVio Copilot",
      description: "Save time and focus on the things that matter most with AI in DetectaVio for business.",
      buttonText: "Learn more",
    ),
    BusinessCard(
      imageUrl: "https://images.mid-day.com/images/images/2017/feb/suitcase-cctv-m.jpg",
      title: "DetectaVio Insight",
      description: "AI-Powered Crime Analytics & Prevention. DetectaVio Insight analyzes security footage, detects threats, and provides predictive insights.",
      buttonText: "Explore DetectaVio Insight",
    ),
    BusinessCard(
      imageUrl: "https://www.techyv.com/sites/default/2023/06/users/Rajen/a-system-equipped-with-tpm.jpg",
      title: "DetectaVio Cloud PC",
      description: "Securely stream your Windows experience from the DetectaVio cloud to any device.",
      buttonText: "Get it today",
    ),
    BusinessCard(
      imageUrl: "https://www.asiainsurancereview.com/Portals/0/ImageLibrary/eDaily_News_Images/Agents/2019/Stock%20photos/35803571_m.jpg",
      title: "DetectaVio Viva",
      description: "Bring together connection, purpose, and insight with the first employee experience platform built for the hybrid era.",
      buttonText: "Learn more about DetectaVio Viva",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    const double cardWidth = 250;
    const double cardHeight = 370;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0B2545), Color(0xFF134074)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                "Services",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ServiceCard(
                          icon: Icons.remove_red_eye,
                          title: "Violence Detection",
                          description: "Detect violence or no violence between the people",
                        ),
                        const SizedBox(width: 16),
                        ServiceCard(
                          icon: Icons.notifications_active,
                          title: "Sending Alerts",
                          description: "Alerts to the camera’s user via the internet",
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ServiceCard(
                          icon: Icons.warning_amber,
                          title: "Stop Violence",
                          description: "Rapid intervention to calm the situation",
                        ),
                        const SizedBox(width: 16),
                        ServiceCard(
                          icon: Icons.smart_display,
                          title: "AI Video Analysis",
                          description: "AI-powered video recognition to enhance security",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              CarouselSlider(
                options: CarouselOptions(
                  height: 200,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 3),
                  enlargeCenterPage: true,
                  viewportFraction: 0.8,
                ),
                items: imageUrls.map((imageUrl) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 25),
              const Text(
                "For Business",
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  height: cardHeight,
                  child: CarouselSlider(
                    options: CarouselOptions(
                      height: cardHeight,
                      enlargeCenterPage: true,
                      enableInfiniteScroll: false,
                      viewportFraction: cardWidth / MediaQuery.of(context).size.width,
                    ),
                    items: businessCards.map((card) {
                      return Builder(
                        builder: (context) {
                          return SizedBox(
                            width: cardWidth,
                            height: cardHeight,
                            child: card,
                          );
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class ServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const ServiceCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 155,
      height: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 30, color: Colors.black),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

class BusinessCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String description;
  final String buttonText;

  const BusinessCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      elevation: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              imageUrl,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    )),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {},
                  child: Text(buttonText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
