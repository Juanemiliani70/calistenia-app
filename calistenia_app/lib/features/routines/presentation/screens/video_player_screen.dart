import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:calistenia_app/core/constants/app_colors.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String urlVideo;
  final String nombreEjercicio;

  const VideoPlayerScreen({
    super.key,
    required this.urlVideo,
    required this.nombreEjercicio,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late YoutubePlayerController _controller;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _inicializarPlayer();
  }

  void _inicializarPlayer() {
    // Extraer el ID del video desde la URL de YouTube
    final videoId = YoutubePlayerController.convertUrlToId(widget.urlVideo);

    if (videoId == null) {
      setState(() => _error = true);
      return;
    }

    _controller = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        mute: false,
      ),
    );
  }

  @override
  void dispose() {
    if (!_error) _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: AppColors.textPrimary,
        title: Text(
          widget.nombreEjercicio,
          style: const TextStyle(fontSize: 16),
        ),
      ),
      body: _error
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: AppColors.error, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'No se pudo cargar el video',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.urlVideo,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Reproductor embebido
                YoutubePlayer(
                  controller: _controller,
                  aspectRatio: 16 / 9,
                ),
                const SizedBox(height: 24),
                // Nombre del ejercicio debajo del video
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    widget.nombreEjercicio,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}