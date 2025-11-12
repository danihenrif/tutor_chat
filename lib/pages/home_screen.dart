import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tutor_chat/model/message.dart';
import 'package:tutor_chat/pages/components/message_box.dart';
import 'package:http/http.dart' as http;

import '../model/student_data.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String mockJsonString = '''
{
  "student_id": "98765",
  "modules": [
    {
      "module_name": "Estruturas Fundamentais",
      "lessons": [
        {
          "lesson_name": "Pilhas e Filas",
          "video_link": "https://mock.link/pilhas",
          "view_status": 1
        },
        {
          "lesson_name": "Listas Ligadas",
          "video_link": "https://mock.link/listas",
          "view_status": 1
        }
      ]
    },
    {
      "module_name": "Árvores Binárias",
      "lessons": [
        {
          "lesson_name": "Conceitos Básicos de Árvores",
          "video_link": "https://mock.link/arvores/conceitos",
          "view_status": 0
        },
        {
          "lesson_name": "Busca em Largura (BFS)",
          "video_link": "https://mock.link/bfs",
          "view_status": 0
        }
      ]
    },
    {
      "module_name": "Busca e Hash",
      "lessons": [
        {
          "lesson_name": "Tabelas Hash e Colisões",
          "video_link": "https://mock.link/hash/tabelas",
          "view_status": 0
        },
        {
          "lesson_name": "Busca Binária Otimizada",
          "video_link": "https://mock.link/busca/binaria",
          "view_status": 0
        }
      ]
    },
    {
      "module_name": "Grafos e Redes",
      "lessons": [
        {
          "lesson_name": "Representação de Grafos",
          "video_link": "https://mock.link/grafos/rep",
          "view_status": 0
        },
        {
          "lesson_name": "Algoritmo de Dijkstra",
          "video_link": "https://mock.link/grafos/dijkstra",
          "view_status": 0
        }
      ]
    },
    {
      "module_name": "Algoritmos de Ordenação",
      "lessons": [
        {
          "lesson_name": "Merge Sort",
          "video_link": "https://mock.link/ordenacao/merge",
          "view_status": 1
        },
        {
          "lesson_name": "Quick Sort",
          "video_link": "https://mock.link/ordenacao/quick",
          "view_status": 0
        }
      ]
    },
    {
      "module_name": "Árvores Avançadas",
      "lessons": [
        {
          "lesson_name": "Árvores AVL",
          "video_link": "https://mock.link/avl",
          "view_status": 0
        },
        {
          "lesson_name": "Árvores B+",
          "video_link": "https://mock.link/bmais",
          "view_status": 0
        }
      ]
    },
    {
      "module_name": "Programação Dinâmica",
      "lessons": [
        {
          "lesson_name": "Introdução e Memoização",
          "video_link": "https://mock.link/dp/intro",
          "view_status": 0
        },
        {
          "lesson_name": "Problema da Mochila",
          "video_link": "https://mock.link/dp/mochila",
          "view_status": 0
        }
      ]
    },
    {
      "module_name": "Complexidade e P/NP",
      "lessons": [
        {
          "lesson_name": "Notação Big O ()",
          "video_link": "https://mock.link/bigo",
          "view_status": 1
        },
        {
          "lesson_name": "Classes P e NP",
          "video_link": "https://mock.link/pnp",
          "view_status": 0
        }
      ]
    },
    {
      "module_name": "Tópicos Especiais",
      "lessons": [
        {
          "lesson_name": "Estruturas de Dados Persistentes",
          "video_link": "https://mock.link/persistentes",
          "view_status": 0
        }
      ]
    }
  ]
}
''';

  final questionController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool isMinimized = false;

  StudentData? studentData;
  bool isLoadingCourse = true;
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
    super.dispose();
  }

  void calculateProgress() {
    if (studentData == null || studentData!.modules.isEmpty) {
      return;
    }

    int totalLessons = 0;
    int completedLessons = 0;

    for (var module in studentData!.modules) {
      for (var lesson in module.lessons) {
        totalLessons++;

        if (lesson.viewStatus == 1) {
          completedLessons++;
        }
      }
    }

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
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final paddingHorizontal = screenWidth * 0.05;

    final List<String> videoTitles = ["Lista Ligada (1/3)", "Lista Ligada (2/3)", "Lista Ligada (3/3)"];

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
        // leading: Padding(
        //   padding: EdgeInsets.only(left : paddingHorizontal),
        //   child: Icon(Icons.android_outlined, size: 48),
        // ),
        // leading: Padding(
        //   padding: EdgeInsets.only(left: paddingHorizontal),
        //   child: Image.asset('lib/assets/capelo.png'),
        // ),
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
                Text(" Progresso : ${_progressPercentage}%", style: GoogleFonts.lexendDeca(fontSize: 14)),
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(padding: const EdgeInsets.only(bottom: 8.0), child: Icon(Icons.ondemand_video, size: 60)),
                    Text(
                      "Nenhum vídeo selecionado",
                      style: GoogleFonts.lexendDeca(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Text("Escolha uma aula da playlist para começar", style: GoogleFonts.lexendDeca(fontSize: 14)),
                  ],
                ),
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
                                        isMinimized = !isMinimized; // Toggle logic
                                      });
                                    },
                                    child: Text("—", style: GoogleFonts.lexendDeca(fontSize: 16)),
                                  ),
                                ],
                              ),
                            ),
                            // CONTEÚDO DINÂMICO
                            Expanded(
                              child: isLoadingCourse
                                  ? const Center(child: CircularProgressIndicator())
                                  : errorMessage != null
                                  ? Center(child: Text(errorMessage!))
                                  : Builder(
                                      builder: (context) {
                                        List<Widget> displayWidgets = [];

                                        if (studentData == null || studentData!.modules.isEmpty) {
                                          return const Center(child: Text("Nenhum módulo encontrado."));
                                        }

                                        for (var module in studentData!.modules) {
                                          displayWidgets.add(
                                            Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
                                              child: Text(
                                                module.moduleName.toUpperCase(),
                                                style: GoogleFonts.lexendDeca(
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 14,
                                                  color: Theme.of(context).primaryColor,
                                                ),
                                              ),
                                            ),
                                          );

                                          for (var lesson in module.lessons) {
                                            displayWidgets.add(
                                              ListTile(
                                                contentPadding: const EdgeInsets.only(left: 20.0, right: 8.0),
                                                leading: GestureDetector(
                                                  child: Icon(
                                                    lesson.viewStatus == 1 ? Icons.check_circle : Icons.circle_outlined,
                                                    color: lesson.viewStatus == 1 ? Colors.green : Colors.grey,
                                                  ),
                                                  onTap: () {
                                                    setState(() {
                                                      lesson.viewStatus = lesson.viewStatus == 1 ? 0 : 1;
                                                      calculateProgress();
                                                    });

                                                    sendProgressUpdate();
                                                  },
                                                ),
                                                title: Text(
                                                  '${lesson.lessonName}',
                                                  style: GoogleFonts.lexendDeca(fontSize: 14),
                                                ),
                                                onTap: () {
                                                  print('Abrir vídeo: ${lesson.videoLink}');
                                                },
                                              ),
                                            );
                                          }
                                          displayWidgets.add(
                                            const Divider(height: 20, thickness: 1, color: Colors.black12),
                                          );
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
          body: jsonEncode({'pergunta': trimmedText}), // Use trimmedText!
        );
        setState(() {
          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            final botResponse = data['resposta']; // Assumindo que a resposta JSON tem a chave 'resposta'

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

  Future<StudentData> loadMockDataSimple() async {
    final decodedJson = json.decode(mockJsonString);
    return StudentData.fromJson(decodedJson);
  }

  Future<void> _loadInitialData() async {
    try {
      final data = await loadMockDataSimple();

      setState(() {
        studentData = data;
        isLoadingCourse = false;
        messages = [
          Message(
            creationDate: DateTime.now().toIso8601String(),
            message:
                '👋 Olá ${studentData!.studentId}! Bem-vindo ao RoboEdu! Selecione uma aula na playlist ao lado ou me pergunte sobre o conteúdo do curso. Estou aqui para ajudar! 🎓',
            sender: SenderType.bot,
          ),
        ];
      });

      calculateProgress();
    } catch (e) {
      setState(() {
        errorMessage = 'Falha ao carregar dados do Mock: ${e.toString()}';
        isLoadingCourse = false;
      });
    }
  }

  void sendProgressUpdate() {
    if (studentData == null) return;

    final progressPayload = {
      'aluno_id': studentData!.studentId,
      'modulos': studentData!.modules.map((m) => m.toJson()).toList(),
    };

    // 2. Envia para o seu Backend (nova rota: /update-progress)
    // try {
    //   final response = await http.post(
    //     Uri.parse('http://127.0.0.1:5000/update-progress'),
    //     headers: {'Content-Type': 'application/json'},
    //     body: jsonEncode(progressPayload),
    //   );
    //
    //   if (response.statusCode != 200) {
    //     print('Erro ao enviar progresso: ${response.body}');
    //   }
    // } catch (e) {
    //   print('Erro de rede ao enviar progresso: $e');
    // }
  }
}
