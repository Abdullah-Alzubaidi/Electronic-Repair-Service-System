import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'ChatPage.dart'; // Import your ChatPage.dart file here

void main() {
  runApp(MaterialApp(
    home: ChatList(),
  ));
}

class ChatMessage {
  final String user;
  final String message;
  final DateTime time;
  final String? imageUrl;
  final String shopId;

  ChatMessage({
    required this.user,
    required this.message,
    required this.time,
    this.imageUrl,
    required this.shopId,
  });
}

class ChatList extends StatefulWidget {
  @override
  _ChatListState createState() => _ChatListState();
}
String formatTime(DateTime time) {
  final formattedTime = DateFormat.Hm().format(time);
  return formattedTime;
}

class _ChatListState extends State<ChatList> {
  final TextEditingController _searchController = TextEditingController();
  List<ChatMessage>? _filteredMessages;
  List<ChatMessage>? _messages;
  String? uid = FirebaseAuth.instance.currentUser?.uid;
  Stream<List<ChatMessage>> getChatMessages() {
    final StreamController<List<ChatMessage>> controller =
        StreamController<List<ChatMessage>>();

    String? uid = FirebaseAuth.instance.currentUser?.uid;
    CollectionReference messagedShopsCollection =
        FirebaseFirestore.instance.collection('MessagedShops');

    messagedShopsCollection.where('sender', isEqualTo: uid).get().then(
      (querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          List<Future<DocumentSnapshot>> shopDocFutures = [];

          querySnapshot.docs.forEach(
            (doc) {
              List<dynamic> shopsArray = doc['shopsArray'];

              shopsArray.forEach(
                (shopId) {
                  shopDocFutures.add(
                    FirebaseFirestore.instance
                        .collection('Shops')
                        .doc(shopId)
                        .get(),
                  );
                },
              );
            },
          );

          Future.wait(shopDocFutures).then(
            (List<DocumentSnapshot> shopDocs) {
              List<ChatMessage> messages = [];

              shopDocs.forEach(
                (shopDoc) {
                  if (shopDoc.exists) {
                    String fullName = shopDoc['fullName'] ?? '';

                    messages.add(
                      ChatMessage(
                        user: fullName,
                        message: '',
                        time: DateTime.now(), // Replace with the actual time value from Firestore
                        shopId: shopDoc.id, // Add the shopId here
                      ),
                    );
                  } else {
                    print('Shop document does not exist. ShopId: ${shopDoc.id}');
                  }
                },
              );

              setState(() {
                _messages = messages;
                _filteredMessages = messages;
              });
            },
          );
        } else {
          controller.addError('User document does not contain "shopsArray" field');
        }
      },
    ).catchError((error) {
      controller.addError('Error fetching chat messages: $error');
    });

    return controller.stream;
  }

  void navigateToChatPage(BuildContext context, String shopId, String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChatPage(shopId: shopId, userId: userId)), // Pass the shopId to ChatPage
    );
  }

  void filterMessages(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredMessages = _messages;
      });
    } else {
      final List<ChatMessage> filteredList = _messages?.where((message) {
        return message.user.toLowerCase().contains(query.toLowerCase());
      }).toList() ?? [];

      setState(() {
        _filteredMessages = filteredList;
      });
    }
  }

  String formatTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);

    if (time.isAfter(today)) {
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')} ${time.hour >= 12 ? 'PM' : 'AM'}';
    } else if (time.isAfter(yesterday)) {
      return 'Yesterday';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }

  @override
  void initState() {
    super.initState();
    // Fetch the chat messages on widget initialization
    getChatMessages().listen((List<ChatMessage> messages) {
      setState(() {
        _messages = messages;
        _filteredMessages = messages;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        title: Text('Chats', style: TextStyle(color: Colors.white)),
      ),
      backgroundColor: Colors.white70,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  filterMessages(value);
                },
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  hintText: 'Search',
                  labelStyle: TextStyle(color: Colors.black),
                  prefixIcon: Icon(Icons.search, color: Colors.black),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: BorderSide(color: Colors.black, width: 5),
                  ),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final ChatMessage chatMessage = _filteredMessages![index];
                final formattedTime = formatTime(chatMessage.time);

                return GestureDetector(
                  onTap: () {
                    navigateToChatPage(context, chatMessage.shopId, uid!);
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
                            spreadRadius: 1,
                            blurRadius: 2,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      margin: const EdgeInsets.symmetric(
                        vertical: 4.0,
                        horizontal: 8.0,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(chatMessage.imageUrl ?? ''),
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.black,
                          radius: 40,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.black,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          chatMessage.user,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          chatMessage.message,
                          style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
                        ),
                        trailing: Text(
                          formattedTime,
                          style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
                        ),
                      ),
                    ),
                  ),
                );
              },
              childCount: _filteredMessages?.length ?? 0,
            ),
          ),
        ],
      ),
    );
  }
}
