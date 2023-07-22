import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'ChatPage.dart';

class ChatMessage {
  final String user;
  final String message;
  final DateTime time;
  final String? imageUrl;
  final String userId;
  final VoidCallback onPressed;

  ChatMessage({
    required this.user,
    required this.message,
    required this.time,
    this.imageUrl,
    required this.userId,
    required this.onPressed,
  });
}

class ChatListShop extends StatefulWidget {
  @override
  _ChatListShopState createState() => _ChatListShopState();
}

class _ChatListShopState extends State<ChatListShop> {
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  Stream<List<ChatMessage>> getChatMessages() {
    final StreamController<List<ChatMessage>> controller =
        StreamController<List<ChatMessage>>();

    String? uid = FirebaseAuth.instance.currentUser?.uid;
    CollectionReference messagedShopsCollection =
        FirebaseFirestore.instance.collection('MessagedUsers');

    messagedShopsCollection.where('shopId', isEqualTo: uid).get().then(
      (querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          List<Future<DocumentSnapshot>> userDocFutures = [];

          querySnapshot.docs.forEach(
            (doc) {
              List<dynamic> usersArray = doc['usersArray'];

              usersArray.forEach(
                (userId) {
                  if (userId != uid) {
                    userDocFutures.add(
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(userId)
                          .get(),
                    );
                  }
                },
              );
            },
          );

          Future.wait(userDocFutures).then(
            (List<DocumentSnapshot> userDocs) {
              List<ChatMessage> messages = [];

              userDocs.forEach(
                (userDoc) {
                  if (userDoc.exists) {
                    String fullName = userDoc['fullName'] ?? '';

                    messages.add(
                      ChatMessage(
                        user: fullName,
                        message: '',
                        time: DateTime.now(), // Replace with the actual time value from Firestore
                        userId: userDoc.id,
                        onPressed: () {
                          navigateToChatPage(context, userDoc.id, uid!);
                        },
                      ),
                    );
                  } else {
                    print('User document does not exist. userId: ${userDoc.id}');
                  }
                },
              );

              List<ChatMessage> filteredMessages = messages.where((message) {
                return message.user.toLowerCase().contains(searchQuery.toLowerCase());
              }).toList();
              controller.add(filteredMessages);
            },
          );
        } else {
          controller.addError('User document does not contain "usersArray" field');
        }
      },
    ).catchError((error) {
      controller.addError('Error fetching chat messages: $error');
    });

    return controller.stream;
  }

  void navigateToChatPage(BuildContext context, String userId, String shopId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChatPage(userId: userId, shopId: shopId)),
    );
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
                controller: searchController,
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
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
          StreamBuilder<List<ChatMessage>>(
            stream: getChatMessages(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final List<ChatMessage>? messages = snapshot.data?.where((message) {
                  return message.user.toLowerCase().contains(searchQuery.toLowerCase());
                }).toList();
                return SliverPadding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final ChatMessage chatMessage = messages![index];
                        final formattedTime = formatTime(chatMessage.time);
                        return GestureDetector(
                          onTap: chatMessage.onPressed,
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
                      childCount: messages?.length ?? 0,
                    ),
                  ),
                );
              } else if (snapshot.hasError) {
                return SliverToBoxAdapter(
                  child: Container(
                    padding: EdgeInsets.all(16),
                    child: Text('Error: ${snapshot.error}'),
                  ),
                );
              } else {
                return SliverToBoxAdapter(
                  child: Container(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
