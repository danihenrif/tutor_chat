import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tutor_chat/model/message.dart';
import 'package:tutor_chat/pages/components/message_box.dart';
import 'package:http/http.dart' as http;
import 'package:tutor_chat/pages/video.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart'
    show YoutubePlayerController, YoutubePlayerParams, YoutubePlayer;

import '../model/User.dart';
import '../model/ViewedLessonsSumary.dart';
import '../model/course_data.dart';

class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final YoutubePlayerController _youtubeController = YoutubePlayerController(
    params: const YoutubePlayerParams(showControls: true, showFullscreenButton: true, mute: false),
  );

  CourseData? loadedCourseData;
  ViewedLessonsSummary? loadedLessonsSummary;

  Set<String> _viewedLessonIds = {};

  bool _isVideoSelected = false;

  final questionController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool isMinimized = false;

  String? errorMessage;

  int _totalLessonsCount = 0;
  int _completedLessonsCount = 0;
  int _progressPercentage = 0;

  List<Message> messages = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    questionController.dispose();
    _youtubeController.close();
    super.dispose();
  }

  void calculateProgress() {
    if (loadedCourseData == null) {
      setState(() {
        _totalLessonsCount = 0;
        _completedLessonsCount = 0;
        _progressPercentage = 0;
      });
      return;
    }

    int totalLessons = 0;
    for (var module in loadedCourseData!.modules) {
      totalLessons += module.lessons.length;
    }

    int completedLessons = _viewedLessonIds.length;

    double progressPercentage = 0.0;
    if (totalLessons > 0) {
      progressPercentage = (completedLessons / totalLessons) * 100;
    }

    int roundedPercentage = progressPercentage.round();

    setState(() {
      _totalLessonsCount = totalLessons;
      _completedLessonsCount = completedLessons;
      _progressPercentage = roundedPercentage;
    });

    if (kDebugMode) {
      print('Progresso Calculado: $roundedPercentage% (${completedLessons}/${totalLessons})');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final paddingHorizontal = screenWidth * 0.05;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        titleSpacing: 0,
        leadingWidth: paddingHorizontal + 48,
        leading: Padding(
          padding: EdgeInsets.only(left: paddingHorizontal),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFFAD69E9), Color(0xFF8B46D0), Color(0xFF3593EE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 3.0, offset: Offset(0, 3))],
            ),
            child: const Center(child: Icon(Icons.android_outlined, size: 32, color: Colors.white)),
          ),
        ),
        title: Padding(
          padding: EdgeInsets.only(left: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('RoboEdu', style: GoogleFonts.lexendDeca(fontWeight: FontWeight.bold)),
              Text(
                'Plataforma Educacional Inteligente',
                style: GoogleFonts.lexendDeca(fontSize: 12, fontWeight: FontWeight.w300, color: Colors.black),
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: paddingHorizontal),
            child: Row(
              children: [
                Icon(Icons.emoji_events),
                Text(" Progresso : $_progressPercentage%", style: GoogleFonts.lexendDeca(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 40.0, horizontal: paddingHorizontal),
        child: Row(
          children: [
            //Chat
            Expanded(
              flex: 1,
              child: Container(
                margin: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10.0, offset: Offset(0, 5))],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      //Tittle
                      Padding(
                        padding: const EdgeInsets.only(bottom: 40.0),
                        child: Row(
                          children: [
                            Icon(Icons.chat_bubble_outline),
                            Text(
                              ' Chat com RoboEdu',
                              style: GoogleFonts.lexendDeca(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      //Messages
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: messages.length,
                          reverse: false,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            final messageItem = messages[index];
                            return MessageBox(key: ValueKey(messageItem.creationDate), message: messageItem);
                          },
                        ),
                      ),
                      //Question field
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10.0),
                                  boxShadow: const [
                                    BoxShadow(color: Colors.black12, blurRadius: 10.0, offset: Offset(0, 5)),
                                  ],
                                ),
                                child: TextFormField(
                                  controller: questionController,
                                  textInputAction: TextInputAction.send,
                                  onFieldSubmitted: (value) {
                                    sendQuestion(value.trim());
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Faça uma pergunta...',
                                    isDense: false,
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.fromLTRB(12, 0, 0, 0),
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                sendQuestion(questionController.text.trim());
                              },
                              icon: Icon(Icons.keyboard_double_arrow_right_outlined, color: Color(0xFFAD69E9)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            //Video
            Expanded(
              flex: isMinimized ? 3 : 2,
              child: Container(
                margin: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10.0, offset: Offset(0, 5))],
                ),
                child: Video(isSomeVideoSelected: _isVideoSelected, youtubeController: _youtubeController),
              ),
            ),
            //Playist
            isMinimized
                ? SizedBox(
                    width: 70.0,
                    child: Container(
                      margin: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10.0, offset: Offset(0, 5))],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                isMinimized = !isMinimized;
                              });
                            },
                            icon: Icon(Icons.add, size: 30, color: Theme.of(context).primaryColor),
                          ),
                        ],
                      ),
                    ),
                  )
                : Expanded(
                    flex: 1,
                    child: Container(
                      margin: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10.0, offset: Offset(0, 5))],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 20.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.playlist_play_outlined),
                                      Text(
                                        ' Playlist do Curso ',
                                        style: GoogleFonts.lexendDeca(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        isMinimized = !isMinimized;
                                      });
                                    },
                                    child: Text("—", style: GoogleFonts.lexendDeca(fontSize: 16)),
                                  ),
                                ],
                              ),
                            ),
                            //CONTEÚDO DINÂMICO
                            Expanded(
                              child: Builder(
                                builder: (context) {
                                  if (loadedCourseData?.modules == null) {
                                    return const Center(child: Text("Nenhum módulo encontrado."));
                                  }

                                  List<Widget> displayWidgets = [];

                                  for (var module in loadedCourseData!.modules) {
                                    displayWidgets.add(
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
                                        child: Text(
                                          module.title.toUpperCase(),
                                          style: GoogleFonts.lexendDeca(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 14,
                                            color: Theme.of(context).primaryColor,
                                          ),
                                        ),
                                      ),
                                    );

                                    for (var lesson in module.lessons) {
                                      final bool isViewed = _viewedLessonIds.contains(lesson.lessonId);

                                      displayWidgets.add(
                                        ListTile(
                                          contentPadding: const EdgeInsets.only(left: 20.0, right: 8.0),

                                          leading: GestureDetector(
                                            child: Icon(
                                              isViewed ? Icons.check_circle : Icons.circle_outlined,
                                              color: isViewed ? Colors.green : Colors.grey,
                                            ),
                                            onTap: () {
                                              setState(() {
                                                isViewed
                                                    ? _viewedLessonIds.remove(lesson.lessonId)
                                                    : _viewedLessonIds.add(lesson.lessonId);
                                                calculateProgress();
                                              });

                                              final String newStatus = isViewed ? 'nao visto' : 'visto';
                                              completeOrIncompleteLesson(lesson.lessonId, newStatus);
                                            },
                                          ),

                                          title: GestureDetector(
                                            child: Text(
                                              lesson.title,
                                              style: GoogleFonts.lexendDeca(
                                                fontSize: 14,
                                                color: isViewed ? Colors.black54 : Colors.black,
                                              ),
                                            ),
                                            onTap: () {
                                              _playVideo(lesson.videoUrl);
                                            },
                                          ),
                                        ),
                                      );
                                    }

                                    displayWidgets.add(const Divider(height: 20, thickness: 1, color: Colors.black12));
                                  }
                                  return ListView(children: displayWidgets);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  void sendQuestion(String text) async {
    final trimmedText = text.trim();

    if (trimmedText.isNotEmpty) {
      final now = DateTime.now().toIso8601String();

      setState(() {
        messages.add(Message(creationDate: now, message: trimmedText, sender: SenderType.user));
        questionController.clear();
      });

      try {
        final response = await http.post(
          Uri.parse('http://127.0.0.1:5000/chat'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'pergunta': trimmedText}),
        );
        setState(() {
          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            final botResponse = data['resposta'];

            messages.add(
              Message(creationDate: DateTime.now().toIso8601String(), message: botResponse, sender: SenderType.bot),
            );
          } else {
            messages.add(
              Message(
                creationDate: DateTime.now().toIso8601String(),
                message: 'Erro do servidor: Status ${response.statusCode}. Tente novamente.',
                sender: SenderType.bot,
              ),
            );
          }
        });
      } catch (e) {
        setState(() {
          messages.add(
            Message(
              creationDate: DateTime.now().toIso8601String(),
              message: 'Erro de conexão: Não foi possível conectar ao RoboEdu. $e',
              sender: SenderType.bot,
            ),
          );
        });
      }
    }
  }

  Future<void> _loadInitialData() async {
    final url = Uri.parse('http://127.0.0.1:5000/course-data/${widget.user.id}');
    final url2 = Uri.parse('http://127.0.0.1:5000/get-viewed-lessons/${widget.user.id}');

    try {
      final responses = await Future.wait([
        http.get(url, headers: {'Content-Type': 'application/json'}),
        http.get(url2, headers: {'Content-Type': 'application/json'}),
      ]);

      final response1 = responses[0];
      final response2 = responses[1];

      if (response1.statusCode == 200 && response2.statusCode == 200) {
        final Map<String, dynamic> jsonResponse1 = json.decode(response1.body);
        final Map<String, dynamic> courseDataJson = jsonResponse1['course_data'] as Map<String, dynamic>;
        loadedCourseData = CourseData.fromJson(courseDataJson);

        final Map<String, dynamic> jsonResponse2 = json.decode(response2.body);
        loadedLessonsSummary = ViewedLessonsSummary.fromJson(jsonResponse2);

        setState(() {
          _viewedLessonIds = loadedLessonsSummary!.viewedLessons.toSet();
          messages = [
            Message(
              creationDate: DateTime.now().toIso8601String(),
              message:
                  '👋 Olá ${widget.user.name} ! Bem-vindo ao RoboEdu! Selecione uma aula na playlist ao '
                  'lado ou me pergunte sobre o conteúdo do curso. Estou aqui para ajudar! 🎓',
              sender: SenderType.bot,
            ),
          ];
        });
        calculateProgress();
      } else {
        print('Falha na requisição. Status 1: ${response1.statusCode}, Status 2: ${response2.statusCode}');
      }
    } catch (e) {
      print('❌ Erro durante o carregamento dos dados: $e');
    }
  }

  Future<void> completeOrIncompleteLesson(lessonId, status) async {
    try {
      final url = Uri.parse('http://127.0.0.1:5000/update-progress/${widget.user.id}');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"lesson_id": lessonId, "status": status}),
      );

      if (response.statusCode != 200 && kDebugMode) {
        print('Erro ao atualizar progresso no backend: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro de rede ao atualizar progresso: $e');
      }
    }
  }

  void _playVideo(String url) {
    String? id;
    Uri uri = Uri.parse(url);
    if (uri.queryParameters.containsKey('v')) {
      id = uri.queryParameters['v'];
    } else if (url.contains('youtu.be/')) {
      id = url.split('youtu.be/')[1];
    }

    if (id == null) {
      print("URL Inválida");
      return;
    }

    setState(() {
      _isVideoSelected = true;
      _youtubeController.loadVideoById(videoId: id!);
    });
  }
}
