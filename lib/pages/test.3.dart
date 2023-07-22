// ignore_for_file: deprecated_member_use, use_key_in_widget_constructors, unused_field, prefer_final_fields, prefer_const_constructors

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Submit extends StatefulWidget {
  @override
  SubmitState createState() => SubmitState();
}

class SubmitState extends State<Submit> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _shopName = '';
  String _description = '';
  List<File> _attachedFiles = [];

  final _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final file = await ImagePicker().getVideo(source: ImageSource.gallery);
    if (file != null) {
      setState(() {
        _attachedFiles.add(File(file.path));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 71, 65, 65),
        title: Text('Submit Request'),
      ),
      backgroundColor: Color.fromARGB(255, 45, 171, 175),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: InputDecoration(labelText: 'Shop Name'),
                  onSaved: (value) => _shopName = value ?? '',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Shop name cannot be empty';
                    }
                    return null;
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  focusNode: _focusNode,
                  maxLines:
                      10, // Allow the TextField to grow vertically to show all comments
                  maxLength: 500, // Set the maximum number of characters to 500
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: _pickImage,
                  style: ElevatedButton.styleFrom(
                    primary: Colors.black, // Change button color here
                  ),
                  child: Text('Attach File'),
                ),
              ),
              if (_attachedFiles.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      for (final file in _attachedFiles)
                        Row(
                          children: [
                            Expanded(child: Text(file.path)),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _attachedFiles.remove(file);
                                });
                              },
                              icon: Icon(Icons.delete),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      // Do something with the form data, like send it to a server or store it locally
                      // _shopName and _description hold the values entered in the form
                      // _attachedFiles holds the list of files attached by the user

                    }
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.black, // Change button color here
                  ),
                  child: Text('Submit'),

                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



