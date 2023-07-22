import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

mixin MyMixin {
  late String startOperationHours;
  late String endOperationHours;

 void sendShopInfo(String uid,TextEditingController addressController)async {

        CollectionReference shopInfoCollection =
            FirebaseFirestore.instance.collection('shopInfo');
              DocumentReference documentRef = shopInfoCollection.doc();

        Map<String, dynamic> data = {            
              'shopId': uid,
              'startOperationHours': startOperationHours,
              'endOperationHours':endOperationHours,
              'Location' : 'https://maps.google.com?q=${addressController.text}'
          
        };
                await documentRef.set(data, SetOptions(merge: true));

    } 
  void updateRequestStatus(String requestId, String status) {
    FirebaseFirestore.instance
        .collection('request')
        .doc(requestId)
        .update({'status': status})
        .then((value) {
      // Request status updated successfully
    }).catchError((error) {
      // Error updating request status
    });

    
  }
String getOpeningHours() {
    if (startOperationHours.isNotEmpty && endOperationHours.isNotEmpty) {
startOperationHours=startOperationHours;
      endOperationHours=endOperationHours;
      return '$startOperationHours - $endOperationHours';
    }
    return '';
  }

   

    bool showTimeSelection = true;


}