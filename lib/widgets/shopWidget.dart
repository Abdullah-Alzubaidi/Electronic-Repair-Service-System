// ignore_for_file: prefer_const_constructors, avoid_unnecessary_containers, prefer_const_literals_to_create_immutables, camel_case_types

import 'package:flutter/material.dart';
class shop_widget extends StatelessWidget {
  const shop_widget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blueGrey,
      child: Row(
        children: [
          Container(
            height: 100,
            width: 100,
            color: Colors.green,
          child: Text('image'),
        ),
        Container(
          child: Column(children: [
             Text('resturant name'),
             Text('Open'),
             Text('delivery fee')
          ]
          ),
        ),
        Container(
          child: Text('extra space for information'),
        )
        ],
      ),
    );
  }
}