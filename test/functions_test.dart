import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final player = AudioPlayer();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MusicAppHome(),
    );
  }
}

class MusicAppHome extends StatefulWidget {
  const MusicAppHome({super.key});

  @override
  State<MusicAppHome> createState() => _MusicAppHomeState();
}

class _MusicAppHomeState extends State<MusicAppHome> {
  String currentReason = "";
  String? currentImagePath;
  String? errorMessage;

  Future<Position> _getCurrentPosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw '位置情報サービスが無効です。';
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw '位置情報の許可が拒否されました。';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw '位置情報の許可が永久に拒否されています。';
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> checkConditionsAndPlayMusic(Position position) async {
    if (!mounted) return;

    try {
      bool isStation = await _checkPlace(
        'https://asia-northeast1-musicapp-9800a.cloudfunctions.net/getNearbyPlaces?lat=${position.latitude}&lng=${position.longitude}&type=train_station',
      );
      bool isStore = await _checkPlace(
        'https://asia-northeast1-musicapp-9800a.cloudfunctions.net/getNearbyPlaces?lat=${position.latitude}&lng=${position.longitude}&type=store',
      );

      String musicFile;
      String imagePath;
      String reason;

      if (isStation) {
        musicFile = 'music/station_music.mp3';
        imagePath = 'assets/images/station_image.png';
        reason = "駅の近く";
      } else if (isStore) {
        musicFile = 'music/shop_music.mp3';
        imagePath = 'assets/images/shop_image.png';
        reason = "店舗の近く";
      } else {
        musicFile = 'music/residential_music.mp3';
        imagePath = 'assets/images/residential_image.png';
        reason = "住宅街エリア";
      }

      setState(() {
        currentReason = reason;
        currentImagePath = imagePath;
        errorMessage = null;
      });

      await _playMusicWithFade(musicFile);
    } catch (e) {
      setState(() {
        errorMessage = 'エラー: $e';
      });
    }
  }

  Future<bool> _checkPlace(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse['results'].isNotEmpty;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> _playMusicWithFade(String path) async {
    try {
      await player.setReleaseMode(ReleaseMode.loop);
      await _fadeOutMusic();
      await player.play(AssetSource(path));
      await _fadeInMusic();
    } catch (e) {
      setState(() {
        errorMessage = '音楽再生エラー: $e';
      });
    }
  }

  Future<void> _fadeOutMusic() async {
    for (double volume = 1.0; volume > 0; volume -= 0.1) {
      await player.setVolume(volume);
      await Future.delayed(const Duration(milliseconds: 100));
    }
    await player.stop();
  }

  Future<void> _fadeInMusic() async {
    for (double volume = 0.0; volume <= 1.0; volume += 0.1) {
      await player.setVolume(volume);
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  void stopMusic() {
    player.stop();
    setState(() {
      currentReason = "";
      currentImagePath = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('音楽アプリ')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (errorMessage != null)
              Text(
                errorMessage!,
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            if (currentImagePath != null)
              Image.asset(currentImagePath!, width: 300, height: 300),
            Text(
              '再生理由: $currentReason',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  Position position = await _getCurrentPosition();
                  await checkConditionsAndPlayMusic(position);
                } catch (e) {
                  setState(() {
                    errorMessage = 'エラー: $e';
                  });
                }
              },
              child: const Text('音楽を再生する'),
            ),
            ElevatedButton(
              onPressed: stopMusic,
              child: const Text('音楽を止める'),
            ),
          ],
        ),
      ),
    );
  }
}