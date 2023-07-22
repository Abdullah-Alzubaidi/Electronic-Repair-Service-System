import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ChatPageShop extends StatefulWidget {
  final String shopId;

  ChatPageShop({required this.shopId, required String userId});

  @override
  _ChatPageShopState createState() => _ChatPageShopState();
}

class _ChatPageShopState extends State<ChatPageShop> {
  File? selectedImage;
  String? shopName;
  TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initializeFirebase();
  }

  Future<void> initializeFirebase() async {
    try {
      // Retrieve the current user's UID
      String? uid = FirebaseAuth.instance.currentUser?.uid;

      if (uid != null) {
        // Fetch the shop name from Firestore using the UID
        DocumentSnapshot? snapshot =
            await FirebaseFirestore.instance.collection('Shops').doc(uid).get();

        if (snapshot.exists) {
          Map<String, dynamic>? data =
              snapshot.data() as Map<String, dynamic>?;

          if (data != null && data.containsKey('shopName')) {
            setState(() {
              shopName = data['shopName'] as String?;
            });
          } else {
            // Handle missing shop name field
            print('Shop name field is missing or invalid.');
          }
        } else {
          // Handle non-existent document
          print('Shop document does not exist.');
        }
      } else {
        // Handle null UID
        print('User is not authenticated.');
      }
    } catch (e) {
      // Handle any errors during initialization
      print('Error initializing Firebase: $e');
    }
  }

  Stream<QuerySnapshot> messagesStream() {
    return FirebaseFirestore.instance
        .collection('messages')
        .where('shopId', isEqualTo: widget.shopId) // Filter messages based on shopId
        .orderBy('timestamp', descending: true) // Order messages by timestamp in descending order
        .snapshots();
  }

  void pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(source: source);

    if (pickedImage != null) {
      setState(() {
        selectedImage = File(pickedImage.path);
      });
    }
  }

  Future<String> uploadImage(File image) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child('images');
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final imageRef = storageRef.child('image_$timestamp.jpg');
      final uploadTask = imageRef.putFile(image);
      final snapshot = await uploadTask.whenComplete(() => null);
      final imageUrl = await snapshot.ref.getDownloadURL();

      return imageUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return '';
    }
  }

  Future<void> addMessagedShops(String shopId) async {
    try {
      String? uid = FirebaseAuth.instance.currentUser?.uid;
      CollectionReference messagedShopsCollection =
          FirebaseFirestore.instance.collection('MessagedShops');
      QuerySnapshot querySnapshot =
          await messagedShopsCollection.where('sender', isEqualTo: uid).get();
      if (querySnapshot.docs.isEmpty) {
        await messagedShopsCollection.add({
          'sender': uid,
          'shopsArray': [shopId]
        });
        print('String added successfully.');
      } else {
        DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
        List<String> shopsArray = List<String>.from(
            (documentSnapshot.data() as Map<String, dynamic>)['shopsArray'] ??
                []);

        if (!shopsArray.contains(shopId)) {
          shopsArray.add(shopId);
          await messagedShopsCollection
              .doc(documentSnapshot.id)
              .update({'shopsArray': shopsArray});
          print('String added successfully.');
        } else {
          print('String already exists in the array.');
        }
      }
    } catch (e) {
      print('Error sending message: $e');
    }
  }

Future<void> addMessagedUsers(String shopId) async {
  try {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    CollectionReference messagedUsersCollection =
        FirebaseFirestore.instance.collection('MessagedUsers');
    QuerySnapshot querySnapshot =
        await messagedUsersCollection.where('shopId', isEqualTo: uid).get();
    if (querySnapshot.docs.isEmpty) {
      await messagedUsersCollection.add({
        'shopId': shopId,
        'usersArray': [uid]
      });
      print('String added successfully.');
    } else {
      DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
      List<String> usersArray = List<String>.from(
          (documentSnapshot.data() as Map<String, dynamic>)['usersArray'] ??
              []);

      if (!usersArray.contains(uid!)) {
        usersArray.add(uid);
        await messagedUsersCollection
            .doc(documentSnapshot.id)
            .update({'usersArray': usersArray});
        print('String added successfully.');
      } else {
        print('String already exists in the array.');
      }
    }
  } catch (e) {
    print('Error sending message: $e');
  }
}

  void sendMessage() async {
    try {
      String? uid = FirebaseAuth.instance.currentUser?.uid;
      String messageText = messageController.text.trim();

      if (uid != null && messageText.isNotEmpty) {
        final imageUrl = selectedImage != null
            ? await uploadImage(selectedImage!)
            : '';

        CollectionReference messagesCollection =
            FirebaseFirestore.instance.collection('messages');

        QuerySnapshot querySnapshot = await messagesCollection
            .where('sender', isEqualTo: uid)
            .where('shopId', isEqualTo: widget.shopId)
            .limit(1)
            .get();

        DocumentReference documentRef;
        List<Map<String, dynamic>> contents;

        if (querySnapshot.docs.isEmpty) {
          // Create a new document for the shop and sender
          documentRef = messagesCollection.doc();
          contents = [];
        } else {
          // Get the existing document between the shop and sender
          DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
          documentRef = documentSnapshot.reference;

          // Get the current contents of the document
          contents = List<Map<String, dynamic>>.from(
              (documentSnapshot.data() as Map<String, dynamic>?)?['contents'] ??
                  []);
        }

        Map<String, dynamic> newMessage = {
          'text': messageText,
          'imageUrl': imageUrl,
          'timestamp': DateTime.now(),
        };

        contents.add(newMessage);

        Map<String, dynamic> data = {
          'contents': contents,
          'sender': uid,
          'shopId': widget.shopId,
          'timestamp': DateTime.now(),
        };

        await documentRef.set(data, SetOptions(merge: true));

        // Add the shop to the MessagedShops collection
        await addMessagedShops(widget.shopId);
        await addMessagedUsers(widget.shopId);

        messageController.clear();
        setState(() {
          selectedImage = null;
        });
      }
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 0, 0, 0),
        title: Text(
          shopName ?? '',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: messagesStream(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final messages = snapshot.data!.docs;

                  return ListView.builder(
                    padding: EdgeInsets.all(16.0),
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];

                      final contents =
                          message['contents'] as List<dynamic>;
                      final isMe = message['sender'] ==
                          FirebaseAuth.instance.currentUser?.uid;

                      return Column(
                        children: contents.map((content) {
                          return ChatBubble(
                            content: content,
                            isMe: isMe,
                          );
                        }).toList(),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading messages: ${snapshot.error}',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ),
          Container(
            color: Colors.grey[200],
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: sendMessage,
                ),
                IconButton(
                  icon: Icon(Icons.attach_file),
                  onPressed: () {
                    pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final dynamic content;
  final bool isMe;

  ChatBubble({required this.content, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final imageUrl = content['imageUrl'] as String?;
    final text = content['text'] as String?;
    final timestamp = content['timestamp'] != null
        ? (content['timestamp'] as Timestamp).toDate()
        : null;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: isMe ? Colors.lightBlueAccent : Colors.white,
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (imageUrl != null && imageUrl.isNotEmpty)
                Image.network(
                  imageUrl,
                  width: 200,
                  height: 200,
                ),
              if (text != null && text.isNotEmpty)
                Text(
                  text,
                  style: TextStyle(fontSize: 16.0),
                ),
              if (timestamp != null)
                Text(
                  DateFormat('dd MMMM yyyy, hh:mm a').format(timestamp),
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.black,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
