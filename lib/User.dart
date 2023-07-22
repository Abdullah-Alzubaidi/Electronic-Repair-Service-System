enum UserType {
  admin,
  customer,
  shop,
  banned
}

class User {
  final String fullName;
  final String email;
  final String address;
  final String phoneNumber;
  final UserType userType;
  final String uid;
  final String imageUrl;
  User({
    
    required this.fullName,
    required this.email,
    required this.address,
    required this.phoneNumber,
    required this.userType,
    required this.uid,
    required this.imageUrl,
  }
  );
}
