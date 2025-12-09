import 'package:flutter/material.dart';

class NoInternetPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off, size: 80, color: Colors.red),
            SizedBox(height: 16),
            Text("No Internet Connection", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text("Please check your network settings", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
