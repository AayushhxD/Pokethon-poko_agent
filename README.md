# Pokethon — poko_agent

Pokethon (poko_agent) is a Flutter/Dart project that provides an agent for Pokémon-themed functionality (UI, assets, and backend examples included). This README covers project setup, running locally, adding Pokémon images, and quick examples for showing sprites in the app.

> Note: This repository's primary language is Dart and it includes Flutter platform directories (android, ios, web). The instructions below assume you have Flutter installed.

---

## Table of contents

- About
- Features
- Prerequisites
- Quick setup
- Running the app
- Adding Pokémon images (assets)
- Example: show Pokémon sprites (network or assets)
- Backend / backend-example
- Contributing
- License & attribution
- Contact

---

## About

Pokethon is a learning/demo project to show how to build a Pokémon-style UI/agent in Flutter. It includes a frontend Flutter project and a `backend` / `backend-example` directory with supporting code or mock backends.

---

## Features

- Flutter app (multi-platform: Android, iOS, web, desktop)
- Example integration for Pokémon images (sprites)
- Backend example folder to demonstrate API usage (see `backend-example`)

---

## Prerequisites

- Flutter SDK (>= 3.x) and Dart (use `flutter --version` to check)
- Git
- For mobile testing: Android Studio or Xcode (macOS)
- For web: Chrome (recommended) or another browser supported by Flutter

Install Flutter: https://flutter.dev/docs/get-started/install

---

## Quick setup

1. Clone the repo
   git clone https://github.com/AayushhxD/Pokethon-poko_agent.git
2. Change directory
   cd Pokethon-poko_agent
3. Get dependencies
   flutter pub get

---

## Running the app

- Run on a connected device or emulator
  flutter run

- Run on web (Chrome)
  flutter run -d chrome

- Build an Android APK
  flutter build apk --release

- Build for iOS (macOS)
  flutter build ios --release

If you run into platform-specific issues, open the `android` or `ios` directories in Android Studio / Xcode and follow the platform tooling prompts.

---

## Adding Pokémon images (assets)

You have two primary options for using Pokémon images:

A. Use remote sprites from PokeAPI (no assets to add)
B. Add local images to `assets/images/` and reference them as assets

Recommended directory (create if missing):

- assets/images/pokemon/

Update `pubspec.yaml` to include the assets (example):

```yaml
flutter:
  uses-material-design: true

  assets:
    - assets/images/pokemon/
```

Then run:
flutter pub get

Place images like:
- assets/images/pokemon/bulbasaur.png
- assets/images/pokemon/charmander.png
- assets/images/pokemon/squirtle.png

Where to get sprites:
- PokeAPI sprites repository (public): https://github.com/PokeAPI/sprites
- Example direct sprite URL (network): https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png

Attribution:
- Sprites from PokeAPI are community-provided; check PokeAPI and the sprites repository for licensing and attribution.

---

## Example: show Pokémon sprites in Flutter

Network sprite (quick & no assets):
```dart
// example: display Bulbasaur (id=1)
Image.network('https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png');
```

Local asset sprite:
```dart
// pubspec.yaml must include the folder assets/images/pokemon/
// then add the file assets/images/pokemon/bulbasaur.png

Image.asset('assets/images/pokemon/bulbasaur.png');
```

Simple widget example:
```dart
import 'package:flutter/material.dart';

class PokemonTile extends StatelessWidget {
  final String name;
  final String spriteUrl; // or asset path

  const PokemonTile({required this.name, required this.spriteUrl, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Image.network(spriteUrl, width: 48, height: 48),
      title: Text(name),
    );
  }
}

// Use:
PokemonTile(
  name: 'Bulbasaur',
  spriteUrl: 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png',
),
```

---

## Example images (PokeAPI sprites)

Here are a few example sprites that you can use directly via network:

- Bulbasaur (id 1)  
  https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png

- Charmander (id 4)  
  https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/4.png

- Squirtle (id 7)  
  https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/7.png

You can embed these in the README (above) or load them into your app with Image.network.

---

## Backend / backend-example

There is a `backend` and a `backend-example` directory. Use them to host or run a mock API your app can talk to. Typical steps:

1. Inspect `backend-example` for README or server code.
2. Start the backend (instructions depend on language used in that folder).
3. Configure the frontend to point at the backend base URL (e.g., in a config file or environment variable).

If you want, I can open the `backend-example` folder and extract exact steps / run commands into this README.

---

## Contributing

1. Fork the repo
2. Create a branch (feature/your-feature)
3. Commit your changes
4. Push and open a pull request

Please include descriptive commit messages and update this README if you add new features or change asset locations.

---

## License & attribution

- No license file included in this repository. If you want this to be open source, add a LICENSE (MIT, Apache-2.0, etc.).
- Sprites used in examples come from PokeAPI / PokeAPI sprites repository — check their repo for attribution and licensing.

---

## Contact

Maintainer: AayushhxD (https://github.com/AayushhxD)

---

Happy coding! If you want, I can:
- Commit this README to a new branch and open a PR for you, or
- Add a sample `assets/images/pokemon/` folder with 3 example sprites (Bulbasaur/Charmander/Squirtle) directly into the repository.
