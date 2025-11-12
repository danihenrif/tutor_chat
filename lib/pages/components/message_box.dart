import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tutor_chat/model/message.dart';

class MessageBox extends StatefulWidget {
  final Message message;

  const MessageBox({super.key, required this.message});

  @override
  State<MessageBox> createState() => _MessageBoxState();
}

class _MessageBoxState extends State<MessageBox> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: widget.message.sender == SenderType.bot ? MainAxisAlignment.start : MainAxisAlignment.end,
      children: [
        widget.message.sender == SenderType.bot
            ? Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFFAD69E9), Color(0xFF8B46D0), Color(0xFF3593EE)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 3.0, offset: Offset(0, 3))],
                ),
                child: const Center(child: Icon(Icons.android_outlined, size: 20, color: Colors.white)),
              )
            : Text("Você:", style: GoogleFonts.lexendDeca(fontSize: 14, fontWeight: FontWeight.bold)),
        Flexible(
          child: Container(
            margin: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10.0, offset: Offset(0, 5))],
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(widget.message.message),
              // AnimatedTextKit(
              //   animatedTexts: [
              //     TypewriterAnimatedText(
              //       widget.message.message,
              //       textAlign: TextAlign.start,
              //       textStyle: TextStyle(
              //         fontSize: 14.0,
              //         fontWeight: FontWeight.w300,
              //         color: Colors.black,
              //       ),
              //       speed: const Duration(milliseconds: 35),
              //     ),
              //   ],
              //   isRepeatingAnimation: false,
              // ),
            ),
          ),
        ),
      ],
    );
  }
}
