import 'package:flutter/material.dart';

import 'package:firebase_storage/firebase_storage.dart';

class Picture extends StatefulWidget {
  const Picture({Key? key}) : super(key: key);

  @override
  State<Picture> createState() => _PictureState();
}

class _PictureState extends State<Picture> {
  String imageUrl = ''; // Variable to store the image URL

  @override
  void initState() {
    super.initState();
    fetchImage(); // Fetch the image URL when the widget initializes
  }

  Future<void> fetchImage() async {
    // Fetch the image URL from Firebase Storage
    // Replace 'your_image_path' with the actual path to your image in Firebase Storage
      String imagePath = 'files/1685815724076.jpg'; // Example path
    String image = await fetchImageUrlFromFirebase(imagePath);
    setState(() {
      imageUrl = image;
    });
  }

  Future<String> fetchImageUrlFromFirebase(String imagePath) async {
  Reference storageReference =
      FirebaseStorage.instance.ref().child(imagePath);

  // Fetch the download URL of the image
  String downloadUrl = await storageReference.getDownloadURL();

  return downloadUrl;
}


  @override
  Widget build(BuildContext context) {
    return imageUrl.isNotEmpty
        ? Image.network(imageUrl) // Display the image if the URL is not empty
        :  Container(); // Display a placeholder if the URL is empty
  }
}
