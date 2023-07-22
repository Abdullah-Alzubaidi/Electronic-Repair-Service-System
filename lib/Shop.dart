import 'package:FixZone/User.dart';

class Shop extends User{
  
  final String shopName;
  
  Shop({
    required super.fullName, 
    required super.email, 
    required super.address, 
    required super.phoneNumber, 
    required super.userType, 
    required super.uid,
    required super.imageUrl,
    required this.shopName});
  
}