// chat_screen.dart
import 'package:celebritybot/api.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textEditingController = TextEditingController();
  final List<String> _messages = [];
  ApiService apiService = ApiService();
// Rest of the code for handling user input and displaying messages

  _handleSubmitted(String message) {
    // Example implementation to send the message to the Telegram API
    final apiService = ApiService();
    message.isNotEmpty
        ? apiService.sendMessageToTelegram(message).then((response) {
            setState(() {
              // Update the chat interface with the response
              _addMessageToChat(response);
            });
          }).then(
            (value) => apiService.receiveMessageFromTelegram().then((response) {
                  setState(() {
                    // Update the chat interface with the response
                    _addMessageToChat(response);
                  });
                }))
        : const ScaffoldMessenger(child: Text("Messsage is empty"));

    // Clear the text input field after submitting the message
    _textEditingController.clear();
  }

  void _addMessageToChat(String message) {
    // Example implementation
    setState(() {
      _messages.add(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Celebrity Chatbot')),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _messages.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                    padding: const EdgeInsets.all(4.0),
                    margin: const EdgeInsets.all(4.0),
                    width: TextSelectionToolbar.kToolbarContentDistanceBelow,
                    decoration: BoxDecoration(
                        color: Colors.lightBlue.shade200,
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8.0),
                            topRight: Radius.circular(8.0),
                            bottomRight: Radius.circular(8.0))),
                    child: Text(
                      _messages[index],
                      style: const TextStyle(color: Colors.white70),
                    ));
              },
            ),
          ),
          const Divider(height: 1.0),
        ],
      ),
      // floatingActionButton: FloatingActionButton(onPressed: () async {
      //   await apiService.receiveMessageFromTelegram().then((value) =>
      //       ScaffoldMessenger.of(context)
      //           .showSnackBar(SnackBar(content: Text(value))));
      // }),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        height: 70,
        child: Row(
          children: <Widget>[
            Flexible(
              child: TextField(
                controller: _textEditingController,
                onSubmitted: _handleSubmitted,
                decoration: const InputDecoration.collapsed(
                  hintText: 'Type a message...',
                ),
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.send,
                color: Colors.teal,
              ),
              onPressed: () => _handleSubmitted(_textEditingController.text),
            ),
          ],
        ),
      ),
    );
  }
}
