import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ChatPage extends StatefulWidget {
  final String userId;
  final String shopId;

  ChatPage({
    required this.userId,
    required this.shopId,
  });

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  File? selectedImage;
  String? shopName;
  int userType = 0; // Assuming userType 1 for customers and 2 for shops
  TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    
    super.initState();
    fetchUserType();
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

  Stream<QuerySnapshot> messagesStream() {
    return FirebaseFirestore.instance
        .collection('messages')
        .where('shopId',
            isEqualTo: widget.shopId)
        .where('customerId',
        isEqualTo: widget.userId) // Filter messages based on shopId
        .orderBy('timestamp',
            descending: true) // Order messages by timestamp in descending order
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

  Future getImage(ImageSource source) async {
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

  Future<void> fetchUserType() async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    DocumentSnapshot userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (userSnapshot.exists) {
      setState(() {
        userType = userSnapshot['userType'];
      });
    }
  }

  Future<int> getUserType() async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    int userType;
    DocumentSnapshot userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (userSnapshot.exists) {
      userType = userSnapshot['userType'];
    } else {
      userType = 0; // Assuming userType 1 for customers and 2 for shops
    }
    return userType;
  }

  Future<void> addMessagedShops(String shopId) async {
    try {
      // Check user type here
      Future<int> userType =
          getUserType(); // Replace with your logic to get the user type

      if (userType == 2) {
        print('User type 2 is not allowed to use this method.');
        return;
      }

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
      print('Error adding string: $e');
    }
  }

  Future<void> addMessagedUsers(String shopId) async {
    try {
      String? uid = FirebaseAuth.instance.currentUser?.uid;
      CollectionReference messagedUsersCollection =
          FirebaseFirestore.instance.collection('MessagedUsers');
      QuerySnapshot querySnapshot = await messagedUsersCollection
          .where('shopId', isEqualTo: shopId)
          .get();

      if (querySnapshot.docs.isEmpty) {
        await messagedUsersCollection.add({
          'shopId': shopId,
          'usersArray': [uid]
        });
        print('UID added successfully.');
      } else {
        DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
        List<String> usersArray = List<String>.from(
            (documentSnapshot.data() as Map<String, dynamic>)['usersArray'] ??
                []);

        if (!usersArray.contains(uid)) {
          usersArray.add(uid!);
          await messagedUsersCollection
              .doc(documentSnapshot.id)
              .update({'usersArray': usersArray});
          print('UID added successfully.');
        } else {
          print('UID already exists in the array.');
        }
      }
    } catch (e) {
      print('Error adding UID: $e');
    }
  }

  void sendMessage() async {
    try {
      String? uid = FirebaseAuth.instance.currentUser?.uid;
      String messageText = messageController.text.trim();
      int userType;
      DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userSnapshot.exists) {
        userType = userSnapshot['userType'];
      } else {
        userType = 0; // Assuming userType 1 for customers and 2 for shops
      }

      if (uid != null && (messageText.isNotEmpty || selectedImage != null)) {
        final imageUrl =
            selectedImage != null ? await uploadImage(selectedImage!) : '';

        CollectionReference messagesCollection =
            FirebaseFirestore.instance.collection('messages');
        QuerySnapshot querySnapshot;
        if (userType == 1 || userType == 2) {
          querySnapshot = await messagesCollection
              .where('shopId', isEqualTo: widget.shopId)
              .where('customerId', isEqualTo: widget.userId)
              .limit(1)
              .get();
        } else {
          querySnapshot = await messagesCollection
              .where('sender', isEqualTo: uid)
              .where('customerId', isEqualTo: widget.userId)
              .limit(1)
              .get();
        }

        DocumentReference documentRef;
        List<Map<String, dynamic>> contents;

        if (querySnapshot.docs.isEmpty) {
          // Create a new document for the shop/customer and sender
          documentRef = messagesCollection.doc();
          contents = [];
        } else {
          // Get the existing document between the shop/customer and sender
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
          'sender': uid,
        };

        contents.add(newMessage);

        Map<String, dynamic> data = {
          'contents': contents,
          'shopId': widget.shopId,
          'customerId': widget.userId,
          'timestamp': DateTime.now(),
        };

        await documentRef.set(data, SetOptions(merge: true));
        addMessagedShops(widget.shopId);
        addMessagedUsers(widget.shopId);
        // Add the shop to the MessagedShops collection
        // Assuming you have a variable named 'userType' that represents the user type

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
    final currentUserID = FirebaseAuth.instance.currentUser?.uid;
    //   print(widget.userId);
    print(widget.userId);

    return Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 0, 0, 0),
        title: Text(
          '',
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
                 // print(messages.isEmpty);
                  return ListView.builder(
                    padding: EdgeInsets.all(16.0),
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      
                      final contents = message['contents'] as List<dynamic>;
                      //isMe is responsible of identifying if the sender  of the message is the same as the current user

                    //this is responsible for figuring out if the sender is a customer and the shop id is a shop
                     /* final senderIsCustomerShopsIsShop = message['sender'] == widget.userId &&
                          message['shopId'] == widget.shopId;*/
                      //check if the customerId is the customer in the widget and  the sender is the shop
                      final mightBeHim = message['shopId'] == widget.shopId && message['customerId'] == widget.userId;
                      // Show messages only if the sender matches the current user ID
                      if ( mightBeHim) {
                        if (userType == 2) {}
                        return Column(
                          children: [
                            for (var content in contents)
                              ChatBubble(
                                content: content,
                                isMe: content['sender'] == currentUserID,
                              ),
                          ],
                        );
                      } else {
                        return SizedBox.shrink();
                      }
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
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Select an Option'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop();
                                  getImage(ImageSource.camera);
                                },
                                child: ListTile(
                                  leading: Icon(Icons.photo_camera),
                                  title: Text('Take a Photo'),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop();
                                  pickImage(ImageSource.gallery);
                                },
                                child: ListTile(
                                  leading: Icon(Icons.photo_library),
                                  title: Text('Pick from Gallery'),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
                if (selectedImage !=
                    null) // Display the selected/captured image
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: FileImage(selectedImage!),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
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
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullScreenImage(url: imageUrl),
                      ),
                    );
                  },
                  child: Image.network(
                    imageUrl,
                    width: 200,
                    height: 200,
                  ),
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
class FullScreenImage extends StatelessWidget {
  final String url;

  const FullScreenImage({required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: false,
          boundaryMargin: EdgeInsets.all(20),
          minScale: 0.5,
          maxScale: 5.0,
          child: Image.network(url),
        ),
      ),
    );
  }
}
