# 🚨 DetectaVio - AI-Powered Smart Surveillance System

A Flutter-based mobile application for real-time violence detection using AI-powered video analytics.

## 🎯 Project Overview

DetectaVio is an intelligent surveillance system that uses computer vision and deep learning to detect violent behavior and weapons in real-time. The system provides instant alerts and enables proactive safety measures through a cross-platform mobile application.

## ✨ Key Features

- 🔐 **Secure Authentication** - Firebase Authentication for user management
- 📱 **Cross-Platform** - Works on Android and iOS devices
- 🔔 **Real-time Notifications** - Firebase Cloud Messaging for instant alerts
- 🎥 **Video Integration** - Connect with IP cameras and surveillance systems
- 🧠 **AI-Powered Detection** - YOLO-based weapon detection and behavior analysis
- 📊 **Analytics Dashboard** - Review incidents and system performance

## 🛠 Tech Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Firebase (Authentication, Cloud Messaging, Storage)
- **AI Models**: YOLO, TensorFlow
- **Video Processing**: Edge computing with local AI processing

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Android Studio / VS Code
- Firebase project setup
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Bishoy-Maged/DetectaVio.git
   cd DetectaVio
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   
   **Important**: You need to set up Firebase configuration files before running the app.
   
   a. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
   
   b. Add your Android and iOS apps to the Firebase project
   
   c. Download the configuration files:
      - `google-services.json` → Place in `android/app/`
      - `GoogleService-Info.plist` → Place in `ios/Runner/`
   
   d. Generate Firebase options:
      ```bash
      flutterfire configure
      ```
      This will create `lib/firebase_options.dart`

4. **Run the application**
   ```bash
   flutter run
   ```

## 📁 Project Structure

```
lib/
├── auth_service.dart          # Firebase Authentication
├── main.dart                  # App entry point
├── firebase_options.dart      # Firebase configuration (generated)
├── screens/                   # UI screens
│   ├── splash_screen.dart
│   ├── signin_screen.dart
│   ├── signup_screen.dart
│   ├── home_screen.dart
│   └── ...
└── ...
```

## 🔐 Security Notes

- **Never commit** `google-services.json`, `GoogleService-Info.plist`, or `firebase_options.dart` to version control
- These files contain sensitive API keys and are automatically ignored by `.gitignore`
- Use the provided example files (`*.example`) as templates for your own configuration

## 👥 Team

- **Maria Mohsen** - Team Leader & Frontend Developer
- **Verena Azer & Gena Ghats** - AI Model Development
- **Beshoy Maged** - Flutter Mobile Developer
- **Dr. Dalia Sameh** - Project Supervisor

## 📄 License

This project is part of a graduation project. All rights reserved.

## 🤝 Contributing

This is a graduation project repository. For questions or collaboration, please contact the development team.

---

**Built with ❤️ for safer environments through AI-powered surveillance**
