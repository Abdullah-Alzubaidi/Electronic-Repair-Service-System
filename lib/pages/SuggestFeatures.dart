import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Suggest Features',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SuggestFeatures(),
    );
  }
}

class SuggestFeatures extends StatefulWidget {
  const SuggestFeatures({Key? key}) : super(key: key);

  @override
  _SuggestFeaturesState createState() => _SuggestFeaturesState();
}

class _SuggestFeaturesState extends State<SuggestFeatures> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 0, 0, 0),
        title: const Text("Suggest Features"),
      ),
      backgroundColor: Colors.white70,
      body: Center(
        child: YourWidget(),
      ),
    );
  }
}

class YourWidget extends StatefulWidget {
  @override
  _YourWidgetState createState() => _YourWidgetState();
}

class _YourWidgetState extends State<YourWidget> {
  File? _image;
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
    }
  }

  Future<void> _saveSuggestion() async {
    String title = _titleController.text;
    String description = _descriptionController.text;

    Map<String, dynamic> suggestionData = {
      'title': title,
      'description': description,
      'imageUrl': '',
    };

    if (_image != null) {
      suggestionData['imageUrl'] = await _uploadImage(_image!);
    }

    try {
      await FirebaseFirestore.instance
          .collection('SuggestionFeature')
          .add(suggestionData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Suggestion posted successfully')),
      );
      _resetForm();
    } catch (error) {
      print('Error posting suggestion: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred. Please try again later.')),
      );
    }
  }

  Future<String> _uploadImage(File? image) async {
    if (image != null) {
      try {
        final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        final firebase_storage.Reference ref =
            firebase_storage.FirebaseStorage.instance.ref().child(fileName);

        final firebase_storage.UploadTask uploadTask = ref.putFile(image);
        final firebase_storage.TaskSnapshot snapshot =
            await uploadTask.whenComplete(() {});

        final String imageUrl = await snapshot.ref.getDownloadURL();
        return imageUrl;
      } catch (error) {
        // Handle any errors that occur during image upload
        print('Error uploading image: $error');
        return '';
      }
    } else {
      return ''; // No image selected, return empty string
    }
  }

  void _resetForm() {
    _titleController.clear();
    _descriptionController.clear();
    setState(() {
      _image = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              "Suggest Features",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "You have the opportunity to make a feature suggestion, notify us of any bugs you encounter, or provide feedback on our services.",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SizedBox(height: 16),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            child: TextFormField(
              controller: _titleController,
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                hintText: 'Enter a title',
                hintStyle: TextStyle(color: Colors.black.withOpacity(0.5)),
              ),
            ),
          ),
          SizedBox(height: 16),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            child: TextFormField(
              controller: _descriptionController,
              style: TextStyle(color: Colors.black),
              maxLines: 4,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                hintText: 'Enter a description',
                hintStyle: TextStyle(color: Colors.black.withOpacity(0.5)),
              ),
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _pickImage,
                style: ElevatedButton.styleFrom(
                  primary: Colors.black,
                ),
                child: Text("Image"),
              ),
            ],
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _saveSuggestion,
            style: ElevatedButton.styleFrom(
              primary: Colors.black,
            ),
            child: Text("Post"),
          ),
          if (_image != null)
            Container(
              margin: EdgeInsets.symmetric(vertical: 16),
              child: Image.file(_image!),
            ),
        ],
      ),
    );
  }
}
