// api_service.dart
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'config.dart';

class ApiService {
  Future<String> sendMessageToOpenAI(String message) async {
    const openaiEndpoint =
        'https://api.openai.com/v1/engines/davinci-codex/completions';
    final openaiResponse = await http.post(Uri.parse(openaiEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Config.openaiToken}',
        },
        body: json.encode({
          'prompt': message,
          'max_tokens': '50',
        }));

    return openaiResponse.body;
  }

  Future<String> sendMessageToTelegram(String message) async {
    const telegramEndpoint =
        'https://api.telegram.org/bot${Config.telegramBotToken}/sendMessage';
    final telegramResponse = await http.post(Uri.parse(telegramEndpoint),
        body: json.encode({
          "chat_id": Config.telegramChatId,
          "text": message,
        }));

    if (telegramResponse.statusCode == 200) {
      return 'Message sent successfully';
    } else {
      return 'Failed to send message ${telegramResponse.body}';
    }
  }

  Future<String> receiveMessageFromTelegram() async {
    const telegramEndpoint =
        'https://api.telegram.org/bot${Config.telegramBotToken}/getUpdates';
    final telegramResponse = await http.get(Uri.parse(telegramEndpoint));

    if (telegramResponse.statusCode == 200) {
      // Parse the response and extract the latest incoming message
      // Here's an example assuming the response is in JSON format:
      final jsonResponse = json.decode(telegramResponse.body);
      final results = jsonResponse['result'];
      final latestMessage = results.isNotEmpty ? results.last : null;
      final messageText = latestMessage != null
          ? latestMessage['message']['text']
          : 'No messages';

      return messageText;
    } else {
      return 'Failed to receive message';
    }
  }
}
