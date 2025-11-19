import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class Video extends StatelessWidget {
  final bool isSomeVideoSelected;
  final YoutubePlayerController? youtubeController;

  const Video({
    super.key,
    required this.isSomeVideoSelected,
    required this.youtubeController,
  });

  @override
  Widget build(BuildContext context) {
    return isSomeVideoSelected && youtubeController != null
        ? ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: YoutubePlayer(
        controller: youtubeController!,
        aspectRatio: 4 / 3,
      ),
    )
        : Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Icon(Icons.ondemand_video, size: 60, color: Colors.grey[400])
        ),
        Text(
          "Nenhum vídeo selecionado",
          style: GoogleFonts.lexendDeca(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey[600]),
        ),
        Text(
            "Escolha uma aula da playlist para começar",
            style: GoogleFonts.lexendDeca(fontSize: 14, color: Colors.grey[500])
        ),
      ],
    );
  }
}