// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'History App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HistoryPage(),
    );
  }
}

class HistoryEntry {
  final String customerName;
  final String status;
  final DateTime? date;
  final String description;
  final String serviceType;
  final String phoneNumber;
  final String address;
  final String paymentMethod;
  final String feeCharge;

  HistoryEntry({
    required this.customerName,
    required this.status,
    required this.date,
    required this.description,
    required this.serviceType,
    required this.phoneNumber,
    required this.address,
    required this.paymentMethod,
    required this.feeCharge,
  });
}

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<HistoryEntry> historyEntries = [];

  List<HistoryEntry> filteredEntries = [];
  List<String> serviceTypes = [];
  Map<String, int> serviceCount = {};
  Map<String, double> incomeByType = {};

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredEntries = historyEntries;
    calculateServiceCounts();
    calculateIncomeByType();
    fetchHistoryData();
  }

  String formatDateTime(Timestamp? timestamp) {
    final dateTime = timestamp?.toDate();
    final formattedDateTime = dateTime != null
        ? DateFormat('yyyy-MM-dd hh:mm a').format(dateTime)
        : '';
    return formattedDateTime;
  }

  void fetchHistoryData() async {
    final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final String userId = user.uid;


    // Fetch data from Firestore collection
     final QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('request')
      .where('shopId', isEqualTo: userId)
      .where('status', isEqualTo: 'Completed')
      .get();

    // Convert query snapshot to a list of HistoryEntry objects
    final List<HistoryEntry> entries = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>?;

      if (data != null) {
         final dateTimestamp = data['dateTime'] as Timestamp?;
      final date = dateTimestamp?.toDate();

        return HistoryEntry(
          customerName: data['fullName'] as String? ?? '',
          status: data['status'] as String? ?? '',
          date: date,
          description: data['description'] as String? ?? '',
          serviceType:
              _parseServiceType(data['services']) ?? 'Default Service Type',
          phoneNumber: data['phoneNumber'].toString(),
          address: data['address'] as String? ?? '',
          paymentMethod: data['payment'] as String? ?? '',
          feeCharge: (data['total'] as num?)?.toStringAsFixed(2) ?? '',
        );
      } else {
        // Handle the case where data is null (optional)
        // For example, you can return a default HistoryEntry or throw an exception.
        return HistoryEntry(
          address: '',
          date: null,
          customerName: '',
          description: '',
          status: '',
          feeCharge: '',
          paymentMethod: '',
          phoneNumber: '',
          serviceType: '',
        );
      }
    }).toList();

    setState(() {
      historyEntries = entries;
      filteredEntries = entries; // Assign fetched entries to filteredEntries as well
    calculateServiceCounts();
    calculateIncomeByType();
    });
  }

  String? _parseServiceType(dynamic value) {
    if (value is List<dynamic>) {
      return value.join(', ');
    } else if (value is String) {
      return value;
    } else {
      return null;
    }
  }

  void calculateServiceCounts() {
    serviceCount.clear();
    for (var entry in filteredEntries) {
      if (serviceCount.containsKey(entry.serviceType)) {
        serviceCount[entry.serviceType] = serviceCount[entry.serviceType]! + 1;
      } else {
        serviceCount[entry.serviceType] = 1;
      }
    }
  }

  void calculateIncomeByType() {
    incomeByType.clear();
    for (var entry in filteredEntries) {
      if (incomeByType.containsKey(entry.serviceType)) {
        double feeCharge =
            double.tryParse(entry.feeCharge.split(" ")[0]) ?? 0.0;
        incomeByType[entry.serviceType] =
            incomeByType[entry.serviceType]! + feeCharge;
      } else {
        double feeCharge =
            double.tryParse(entry.feeCharge.split(" ")[0]) ?? 0.0;
        incomeByType[entry.serviceType] = feeCharge;
      }
    }
  }

  void searchEntries(String searchText) {
  setState(() {
    if (searchText.isEmpty) {
      filteredEntries = historyEntries;
    } else {
      filteredEntries = historyEntries
          .where((entry) =>
              entry.customerName.toLowerCase().contains(searchText.toLowerCase()) == true ||
              (entry.date != null && DateFormat('MMMM d, yyyy').format(entry.date!).toLowerCase().contains(searchText.toLowerCase())) ||
              entry.description.toLowerCase().contains(searchText.toLowerCase()) == true ||
              entry.serviceType.toLowerCase().contains(searchText.toLowerCase()) == true ||
              entry.phoneNumber.toLowerCase().contains(searchText.toLowerCase()) == true ||
              entry.address.toLowerCase().contains(searchText.toLowerCase()) == true)
          .toList();
    }
    calculateServiceCounts();
    calculateIncomeByType();
  });
}


  double calculateTotalIncome() {
    double totalIncome = 0;
    for (var entry in filteredEntries) {
      double feeCharge = double.tryParse(entry.feeCharge.split(" ")[0]) ?? 0.0;
      totalIncome += feeCharge;
    }
    return totalIncome;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('History'),
        actions: [
          IconButton(
            icon: Icon(Icons.analytics),
            onPressed: () {
              // Show options for selecting statistics period
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Select Statistics Period'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          title: Text('Today'),
                          onTap: () {
                            Navigator.pop(context);
                            navigateToStatisticsPage(
                                getTodayEntries(), 'Today');
                          },
                        ),
                        ListTile(
                          title: Text('Weekly'),
                          onTap: () {
                            Navigator.pop(context);
                            navigateToStatisticsPage(
                                getWeeklyEntries(), 'Weekly');
                          },
                        ),
                        ListTile(
                          title: Text('Monthly'),
                          onTap: () {
                            Navigator.pop(context);
                            navigateToStatisticsPage(
                                getMonthlyEntries(), 'Monthly');
                          },
                        ),
                        ListTile(
                          title: Text('Yearly'),
                          onTap: () {
                            Navigator.pop(context);
                            navigateToStatisticsPage(
                                getYearlyEntries(), 'Yearly');
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      backgroundColor:  Colors.white70,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              onChanged: searchEntries,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                prefixIcon: Icon(Icons.search),
                hintText: 'Search...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: filteredEntries.length,
              itemBuilder: (context, index) {
                return HistoryCard(
                  historyEntry: filteredEntries[index],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<HistoryEntry> getTodayEntries() {
  final now = DateTime.now();
  final startOfToday = DateTime(now.year, now.month, now.day);
  final endOfToday = startOfToday.add(Duration(days: 1));
  final todayEntries = historyEntries.where((entry) {
    final entryDate = entry.date;
    return entryDate != null && entryDate.isAfter(startOfToday) && entryDate.isBefore(endOfToday);
  }).toList();
  return todayEntries;
}

List<HistoryEntry> getWeeklyEntries() {
  final now = DateTime.now();
  final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
  final endOfWeek = now.add(Duration(days: DateTime.daysPerWeek - now.weekday));
  final weeklyEntries = historyEntries.where((entry) {
    final entryDate = entry.date;
    return entryDate != null && entryDate.isAfter(startOfWeek) && entryDate.isBefore(endOfWeek);
  }).toList();
  return weeklyEntries;
}

List<HistoryEntry> getMonthlyEntries() {
  final now = DateTime.now();
  final startOfMonth = DateTime(now.year, now.month, 1);
  final endOfMonth = DateTime(now.year, now.month + 1, 0);
  final monthlyEntries = historyEntries.where((entry) {
    final entryDate = entry.date;
    return entryDate != null && entryDate.isAfter(startOfMonth) && entryDate.isBefore(endOfMonth);
  }).toList();
  return monthlyEntries;
}

List<HistoryEntry> getYearlyEntries() {
  final now = DateTime.now();
  final startOfYear = DateTime(now.year, 1, 1);
  final endOfYear = DateTime(now.year, 12, 31);
  final yearlyEntries = historyEntries.where((entry) {
    final entryDate = entry.date;
    return entryDate != null && entryDate.isAfter(startOfYear) && entryDate.isBefore(endOfYear);
  }).toList();
  return yearlyEntries;
}


  void navigateToStatisticsPage(List<HistoryEntry> entries, String timeFrame) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            StatisticsDetailsPage(entries: entries, timeFrame: timeFrame),
      ),
    );
  }
}

class HistoryCard extends StatelessWidget {
  final HistoryEntry historyEntry;

  HistoryCard({
    required this.historyEntry,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
        ),
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Customer Name: ${historyEntry.customerName}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              'Status: ${historyEntry.status}',
              style: TextStyle(
                fontSize: 14.0,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              'Date: ${historyEntry.date}',
              style: TextStyle(
                fontSize: 14.0,
              ),
            ),
            SizedBox(height: 8.0),
            Divider(color: Colors.grey),
            SizedBox(height: 8.0),
            Text(
              'Description:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.0,
              ),
            ),
            SizedBox(height: 4.0),
            Text(
              historyEntry.description,
              style: TextStyle(
                fontSize: 14.0,
              ),
            ),
            SizedBox(height: 8.0),
            Divider(color: Colors.grey),
            SizedBox(height: 8.0),
            Text(
              'Type of Service:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.0,
              ),
            ),
            SizedBox(height: 4.0),
            Text(
              historyEntry.serviceType,
              style: TextStyle(
                fontSize: 14.0,
              ),
            ),
            SizedBox(height: 8.0),
            Divider(color: Colors.grey),
            SizedBox(height: 8.0),
            Text(
              'Phone Number:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.0,
              ),
            ),
            SizedBox(height: 4.0),
            Text(
              historyEntry.phoneNumber,
              style: TextStyle(
                fontSize: 14.0,
              ),
            ),
            SizedBox(height: 8.0),
            Divider(color: Colors.grey),
            SizedBox(height: 8.0),
            Text(
              'Address:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.0,
              ),
            ),
            SizedBox(height: 4.0),
            Text(
              historyEntry.address,
              style: TextStyle(
                fontSize: 14.0,
              ),
            ),
            SizedBox(height: 8.0),
            Divider(color: Colors.grey),
            SizedBox(height: 8.0),
            Text(
              'Payment:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.0,
              ),
            ),
            SizedBox(height: 4.0),
            Text(
              historyEntry.paymentMethod,
              style: TextStyle(
                fontSize: 14.0,
              ),
            ),
            SizedBox(height: 8.0),
            Divider(color: Colors.grey),
            SizedBox(height: 8.0),
            Text(
              'Fee Charge:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.0,
              ),
            ),
            SizedBox(height: 4.0),
            Text(
              historyEntry.feeCharge,
              style: TextStyle(
                fontSize: 14.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ServiceStatistics extends StatelessWidget {
  final Map<String, int> serviceCount;

  ServiceStatistics({required this.serviceCount});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: serviceCount.entries.map((entry) {
        return ListTile(
          title: Text(
            entry.key,
            style: TextStyle(fontSize: 16.0),
          ),
          subtitle: Text(
            'Customers: ${entry.value}',
            style: TextStyle(fontSize: 16.0),
          ),
        );
      }).toList(),
    );
  }
}

