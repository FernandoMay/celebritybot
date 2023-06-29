import 'package:celebritybot/api.dart';
import 'package:celebritybot/chat.dart';
import 'package:celebritybot/models.dart';
import 'package:flutter/material.dart';

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
        title: const Text('Celebrity Screen'),
      ),
      body: ListView.builder(
        itemCount: _celebrities.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(_celebrities[index].name),
            subtitle: Text(_celebrities[index].desc),
            leading: CircleAvatar(
              foregroundImage: Image.network(
                      'https://image.tmdb.org/t/p/w500${_celebrities[index].imagePath}')
                  .image,
            ),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const ChatScreen(),
              ));
            },
          );
        },
      ),
    );
  }
}
