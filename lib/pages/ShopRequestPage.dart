import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chewie/chewie.dart';
import 'package:FixZone/Mixin.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:FixZone/pages/RequestSummary.dart';

class ShopRequestPage extends StatefulWidget{
  const ShopRequestPage({Key? key}) : super(key: key);

  @override
  _ShopRequestPageState createState() => _ShopRequestPageState();
}

class _ShopRequestPageState extends State<ShopRequestPage> with MyMixin  {
  late Stream<QuerySnapshot<Map<String, dynamic>>> requestStream;
  bool showAttachmentSection = false;
  ChewieController? _chewieController;
  String? uid = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      requestStream = FirebaseFirestore.instance
          .collection('request')
          .where('shopId', isEqualTo: userId)
          .snapshots();
    } else {
      requestStream = FirebaseFirestore.instance.collection('request').snapshots();
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white70,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: Color.fromARGB(255, 0, 0, 0),
            title: const Text("Customer Requests:"),
            floating: true,
            snap: true,
          ),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: requestStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return SliverFillRemaining(
                  child: Center(
                    child: Text('Error: ${snapshot.error}'),
                  ),
                );
              }

              if (!snapshot.hasData) {
                return SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final requests = snapshot.data!.docs.map((doc) {
                final data = doc.data();
                return CustomerRequest(
                  customerId:data['customerId']??'',
                  id: doc.id,
                  customerName: data['fullName'] ?? '',
                  customerDescription: data['description'] ?? '',
                  attachmentFileUrls:
                      List<String>.from(data['imageUrls'] ?? []),
                  videoUrls: List<String>.from(data['videoUrls'] ?? []),
                  status: data['status'] ?? '',
                  typeOfServices: data['services']?.toString() ?? '',
                  address: data['address'] ?? '',
                  phone:data['phoneNumber']?.toString()??'',
                );
              }).toList();

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    if (index == requests.length) {
                      return Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.all(10.0),
                        child: Text(
                          'No more requests',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }

                    final request = requests[index];
                    if (request.status == 'Accepted' || request.status == 'Canceled') {
                      return SizedBox.shrink(); // Hide the request if it's accepted or canceled
                    }
                    return buildRequestCard(request);
                  },
                  childCount: requests.length + 1,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget buildRequestCard(CustomerRequest request) {
    final String truncatedDescription = request.customerDescription.length > 500
        ? '${request.customerDescription.substring(0, 500)}...'
        : request.customerDescription;
if(request.status=='Pending'){
return Padding(
      padding: const EdgeInsets.all(10.0),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.near_me, color: Colors.blue, size: 40.0),
                title: Text(
                  'Request: ${request.customerName}',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    truncatedDescription,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ),
              Text(
                'Type of service: ${request.typeOfServices}', // Add this line
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10.0),
              Text(
                'The location: ${request.address}', // Add this line
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10.0),
              Text(
                'Phone: ${request.phone}', // Add this line
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ElevatedButton(
                    child: Text('Add Invoice'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.yellow,
                      textStyle: TextStyle(fontSize: 14.0),
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onPressed: () {
                     // Navigator.pushNamed(context, "/RequestSummary",arguments:{'userId':request.id,'shopId':uid});
                      Navigator.push(context,MaterialPageRoute(builder: (context) => RequestSummary(userId:request.customerId,requestId: request.id,shopId:uid!
    ),
  ),
);
                      setState(() {}); // Trigger rebuild to hide the accepted request
                    },
                  ),
                  ElevatedButton(
                    child: Text('Reject'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                      textStyle: TextStyle(fontSize: 14.0),
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onPressed: (){updateRequestStatus(request.id, 'Canceled');}
                       // Trigger rebuild to hide the rejected request
                    ,
                  ),
                ],
              ),
              SizedBox(height: 10.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  TextButton(
                    child: Text(
                      'VIEW ATTACHMENT',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        showAttachmentSection = !showAttachmentSection;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 10.0),
              // Display video
              if (showAttachmentSection && request.videoUrls.isNotEmpty)
                Column(
                  children: request.videoUrls.map((url) {
                    final videoPlayerController = VideoPlayerController.network(url);
                    final chewieController = ChewieController(
                      videoPlayerController: videoPlayerController,
                      autoPlay: false,
                      
                      looping: false,
                      // Additional chewie options, such as aspectRatio, showControls, etc.
                      // can be set here as per your requirement.
                    );
                    return Container(
                      height: 200, // Set the desired height for the video
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Chewie(controller: chewieController),
                      ),
                    );
                  }).toList(),
                ),

              SizedBox(height: 10.0),
              // Display attachment images
              if (showAttachmentSection && request.attachmentFileUrls.isNotEmpty)
              Column(
                children: request.attachmentFileUrls.map((url) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullScreenImage(url: url),
                        ),
                      );
                    },
                    child: Image.network(url, height: 200),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    ),
  );

  
}else if(request.status=='Review'){
return Padding(
      padding: const EdgeInsets.all(10.0),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.near_me, color: Colors.blue, size: 40.0),
                title: Text(
                  'Request: ${request.customerName}',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    truncatedDescription,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ),
              Text(
                'Type of service: ${request.typeOfServices}', // Add this line
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10.0),
              Text(
                'The location: ${request.address}', // Add this line
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10.0),
              Text(
                'Phone: ${request.phone}', // Add this line
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10.0),
              ElevatedButton(
                    child: Text('under review'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.pink,
                      textStyle: TextStyle(fontSize: 14.0),
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onPressed: (){;}
                       // Trigger rebuild to hide the rejected request
                    ,
                  ),
              SizedBox(height: 10.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  TextButton(
                    child: Text(
                      'VIEW ATTACHMENT',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        showAttachmentSection = !showAttachmentSection;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 10.0),
              // Display video
              if (showAttachmentSection && request.videoUrls.isNotEmpty)
                Column(
                  children: request.videoUrls.map((url) {
                    final videoPlayerController = VideoPlayerController.network(url);
                    final chewieController = ChewieController(
                      videoPlayerController: videoPlayerController,
                      autoPlay: false,
                      
                      looping: false,
                      // Additional chewie options, such as aspectRatio, showControls, etc.
                      // can be set here as per your requirement.
                    );
                    return Container(
                      height: 200, // Set the desired height for the video
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Chewie(controller: chewieController),
                      ),
                    );
                  }).toList(),
                ),

              SizedBox(height: 10.0),
              // Display attachment images
              if (showAttachmentSection && request.attachmentFileUrls.isNotEmpty)
              Column(
                children: request.attachmentFileUrls.map((url) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullScreenImage(url: url),
                        ),
                      );
                    },
                    child: Image.network(url, height: 200),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    ),
  );
   
}else{
  return Container();
}
    }

  
}

class CustomerRequest {
  final String id;
  final String customerId;
  final String customerName;
  final String customerDescription;
  final String address;
  final String  phone;
  final List<String> attachmentFileUrls;
  final List<String> videoUrls;
  final String status;
  final String typeOfServices;

  CustomerRequest({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerDescription,
    required this.address,
    required  this.phone,
    required this.attachmentFileUrls,
    required this.videoUrls,
    required this.status,
    required this.typeOfServices,
  });
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shop Request Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ShopRequestPage(),
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
          panEnabled: false, // Disable panning
          boundaryMargin: EdgeInsets.all(20),
          minScale: 0.5,
          maxScale: 5.0,
          child: Image.network(url),
        ),
      ),
    );
  }
}