import 'package:celebritybot/api.dart';
import 'package:celebritybot/models.dart';
import 'package:flutter/material.dart';
// import 'package:telegram/telegram.dart';

class CelebrityScreen extends StatefulWidget {
  const CelebrityScreen({super.key});

  @override
  _CelebrityScreenState createState() => _CelebrityScreenState();
}

class _CelebrityScreenState extends State<CelebrityScreen> {
  final ApiService _apiService = ApiService();
  List<Celebrity> _celebrities = [];

  @override
  void initState() {
    super.initState();
    _fetchCelebrities();
  }

  Future<void> _fetchCelebrities() async {
    final response = await _apiService.getCelebrities();

    setState(() {
      _celebrities = response;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose your Celebrity!'),
      ),
      body: ListView.builder(
        itemCount: _celebrities.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(_celebrities[index].name),
            subtitle: Text(_celebrities[index].desc),
            leading: CircleAvatar(
              backgroundImage: Image.network(
                      'https://image.tmdb.org/t/p/w500${_celebrities[index].imagePath}')
                  .image,
            ),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => CelebrityDetailScreen(
                  celebrity: _celebrities[index],
                ),
              ));
            },
          );
        },
      ),
    );
  }
}

class CelebrityDetailScreen extends StatefulWidget {
  final Celebrity celebrity;

  const CelebrityDetailScreen({Key? key, required this.celebrity})
      : super(key: key);

  @override
  State<CelebrityDetailScreen> createState() => _CelebrityDetailScreenState();
}

class _CelebrityDetailScreenState extends State<CelebrityDetailScreen> {
  final TextEditingController _textEditingController = TextEditingController();

  final List<String> conversation = [];

  void _handleSubmitted(String message) {
    //   Telegram bot = Telegram();

    // // Manejador para los mensajes entrantes
    // bot.onMessage((message) async {
    //   String userMessage = message.text;

    //   // Genera la respuesta utilizando la función generateResponse
    //   String botResponse = await generateResponse(userMessage);

    //   // Envía la respuesta al chat correspondiente
    //   bot.sendMessage(
    //     chatId: message.chat.id,
    //     text: botResponse,
    //   );
    // });

    // Inicia el cliente de Telegram
    // bot.start();
    if (message.isNotEmpty) {
      final apiService = ApiService();
      apiService.sendMessageToTelegram(message).then((response) {
        setState(() {
          _addMessageToChat(message);
          // _addMessageToChat(response);
        });
      }).then((value) => apiService
              .sendMessageToOpenAI(message, widget.celebrity)
              .then((value) => setState(() {
                    _addMessageToChat(value);
                    // _addMessageToChat(response);
                  }))
          // .then((value) => null
          // apiService
          //     .receiveMessageFromTelegram()
          //     .then((value) => setState(() {
          //           _addMessageToChat(value);
          //           // _addMessageToChat(response);
          //         })))
          );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message is empty')),
      );
    }

    _textEditingController.clear();
  }

  void _addMessageToChat(String message) {
    setState(() {
      conversation.add(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 400,
                  flexibleSpace: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.network(
                          'https://image.tmdb.org/t/p/w500${widget.celebrity.imagePath}',
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(30),
                              bottomRight: Radius.circular(30),
                            ),
                            color: Colors.black.withOpacity(0.5),
                          ),
                          child: Center(
                            child: Text(
                              'Hello, I\'m ${widget.celebrity.name}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      final message = conversation[index];
                      final isSentByCelebrity = index % 2 == 0;

                      return Align(
                        alignment: isSentByCelebrity
                            ? Alignment.topRight
                            : Alignment.topLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSentByCelebrity
                                ? Colors.lightBlue[300]
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            message,
                            style: TextStyle(
                              color: Colors.indigoAccent[300],
                              fontWeight: isSentByCelebrity
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: conversation.length,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textEditingController,
                    onSubmitted: _handleSubmitted,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: () {
                    _handleSubmitted(_textEditingController.text);
                  },
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// class CelebrityDetailScreen extends StatefulWidget {
//   final Celebrity celebrity;

//   const CelebrityDetailScreen({super.key, required this.celebrity});

//   @override
//   State<CelebrityDetailScreen> createState() => _CelebrityDetailScreenState();
// }

// class _CelebrityDetailScreenState extends State<CelebrityDetailScreen> {
//   final TextEditingController _textEditingController = TextEditingController();

//   final List<String> conversation = [];

//   _handleSubmitted(String message) {
//     // Example implementation to send the message to the Telegram API
//     final apiService = ApiService();
//     message.isNotEmpty
//         ? apiService.sendMessageToTelegram(message).then((response) {
//             setState(() {
//               // Update the chat interface with the response
//               _addMessageToChat(response);
//             });
//           }).then(
//             (value) => apiService.receiveMessageFromTelegram().then((response) {
//                   setState(() {
//                     // Update the chat interface with the response
//                     _addMessageToChat(response);
//                   });
//                 }))
//         : const ScaffoldMessenger(child: Text("Messsage is empty"));

//     // Clear the text input field after submitting the message
//     _textEditingController.clear();
//   }

//   void _addMessageToChat(String message) {
//     // Example implementation
//     setState(() {
//       conversation.add(message);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         children: [
//           Expanded(
//             child: CustomScrollView(
//               slivers: [
//                 SliverAppBar.large(
//                   shape: StarBorder(innerRadiusRatio: 60),
//                   title: Text('Hello I\'m ${widget.celebrity.name}'),
//                   backgroundColor: Colors.transparent,
//                   actions: [
//                     Container(
//                       height: 200,
//                       decoration: BoxDecoration(
//                         image: DecorationImage(
//                           image: Image.network(
//                                   'https://image.tmdb.org/t/p/w500${widget.celebrity.imagePath}')
//                               .image,
//                           fit: BoxFit.cover,
//                         ),
//                         borderRadius: const BorderRadius.only(
//                           bottomLeft: Radius.circular(80),
//                           bottomRight: Radius.circular(80),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 SliverList(
//                   delegate: SliverChildBuilderDelegate(
//                     (BuildContext context, int index) {
//                       final message = conversation[index];
//                       final isSentByCelebrity = index % 2 == 0;

//                       return ListTile(
//                         title: Text(
//                           message,
//                           style: TextStyle(
//                             fontWeight: isSentByCelebrity
//                                 ? FontWeight.bold
//                                 : FontWeight.normal,
//                           ),
//                         ),
//                         tileColor: isSentByCelebrity
//                             ? Colors.grey[300]
//                             : Colors.lightBlue[300],
//                       );
//                     },
//                     childCount: conversation.length,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _textEditingController,
//                     onSubmitted: _handleSubmitted,
//                     decoration: InputDecoration(
//                       hintText: 'Type a message...',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8.0),
//                 ElevatedButton(
//                   onPressed: () {
//                     // Logic to submit the message
//                     _handleSubmitted(_textEditingController.text);
//                   },
//                   child: const Text('Submit'),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
