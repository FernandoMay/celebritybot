// api_service.dart
import 'dart:convert';

import 'package:celebritybot/models.dart';
import 'package:http/http.dart' as http;
import 'config.dart';

class ApiService {
  Future<String> sendMessageToOpenAI(
      String message, Celebrity celebrity) async {
    const openaiEndpoint =
        'https://api.openai.com/v1/engines/text-davinci-003/completions';
    final openaiResponse = await http.post(Uri.parse(openaiEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Config.openaiToken}',
        },
        body: json.encode({
          "prompt":
              "Asume que eres ${celebrity.name} y estas hablando en chat con un fan, tienes que contestar actuar y decir dialaogos comunes de la celebridad y demas, te dejo el mensaje: $message",
          "max_tokens": 50, // Máximo número de tokens en la respuesta generada
          "temperature":
              0.8, // Controla la aleatoriedad de la respuesta (mayor valor = más aleatorio)
          "top_p":
              1.0, // Controla la diversidad de la respuesta (1.0 = máxima diversidad)
          "n": 1, // Número de respuestas a generar
          "stop":
              "\n" // Detiene la generación de la respuesta en un salto de línea
        }));

    return openaiResponse.body;
  }

  Future<String> sendMessageToTelegram(String message) async {
    const telegramEndpoint =
        'https://api.telegram.org/bot${Config.telegramBotToken}/sendMessage';
    final telegramResponse = await http.post(Uri.parse(telegramEndpoint),
        headers: {
          'Content-Type': 'application/json',
        },
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

  Future<List<Celebrity>> getCelebrities() async {
    const url =
        'https://api.themoviedb.org/3/person/popular?api_key=${Config.tmdbApiKey}';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final results = jsonData['results'];

      final celebrities = results.map((celebrity) {
        return Celebrity.fromJson(celebrity);
      }).toList();

      return celebrities;
    } else {
      throw Exception('Failed to fetch celebrities');
    }
  }
}
