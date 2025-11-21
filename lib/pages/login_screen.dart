import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tutor_chat/model/User.dart';
import 'package:tutor_chat/pages/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 350,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  decoration: InputDecoration(border: OutlineInputBorder(), labelText: 'Seu nome', isDense: true),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: OutlinedButton(
                  onPressed: () {
                    registerUser();
                  },
                  child: const Text("Enviar"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> registerUser() async {
    try {
      final url = Uri.parse('http://127.0.0.1:5000/register-student');
      final name = _textController.text;
      final accountPayload = {'student_id': name.toLowerCase(), 'name': name};

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(accountPayload),
      );

      if (response.statusCode == 200) {
        final user = User(id: name.toLowerCase(), name: name);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen(user: user)));
      }
    } catch (e) {}
  }
}
