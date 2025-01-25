import 'package:budgetly/components/shared/custom_confirmation_dialog.dart';
import 'package:budgetly/provider/provider_user.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  Map<String, dynamic>? user;
  List<Map<String, String>> messages = [];
  String input = '';
  bool isLoading = false;
  bool isFetching = true;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    fetchUserData();

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        });
      }
    });
  }

  Future<void> fetchUserData() async {
    final userId = Provider.of<UserProvider>(context, listen: false).userId;
    setState(() {
      isFetching = true;
    });

    try {
      final conversationResponse = await http.get(
        Uri.parse(
            'https://budgetly-api-pa7n.vercel.app/api/chatbot/get-conversation/$userId'),
      );
      final conversationData = json.decode(conversationResponse.body);

      setState(() {
        messages = List<Map<String, String>>.from(
          (conversationData['messages'] as List).map((msg) => {
                'sender': msg['sender'].toString(),
                'text': msg['text'].toString(),
              }),
        );
      });
    } catch (error) {
    } finally {
      setState(() {
        isFetching = false;
      });
    }
  }

  Future<void> handleSendMessage() async {
    if (input.trim().isEmpty) return;

    final userMessage = {'sender': 'user', 'text': input};
    setState(() {
      messages.add(userMessage);
      isLoading = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });

    try {
      final response = await http.post(
        Uri.parse('https://budgetly-api-pa7n.vercel.app/api/chatbot/generate'),
        body: json.encode({
          'userId': Provider.of<UserProvider>(context, listen: false).userId,
          'prompt': input,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      final botResponse = json.decode(response.body);
      final botMessage = {
        'sender': 'bot',
        'text': botResponse['response']?.toString() ??
            'Maaf, saya tidak dapat merespons saat ini.',
      };

      setState(() {
        messages.add(botMessage);
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });

      await saveConversation([
        ...messages.map((msg) => {
              'sender': msg['sender'].toString(),
              'text': msg['text'].toString(),
            }),
      ]);
    } catch (error) {
      setState(() {
        messages.add({
          'sender': 'bot',
          'text': 'Oops! Terjadi kesalahan. Silakan coba lagi.',
        });
      });
    } finally {
      setState(() {
        isLoading = false;
      });
      input = '';
      _inputController.clear();
    }
  }

  Future<void> saveConversation(List<Map<String, String>> conversation) async {
    final userId = Provider.of<UserProvider>(context, listen: false).userId;

    try {
      await http.post(
        Uri.parse(
            'https://budgetly-api-pa7n.vercel.app/api/chatbot/save-conversation'),
        body: json.encode({
          'userId': userId,
          'messages': conversation,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (error) {}
  }

  Future<void> handleDeleteConversations() async {
    showDialog(
      context: context,
      builder: (context) {
        return CustomConfirmationDialog(
          title: 'Konfirmasi Hapus',
          message:
              'Apakah Anda yakin ingin menghapus semua percakapan? Data yang dihapus tidak dapat dikembalikan.',
          confirmText: 'Hapus',
          cancelText: 'Batal',
          onConfirm: () async {
            Navigator.of(context).pop();
            final userId =
                Provider.of<UserProvider>(context, listen: false).userId;

            setState(() {
              isFetching = true;
            });

            try {
              await http.delete(
                Uri.parse(
                    'https://budgetly-api-pa7n.vercel.app/api/chatbot/delete-conversation'),
                body: json.encode({'userId': userId}),
                headers: {'Content-Type': 'application/json'},
              );

              setState(() {
                messages.clear();
              });

              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Berhasil!'),
                  content: const Text('Semua percakapan telah dihapus.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            } catch (error) {
            } finally {
              setState(() {
                isFetching = false;
              });
            }
          },
          onCancel: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  Future<void> handleRefreshConversations() async {
    final userId = Provider.of<UserProvider>(context, listen: false).userId;
    setState(() {
      isFetching = true;
    });

    try {
      final conversationResponse = await http.get(
        Uri.parse(
            'https://budgetly-api-pa7n.vercel.app/api/chatbot/get-conversation/$userId'),
      );

      if (conversationResponse.statusCode == 200) {
        final conversationData = json.decode(conversationResponse.body);

        setState(() {
          messages = List<Map<String, String>>.from(
            (conversationData['messages'] as List).map((msg) => {
                  'sender': msg['sender'].toString(),
                  'text': msg['text'].toString(),
                }),
          );
        });
      } else {}
    } catch (error) {
    } finally {
      setState(() {
        isFetching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF3F8C92),
                  Color(0xFF1F4649),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 5.0, left: 20.0, right: 10.0, bottom: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Chatbot AI',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.white),
                        onPressed: handleDeleteConversations,
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        onPressed: handleRefreshConversations,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: isFetching
                ? Container(
                    color: Colors.white,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          LoadingAnimationWidget.staggeredDotsWave(
                            size: 50,
                            color: const Color(0xFF3F8C92),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Memuat percakapan...',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : messages.isEmpty
                    ? Center(
                        child: Text(
                          'Tidak ada percakapan.',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 16,
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: messages.length + (isLoading ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == messages.length) {
                            return Center(
                              child: LoadingAnimationWidget.staggeredDotsWave(
                                size: 50,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            );
                          }

                          final message = messages[index];
                          final isUser = message['sender'] == 'user';

                          return Align(
                            alignment: isUser
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: isUser
                                  ? const EdgeInsets.only(
                                      left: 60, bottom: 8, top: 8)
                                  : const EdgeInsets.only(
                                      right: 60, bottom: 8, top: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isUser
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey[300],
                                borderRadius: isUser
                                    ? const BorderRadius.only(
                                        topLeft: Radius.circular(12),
                                        topRight: Radius.circular(12),
                                        bottomLeft: Radius.circular(12),
                                      )
                                    : const BorderRadius.only(
                                        topLeft: Radius.circular(12),
                                        topRight: Radius.circular(12),
                                        bottomRight: Radius.circular(12),
                                      ),
                              ),
                              child: Text(
                                message['text'] ?? '',
                                style: TextStyle(
                                  color: isUser ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    focusNode: _focusNode,
                    onChanged: (value) => input = value,
                    onSubmitted: (value) => handleSendMessage(),
                    decoration: InputDecoration(
                      hintText: 'Ketik pesan Anda...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: isLoading ? null : handleSendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
