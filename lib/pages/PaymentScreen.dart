// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:FixZone/pages/customers_page.dart' ;

void main() {
  runApp(SandboxPaymentTextingApp());
}

class SandboxPaymentTextingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: PaymentTextingScreen(),
    );
  }
}


class PaymentTextingScreen extends StatefulWidget {
  @override
  _PaymentTextingScreenState createState() => _PaymentTextingScreenState();
}

class _PaymentTextingScreenState extends State<PaymentTextingScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _cardHolderController = TextEditingController();
  AnimationController? _animationController;
  Animation<double>? _cardAnimation;
  String? _cardNumberErrorMessage;
  String? _expiryDateErrorMessage;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _cardAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController!,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController!.dispose();
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    _cardHolderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(' Payment '),
      ),
      backgroundColor: const Color.fromARGB(230, 255, 255, 255),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 30),
            Text(
              'Provide the following details for your credit or debit card :',
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _cardNumberController,
              decoration: InputDecoration(
                labelText: 'Card Number',
                hintText: 'Enter your card number',
                border: OutlineInputBorder(),
                errorText: _cardNumberErrorMessage,
              ),
              onChanged: (value) {
                setState(() {
                  if (value.isNotEmpty) {
                    _animationController!.forward();
                  } else {
                    _animationController!.reverse();
                  }
                  _cardNumberErrorMessage = _validateCardNumber(value);
                });
              },
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _expiryDateController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Expiry Date',
                      hintText: 'MM/YY',
                      border: OutlineInputBorder(),
                      errorText: _expiryDateErrorMessage,
                    ),
                    onChanged: (value) {
                      setState(() {
                        if (value.length == 2 &&
                            !_expiryDateController.text.endsWith('/')) {
                          _expiryDateController.text += '/';
                          _expiryDateController.selection =
                              TextSelection.fromPosition(
                            TextPosition(offset: value.length + 1),
                          );
                        } else if (value.length == 2 &&
                            _expiryDateController.text.endsWith('/')) {
                          _expiryDateController.text = value.substring(0, 1);
                          _expiryDateController.selection =
                              TextSelection.fromPosition(
                            TextPosition(offset: 1),
                          );
                        } else if (value.length > 5) {
                          _expiryDateController.text = value.substring(0, 5);
                          _expiryDateController.selection =
                              TextSelection.fromPosition(
                            TextPosition(offset: 5),
                          );
                        }

                        _expiryDateErrorMessage = _validateExpiryDate(value);
                      });
                    },
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _cvvController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'CVV',
                      hintText: 'Enter CVV',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        if (value.length > 3) {
                          _cvvController.text = value.substring(0, 3);
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _cardHolderController,
              decoration: InputDecoration(
                labelText: 'Cardholder Name',
                hintText: 'Enter cardholder name',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
            SizedBox(height: 30),
            if (_animationController != null && _cardAnimation != null)
              AnimatedBuilder(
                animation: _animationController!,
                builder: (context, child) {
                  return Opacity(
                    opacity: _cardAnimation!.value,
                    child: Transform.scale(
                      scale: _cardAnimation!.value,
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: Container(
                          padding: EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blue, Colors.indigo],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Image.asset(
                                    'assets/images/visa_logo.png',
                                    height: 48,
                                  ),
                                  Icon(
                                    Icons.credit_card,
                                    color: Colors.white,
                                    size: 48,
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              Text(
                                _cardNumberController.text,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'CARD HOLDER',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                _cardHolderController.text,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'EXPIRES',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          _expiryDateController.text,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'CVV',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          _cvvController.text,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _cardNumberErrorMessage =
                        _validateCardNumber(_cardNumberController.text);
                    _expiryDateErrorMessage =
                        _validateExpiryDate(_expiryDateController.text);

                    if (_cardNumberErrorMessage!.isEmpty &&
                        _expiryDateErrorMessage!.isEmpty) {
                      _showPaymentConfirmationDialog();
                    }
                  });
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                       Colors.black54), // Change the color here
                ),
                child: Text('Pay'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _validateCardNumber(String value) {
    if (value.isEmpty) {
      return 'Card number is required';
    }
    if (value.length < 16) {
      return 'Card number must be 16 digits';
    }
    return '';
  }

  String _validateExpiryDate(String value) {
    if (value.isEmpty) {
      return 'Expiry date is required';
    }
    if (value.length != 5 || !value.contains('/')) {
      return 'Expiry date must be in MM/YY format';
    }
    final parts = value.split('/');
    final month = int.tryParse(parts[0]);
    final year = int.tryParse(parts[1]);
    if (month == null || year == null || month < 1 || month > 12) {
      return 'Invalid expiry date';
    }
    return '';
  }

  void _showPaymentConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Payment Confirmation'),
          content: Text('Are you sure you want to proceed with the payment?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showSuccessDialog();
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Payment Successful'),
          content: Text('Thank you for your payment!'),
          actions: [
            ElevatedButton(
              onPressed: () {
                                        Navigator.push(context,MaterialPageRoute(builder: (context) => CustomerPage()),);
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
