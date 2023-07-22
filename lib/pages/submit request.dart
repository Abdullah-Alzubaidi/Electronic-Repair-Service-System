import 'dart:io';
import 'package:FixZone/pages/CustomerRequestPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Submit extends StatefulWidget {
  final String shopId;
  final String typeServices;
  final String shopName;
  final String phoneNumberShop;
  final String shopImage;
  final List<String> services;

  Submit({
    required this.shopId,
    required this.typeServices,
    required this.shopName,
    required this.phoneNumberShop,
    required this.shopImage,
    required this.services,
  });

  @override
  _SubmitState createState() => _SubmitState();
}

class _SubmitState extends State<Submit> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();

  List<File> _attachedImages = [];
  List<File> _attachedVideos = [];

  final _focusNode = FocusNode();
  late String _shopName = '';
  late String _description;

  List<bool> _showAttachments = List<bool>.filled(2, false);

  bool _isSubmitting = false; // Flag to track if form submission is in progress

  @override
  void initState() {
    super.initState();
    fetchShopData();
  }

  Future<void> fetchShopData() async {
    final shopData = await FirebaseFirestore.instance
        .collection('Shops')
        .doc(widget.shopId)
        .get();

    if (shopData.exists) {
      setState(() {
        _shopName = shopData['shopName'];
      });
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await ImagePicker().getImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _attachedImages.add(File(image.path));
      });
    }
  }

  Future<void> _pickVideo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp4', 'avi', 'wmv', 'mov'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      if (file.lengthSync() > 104857600) {
        // 100 MB
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('File size exceeded'),
            content: Text('Please select a file of size less than 100 MB'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      } else {
        setState(() {
          _attachedVideos.add(file);
        });
      }
    }
  }

  Future<void> _submitForm(
    String shopName,
    String phoneNumberShop,
    String shopImage,
  ) async {
    if (_isSubmitting) {
      // If submission is already in progress, skip the submission
      return;
    }

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _isSubmitting = true; // Set flag to true when submission begins
      });

      // Get the current user
      User? user = FirebaseAuth.instance.currentUser;

      // Check if the user is authenticated
      if (user != null) {
        // Get the UID of the current user
        String uid = user.uid;

        // Fetch user information from the "users" collection
        DocumentSnapshot userSnapshot =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();

        // Get the fullName from the user document
        String fullName = userSnapshot['fullName'];
        String phoneNumber = userSnapshot['phoneNumber'];
        String address = userSnapshot['address'];

        // Upload images to Firebase Cloud Storage
        List<String> imageUrls = [];
        for (final imageFile in _attachedImages) {
          String imageFileName =
              DateTime.now().millisecondsSinceEpoch.toString();
          firebase_storage.Reference ref = firebase_storage
              .FirebaseStorage.instance
              .ref('files/$imageFileName.jpg');
          try {
            await ref.putFile(imageFile);
            String imageUrl = await ref.getDownloadURL();
            imageUrls.add(imageUrl);
            print('Image uploaded successfully: $imageUrl');
          } catch (e) {
            print('Image upload failed: $e');
          }
        }

        // Upload videos to Firebase Cloud Storage
        List<String> videoUrls = [];
        for (final videoFile in _attachedVideos) {
          String videoFileName =
              DateTime.now().millisecondsSinceEpoch.toString();
          firebase_storage.Reference ref = firebase_storage
              .FirebaseStorage.instance
              .ref('files/$videoFileName.mp4');
          try {
            await ref.putFile(videoFile);
            String videoUrl = await ref.getDownloadURL();
            videoUrls.add(videoUrl);
            print('Video uploaded successfully: $videoUrl');
          } catch (e) {
            print('Video upload failed: $e');
          }
        }

        // Upload data to Firestore
        try {
          await FirebaseFirestore.instance.collection('request').add({
            'customerId': uid,
            'shopId': widget.shopId, // Add the shopId to the request
            'shopName': shopName, // Use the passed shopName
            'description': _description,
            'phoneNumberShop': phoneNumberShop,
            'fullName': fullName,
            'phoneNumber': phoneNumber,
            'services': [widget.typeServices],
            'shopImage': shopImage,
            'address': address,
            'imageUrls': imageUrls,
            'videoUrls': videoUrls,
            'status': 'Pending', // Set the status as "Pending"
            'dateTime': DateTime.now(), // Add the current DateTime
          });
          print('Data uploaded to Firestore successfully.');

          // Show success dialog
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text('Submit Successful'),
              content: Text('Your request has been submitted successfully.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyTabBar(),
                      ),
                    );
                  },
                  child: Text('OK'),
                ),
              ],
            ),
          );
        } catch (e) {
          print('Firestore upload failed: $e');
        }
      }

      setState(() {
        _isSubmitting =
            false; // Set flag back to false when submission is completed
      });
    }
  }

  void _viewAttachment(int index, AttachmentType type) {
    if (type == AttachmentType.image) {
      // Display image attachment
      print('Viewing image attachment: ${_attachedImages[index].path}');
    } else if (type == AttachmentType.video) {
      // Display video attachment
      print('Viewing video attachment: ${_attachedVideos[index].path}');
    }

    // Remove the selected attachment
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Remove Attachment'),
        content: Text('Do you want to remove this attachment?'),
        actions: [
          TextButton(
            onPressed: () {
              if (type == AttachmentType.image) {
                setState(() {
                  _attachedImages.removeAt(index);
                });
              } else if (type == AttachmentType.video) {
                setState(() {
                  _attachedVideos.removeAt(index);
                });
              }
              Navigator.pop(context);
            },
            child: Text('Remove'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 0, 0, 0),
        title: Text('Submit Request'),
      ),
      backgroundColor: Colors.white70,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 4,
                margin: EdgeInsets.all(8.0),
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  side: BorderSide(color: Colors.grey),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Shop name:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        _shopName,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Type of Services : ',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        widget.typeServices,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                elevation: 4,
                margin: EdgeInsets.all(8.0),
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  side: BorderSide(color: Colors.grey),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      controller: _descriptionController,
                      focusNode: _focusNode,
                      maxLines: 10,
                      maxLength: 500,
                      decoration: InputDecoration(
                        hintText: "Enter your description",
                      ),
                      onChanged: (value) {
                        setState(() {
                          _description = value;
                        });
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _pickImage,
                    style: ElevatedButton.styleFrom(
                      primary: Colors.black,
                    ),
                    child: Text('Attach Image'),
                  ),
                  SizedBox(width: 40),
                  ElevatedButton(
                    onPressed: _pickVideo,
                    style: ElevatedButton.styleFrom(
                      primary: Colors.black,
                    ),
                    child: Text('Attach Video'),
                  ),
                ],
              ),
              if (_attachedImages.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              _showAttachments[0] = !_showAttachments[0];
                            });
                          },
                          child: Row(
                            children: [
                              Icon(
                                _showAttachments[0]
                                    ? Icons.arrow_drop_up
                                    : Icons.arrow_drop_down,
                                color: _showAttachments[0]
                                    ? Colors.blue
                                    : Colors.grey,
                              ),
                              Text(
                                'Images (${_attachedImages.length})',
                                style: TextStyle(
                                  color: _showAttachments[0]
                                      ? Colors.blue
                                      : Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _attachedImages.clear();
                            });
                          },
                          icon: Icon(Icons.delete),
                        ),
                      ],
                    ),
                    if (_showAttachments[0])
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (int i = 0; i < _attachedImages.length; i++)
                              Stack(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      _viewAttachment(i, AttachmentType.image);
                                    },
                                    child: Row(
                                      children: [
                                        Image.file(
                                          _attachedImages[i],
                                          width: 100,
                                          height: 100,
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            setState(() {
                                              _attachedImages.removeAt(i);
                                            });
                                          },
                                          icon: Icon(Icons.delete),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              SizedBox(height: 20),
              if (_attachedVideos.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              _showAttachments[1] = !_showAttachments[1];
                            });
                          },
                          child: Row(
                            children: [
                              Icon(
                                _showAttachments[1]
                                    ? Icons.arrow_drop_up
                                    : Icons.arrow_drop_down,
                                color: _showAttachments[1]
                                    ? Colors.blue
                                    : Colors.grey,
                              ),
                              Text(
                                'Videos (${_attachedVideos.length})',
                                style: TextStyle(
                                  color: _showAttachments[1]
                                      ? Colors.blue
                                      : Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _attachedVideos.clear();
                            });
                          },
                          icon: Icon(Icons.delete),
                        ),
                      ],
                    ),
                    if (_showAttachments[1])
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (int i = 0; i < _attachedVideos.length; i++)
                              Stack(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      _viewAttachment(i, AttachmentType.video);
                                    },
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.video_library,
                                          size: 100,
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            setState(() {
                                              _attachedVideos.removeAt(i);
                                            });
                                          },
                                          icon: Icon(Icons.delete),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              SizedBox(height: 20),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
  onPressed: () {
    // Call the _submitForm method only if not currently submitting
    if (!_isSubmitting) {
      _submitForm(
        _shopName,
        widget.phoneNumberShop,
        widget.shopImage,
      );
    }
  },
  style: ElevatedButton.styleFrom(
    primary: Colors.black,
  ),
  child: _isSubmitting
      ? CircularProgressIndicator() // Show loading indicator while submitting
      : Text('Submit'),
)

                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum AttachmentType {
  image,
  video,
}
