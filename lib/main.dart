import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat Client Socket',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const NameEntryPage(),
    );
  }
}

class NameEntryPage extends StatefulWidget {
  const NameEntryPage({super.key});

  @override
  State<NameEntryPage> createState() => _NameEntryPageState();
}

class _NameEntryPageState extends State<NameEntryPage> {
  final TextEditingController _nameController = TextEditingController();

  void _enterChat() {
    final name = _nameController.text;
    if (name.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatPage(userName: name),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Name'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Name',
                ),
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _enterChat,
                child: const Text('Enter Chat'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChatPage extends StatefulWidget {
  final String userName;

  const ChatPage({super.key, required this.userName});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late IO.Socket socket;
  final TextEditingController _messageController = TextEditingController();
  List<String> messages = [];

  @override
  void initState() {
    super.initState();
    connectToServer();
  }

  void connectToServer() {
    socket = IO.io('http://localhost:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();

    socket.onConnect((_) {
      print('Connected to server');
      socket.emit('join', widget.userName);
    });

    socket.on('chat message', (msg) {
      setState(() {
        messages.add(msg);
      });
    });

    socket.onDisconnect((_) {
      print('Disconnected from server');
    });
  }

  void sendMessage() {
    if (_messageController.text.isNotEmpty) {
      socket.emit('chat message', '${widget.userName}: ${_messageController.text}');
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat - ${widget.userName}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(messages[index]),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your message',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

