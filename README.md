# STAR AI Assistant

**S**mart **T**echnical **A**ssistant & **R**esponder

A Flutter-based AI voice assistant application that provides intelligent responses through voice interaction.

## Features

- 🎤 **Voice Recognition**: Speak to interact with the assistant
- 🤖 **AI-Powered Responses**: Powered by OpenAI GPT for intelligent conversations
- 🔊 **Text-to-Speech**: Hear responses spoken aloud
- 💬 **Conversation History**: Keep track of your conversation
- 🌙 **Premium Dark Theme**: Beautiful glassmorphism UI design

## Getting Started

### Prerequisites

- Flutter SDK (^3.5.1)
- Dart SDK
- Android Studio / VS Code
- An OpenAI API key

### Installation

1. Clone the repository:
```bash
git clone https://github.com/Nilanjan-Nayak/Star-Mobile-Assistant.git
cd Star-Mobile-Assistant
```

2. Copy the environment file and add your API key:
```bash
cp .env.example .env
# Edit .env and add your OpenAI API key
```

3. Install dependencies:
```bash
flutter pub get
```

4. Run the app:
```bash
flutter run
```

### Building for Release

```bash
flutter build apk --release
```

The APK will be available at `build/app/outputs/flutter-apk/app-release.apk`

## Technologies Used

- **Flutter** - Cross-platform mobile framework
- **Provider** - State management
- **OpenAI GPT** - AI language model
- **Speech-to-Text** - Voice recognition
- **Flutter TTS** - Text-to-speech

## License

This project is open source and available under the MIT License.

## Author

**Nilanjan Nayak** - Star Projects Lab
