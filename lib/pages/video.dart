import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Video extends StatefulWidget {
  final String title;

  const Video({super.key, required this.title});

  @override
  State<Video> createState() => _VideoState();
}

class _VideoState extends State<Video> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [Text(widget.title, style: GoogleFonts.lexendDeca(fontWeight: FontWeight.w600, fontSize: 14),)],
    );
  }
}