class IncomeStatistics extends StatelessWidget {
  final Map<String, double> incomeByType;

  IncomeStatistics({required this.incomeByType});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: incomeByType.entries.map((entry) {
        return ListTile(
          title: Text(
            entry.key,
            style: TextStyle(fontSize: 16.0),
          ),
          subtitle: Text(
            'Income: ${entry.value.toStringAsFixed(2)} RM',
            style: TextStyle(fontSize: 16.0),
          ),
        );
      }).toList(),
    );
  }
}

class StatisticsDetailsPage extends StatelessWidget {
  final List<HistoryEntry> entries;
  final String timeFrame;

  StatisticsDetailsPage({required this.entries, required this.timeFrame});

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.black,
      title: Text('Statistics - $timeFrame'),
    ),
    backgroundColor: Colors.white70,
    body: SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 16.0),
          Text(
            'Most Demanded Services :',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8.0),
          ServiceStatistics(serviceCount: calculateServiceCounts()),
          SizedBox(height: 16.0),
          Text(
            'Income Statistics :',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8.0),
          IncomeStatistics(incomeByType: calculateIncomeByType()),
          SizedBox(height: 16.0),
          Text(
            'Total Income : ${calculateTotalIncome().toStringAsFixed(2)} RM',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 16.0),
        ],
      ),
    ),
  );
}


  Map<String, int> calculateServiceCounts() {
    final serviceCount = Map<String, int>();
    for (var entry in entries) {
      if (serviceCount.containsKey(entry.serviceType)) {
        serviceCount[entry.serviceType] = serviceCount[entry.serviceType]! + 1;
      } else {
        serviceCount[entry.serviceType] = 1;
      }
    }
    return serviceCount;
  }

  Map<String, double> calculateIncomeByType() {
    final incomeByType = Map<String, double>();
    for (var entry in entries) {
      if (incomeByType.containsKey(entry.serviceType)) {
        double feeCharge =
            double.tryParse(entry.feeCharge.split(" ")[0]) ?? 0.0;
        incomeByType[entry.serviceType] =
            incomeByType[entry.serviceType]! + feeCharge;
      } else {
        double feeCharge =
            double.tryParse(entry.feeCharge.split(" ")[0]) ?? 0.0;
        incomeByType[entry.serviceType] = feeCharge;
      }
    }
    return incomeByType;
  }

  double calculateTotalIncome() {
    double totalIncome = 0;
    for (var entry in entries) {
      double feeCharge = double.tryParse(entry.feeCharge.split(" ")[0]) ?? 0.0;
      totalIncome += feeCharge;
    }
    return totalIncome;
  }
}
