import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Feature Page Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FeatureListPage(),
    );
  }
}

class Feature {
  final String title;
  final String description;
  final String attachmentImage;
  final String customerName;

  Feature({
    required this.title,
    required this.description,
    required this.attachmentImage,
    required this.customerName,
  });
}

class FeatureListPage extends StatelessWidget {
  final CollectionReference suggestionFeatureCollection =
      FirebaseFirestore.instance.collection('SuggestionFeature');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Suggestion List'),
        backgroundColor: Colors.black,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: suggestionFeatureCollection.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          List<Feature> features =
              snapshot.data!.docs.map((QueryDocumentSnapshot doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            return Feature(
              title: data['title'] ?? '',
              description: data['description'] ?? '',
              attachmentImage: data['imageUrl'] ?? '',
              customerName: '',
            );
          }).toList();

          return ListView.builder(
            itemCount: features.length,
            itemBuilder: (context, index) {
              Feature feature = features[index];
              return FeatureCard(
                feature: feature,
              );
            },
          );
        },
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final Feature feature;

  FeatureCard({required this.feature});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FullScreenImage(url: feature.attachmentImage),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: Colors.black,
            width: 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 5.0,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Title:',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5.0),
                    Text(
                      feature.title,
                      style: TextStyle(
                        fontSize: 18.0,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                                color: const Color.fromARGB(255, 0, 0, 0))),
                      ),
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      'Description:',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5.0),
                    Text(
                      feature.description,
                      style: TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                                color: const Color.fromARGB(255, 0, 0, 0))),
                      ),
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      'Attachment Image:',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.0),
                  ],
                ),
              ),
              Container(
                height: 200.0,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3), // Placeholder color
                ),
                child: feature.attachmentImage.isEmpty
                    ? Icon(
                        Icons.image,
                        size: 80,
                        color: Colors.white,
                      )
                    : Image.network(
                        feature.attachmentImage,
                        fit: BoxFit.cover,
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
