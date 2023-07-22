import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MaterialApp(
    home: ComplaintCardPage(),
  ));
}

class ComplaintCard extends StatefulWidget {
  final String customerName;
  final String shopName;
  final String complaint;

  ComplaintCard({
    required this.customerName,
    required this.shopName,
    required this.complaint,
  });

  @override
  _ComplaintCardState createState() => _ComplaintCardState();
}

class _ComplaintCardState extends State<ComplaintCard> {
  String? selectedShop;
  List<String> shopList = [];
  TextEditingController _customerNameController = TextEditingController();
  TextEditingController _complaintController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _customerNameController.text = widget.customerName;
    _complaintController.text = widget.complaint;
    fetchShopNames();
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _complaintController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  void fetchShopNames() {
    FirebaseFirestore.instance.collection('Shops').get().then(
      (QuerySnapshot snapshot) {
        List<String> names = [];
        snapshot.docs.forEach(
          (DocumentSnapshot doc) {
            Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

            if (data != null && data.containsKey('shopName')) {
              String shopName = data['shopName'] as String;
              names.add(shopName);
            }
          },
        );
        setState(() {
          shopList = names;
        });
      },
    ).catchError((error) {
      print('Error retrieving shop names: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4.0,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.black,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10.0),
                topRight: Radius.circular(10.0),
              ),
            ),
            child: Text(
              'COMPLAINT CARD',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Full Name:',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextFormField(
                    controller: _customerNameController,
                    decoration: InputDecoration(
                      hintText: 'Enter your full name',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your full name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    controller: _phoneNumberController,
                    decoration: InputDecoration(
                      hintText: 'Enter your phone number',
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Shop Selected:',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    height: 90,
                    padding: const EdgeInsets.all(20.0),
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        hintText: 'Select a shop',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.blue),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.green),
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 15.0,
                          horizontal: 20.0,
                        ),
                      ),
                      value: selectedShop,
                      items: shopList.map((String value) {
                        // Add a prefix to shop names containing numbers
                        if (value.contains(RegExp(r'\d'))) {
                          value = "shop_$value";
                        }
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toSet().toList(),
                      onChanged: (String? shop) {
                        setState(() {
                          selectedShop = shop;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Complaint:',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  TextFormField(
                    controller: _complaintController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Enter your complaint',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your complaint';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Get the complaint data from the form
                        String description = _complaintController.text;
                        String fullName = _customerNameController.text;
                        String phoneNumber = _phoneNumberController.text;
                        String shopName = selectedShop ?? "";

                        // Send the complaint data to Firestore
                        FirebaseFirestore.instance
                            .collection('complaints')
                            .add({
                          'description': description,
                          'fullName': fullName,
                          'phoneNumber': phoneNumber,
                          'shopName': shopName,
                        }).then((value) {
                          // Clear the form fields
                          _customerNameController.clear();
                          _phoneNumberController.clear();
                          setState(() {
                            selectedShop = null;
                          });
                          _complaintController.clear();

                          // Show success dialog
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Success'),
                                content:
                                    Text('Complaint submitted successfully.'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context); // Close the dialog
                                      _formKey.currentState!
                                          .reset(); // Reset the form fields
                                    },
                                    child: Text('OK'),
                                  ),
                                ],
                              );
                            },
                          );
                        }).catchError((error) {
                          print('Errorsubmitting complaint: $error');
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.black,
                    ),
                    child: Text('Submit Complaint'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ComplaintCardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white70,
      appBar: AppBar(
        title: Text('Complaint'),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ComplaintCard(
                customerName: '',
                shopName: '',
                complaint: '',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
