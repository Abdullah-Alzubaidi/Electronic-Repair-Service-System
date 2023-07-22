import 'package:flutter/material.dart';

class test_1 extends StatelessWidget {
  const test_1 ({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 0, 0, 0),
        title: const Text("My Requests:"),
      ),
      backgroundColor: Color.fromARGB(255, 45, 171, 175),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            OrderCard(),
            SizedBox(height: 16.0),
            OrderCard(),
            SizedBox(height: 16.0),
            OrderCard(),
            // Add more OrderCard instances as needed
          ],
        ),
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
           // Container(
            //  width: 80,
            //  height: 80,

              ////decoration: BoxDecoration(
                ///image: DecorationImage(
                 // image: AssetImage('assets/shop_logo.png'),
                  ///fit: BoxFit.cover,
                //),
              //),
          //  ),
            SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Shop Name',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Order ID: ABC123',
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Date and Time: May 21, 2023, 10:00 AM',
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Fee Charged: \$25.00',
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16.0),
            Column(
              children: [
                IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    // Handle call functionality
                  },
                ),
                SizedBox(height: 8.0),
                IconButton(
                  icon: Icon(Icons.star),
                  onPressed: () {
                    // Handle rating functionality
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
