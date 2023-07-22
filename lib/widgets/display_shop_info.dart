/*import 'package:flutter/material.dart';

import '../Mixin.dart';

class DisplayShopInfo extends StatefulWidget {
  final bool isCustomer;
  final bool isOperationHours;
  final bool isPaymentMethod;
  final bool isMap;
  

  const DisplayShopInfo({required this.isCustomer,required this.isOperationHours,required this.isPaymentMethod,required this.isMap, super.key});

  @override
  State<DisplayShopInfo> createState() => _DisplayShopInfo();
}

class _DisplayShopInfo extends State<DisplayShopInfo> with MyMixin{
  bool showTimeSelection = true;
  bool cashSelected = false;
  bool cardSelected = false;
void updateOperationHours(String start, String end) {
  setState(() {
    startOperationHours = start;
    endOperationHours = end;
  });
}
  @override
  Widget build(BuildContext context) {
    if(widget.isCustomer){
      if(widget.isOperationHours){
        return Container();
      }
      else if(widget.isPaymentMethod){
        return Container();
      }
      else if(widget.isMap){
        return Container();
      }else{
        return Container();
      }
    }else{
      if(widget.isOperationHours){
        return Column(
                  children: [
                  const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Operation Hours',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                if (startOperationHours.isEmpty || endOperationHours.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            _selectTime(context, true);
                          },
                          child: Text(
                            startOperationHours.isEmpty
                                ? 'Select Start Time'
                                : startOperationHours,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _selectTime(context, false);
                          },
                          child: Text(
                            endOperationHours.isEmpty
                                ? 'Select End Time'
                                : endOperationHours,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                if (startOperationHours.isNotEmpty &&
                    endOperationHours.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Opening Hours: ${getOpeningHours()}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              showTimeSelection = true;
                            });
                            _selectTime(context, true);
                          },
                          icon: Icon(Icons.edit),
                        ),
                      ],
                    ),
                  ),

                ],
                );
      
      }
      else if(widget.isPaymentMethod){
        return  Column(
                  children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Payment Methods:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,

                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            cashSelected = true;
                            cardSelected = false;
                          });
                        },
                        
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color:
                                      cashSelected ? Colors.blue : Colors.grey,
                                  width: 2,
                                ),
                              ),
                              child: cashSelected
                                  ? Center(child: Icon(Icons.check, size: 16))
                                  : null,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Cash',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 16),
                      InkWell(
                        onTap: () {
                          setState(() {
                            cashSelected = false;
                            cardSelected = true;
                          });
                        },
                        child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color:
                                      cardSelected ? Colors.blue : Colors.grey,
                                  width: 2,
                                ),
                              ),
                              child: cardSelected
                                  ? Center(child: Icon(Icons.check, size: 16))
                                  : null,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Card',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                ],);

      }
      else if(widget.isMap){
        return Container();
      }else{
        return Container();
      }
    }
  }
  Future<void> _selectTime(context, bool isStart) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        if (isStart) {
          startOperationHours = pickedTime.format(context);
          endOperationHours = '';
          showTimeSelection = false;
        } else {
          endOperationHours = pickedTime.format(context);
          showTimeSelection = true;
        }
      });
    }
  }
}*/