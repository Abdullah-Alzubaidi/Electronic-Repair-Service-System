import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ChatPage extends StatefulWidget {
final String shopId;
ChatPage({required this.shopId, required String userId});
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
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
          Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;

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
 // to be updated
Stream<QuerySnapshot> messagesStream() {
  return FirebaseFirestore.instance
      .collection('messages')
      .orderBy('contents.0.timestamp', descending: true) // Order messages by timestamp in descending order
      .snapshots();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 0, 0, 0),
        title: Text(
          shopName ?? '', // Display the shop name or empty string if it's null
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

                      final contents= message['contents'] as List<dynamic>;
                      final isMe = message['sender'] ==
                          FirebaseAuth.instance.currentUser?.uid;

                      return ChatBubble(
                        contents: contents,
                        isMe: isMe,
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Text('Error loading messages');
                } else {
                  return CircularProgressIndicator();
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
                      hintText: 'Type your message...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    showImageOptions(context);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    sendMessage();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void showImageOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Choose from Gallery'),
                onTap: () {
                  getImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              Divider(
                height: 0.0,
                color: Colors.grey[300],
              ),
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('Take a Photo'),
                onTap: () {
                  getImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future getImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(source: source);

    if (pickedImage != null) {
      setState(() {
        selectedImage = File(pickedImage.path);
      });
    }
  }

  Future<String?> uploadImage(File image) async {
    try {
      String? uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        Reference ref = FirebaseStorage.instance
            .ref()
            .child('images')
            .child(uid)
            .child(DateTime.now().toString() + '.jpg');

        UploadTask uploadTask = ref.putFile(image);
        TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);

        String downloadUrl = await taskSnapshot.ref.getDownloadURL();
        return downloadUrl;
      } else {
        print('User is not authenticated.');
        return null;
      }
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

 Future<void> addMessagedShops(String shopId) async {
    try {
      String? uid = FirebaseAuth.instance.currentUser?.uid;
      CollectionReference messageedShopsCollection = FirebaseFirestore.instance.collection('MessagedShops');
      QuerySnapshot querySnapshot = await messageedShopsCollection.where('sender', isEqualTo: uid).get();
  if (querySnapshot.docs.isEmpty) {
      await messageedShopsCollection.add({
        'sender': uid,
        'shopsArray': [shopId]
      });
      print('String added successfully.');
    }else {
      DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
      List<String> shopsArray = List<String>.from((documentSnapshot.data() as Map<String, dynamic>)['shopsArray'] ?? []);
      
      if (!shopsArray.contains(shopId)) {
        shopsArray.add(shopId);
        await messageedShopsCollection.doc(documentSnapshot.id).update({'shopsArray': shopsArray});
        print('String added successfully.');
      } else {
        print('String already exists in the array.');
      }
    }
  } catch (e) {
      print('Error sending message: $e');
    }
}  


Future<void> sendMessage() async {
  try {
    String? uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid != null) {
      CollectionReference messagesCollection =
          FirebaseFirestore.instance.collection('messages');

      DocumentReference documentRef = messagesCollection.doc();

      String? imageUrl =
          selectedImage != null ? await uploadImage(selectedImage!) : null;

      List<Map<String, dynamic>> contents = [
        {
          'text': messageController.text,
          'imageUrl': imageUrl,
          'timestamp': DateTime.now(),
        }
      ];

      Map<String, dynamic> data = {
        'contents': contents,
        'sender': uid,
        'shopId': widget.shopId,
      };

      await documentRef.set(data, SetOptions(merge: true));

      messageController.clear();
      setState(() {
        selectedImage = null;
      });
    } else {
      print('User is not authenticated.');
    }
  } catch (e) {
    print('Error sending message: $e');
  }
}


}
class ChatBubble extends StatelessWidget {
  final List<dynamic> contents;
  final bool isMe;

  ChatBubble({required this.contents, required this.isMe});

  @override
  Widget build(BuildContext context) {
    
    return Container(
      margin: EdgeInsets.only(bottom: 10.0),
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10.0,
            children: contents.map<Widget>((content) {
              if (content['type'] == 'text') {
                return Text(
                  content['text'],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                  ),
                );
              } else if (content['type'] == 'image') {
                return Image.network(
                  content['url'],
                  width: 150.0,
                  height: 150.0,
                );
              } else {
                return SizedBox();
              }
            }).toList(),
          ),
          Text(
            DateFormat('dd MMM kk:mm').format(DateTime.now()),
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12.0,
            ),
          ),
        ],
      ),
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: isMe ? Colors.blue : Colors.grey[800],
        borderRadius: isMe
            ? BorderRadius.only(
                topLeft: Radius.circular(20.0),
                bottomLeft: Radius.circular(20.0),
                bottomRight: Radius.circular(20.0),
              )
            : BorderRadius.only(
                topRight: Radius.circular(20.0),
                bottomLeft: Radius.circular(20.0),
                bottomRight: Radius.circular(20.0),
              ),
      ),
    );
  }

}