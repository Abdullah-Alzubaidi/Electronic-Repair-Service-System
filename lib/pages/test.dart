import 'package:flutter/material.dart';

class Hotel {
  final String name;
  final String location;
  final String description;

  Hotel({required this.name, required this.location, required this.description});
}

class HotelListScreen extends StatelessWidget {
  final List<Hotel> hotels = [
    Hotel(
      name: "Grand Luxe Resort",
      location: "123 Main Street, Cityville",
      description: "A luxurious 5-star hotel offering breathtaking views, spacious rooms, gourmet dining, and a state-of-the-art spa.",
    ),
    Hotel(
      name: "Seaside Haven Hotel",
      location: "456 Ocean Avenue, Beachtown",
      description: "Nestled along the coast, this charming boutique hotel offers cozy rooms, beachfront access, and a rooftop terrace with panoramic ocean views.",
    ),
    Hotel(
      name: "Mountain View Lodge",
      location: "789 Pine Road, Mountainville",
      description: "Surrounded by majestic peaks, this rustic lodge provides comfortable accommodations, an on-site restaurant serving local cuisine, and easy access to hiking trails.",
    ),
    // Add more hotels here...
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hotel List'),
      ),
      body: ListView.builder(
        itemCount: hotels.length,
        itemBuilder: (context, index) {
          final hotel = hotels[index];
          return Card(
            child: ListTile(
              title: Text(hotel.name),
              subtitle: Text(hotel.location),
              onTap: () {
                // Perform actions when a hotel is tapped
                // For example, navigate to a detail screen
              },
            ),
          );
        },
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: HotelListScreen(),
  ));
}
