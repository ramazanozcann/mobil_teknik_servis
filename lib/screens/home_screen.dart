import 'package:flutter/material.dart';
import 'add_customer_screen.dart';
import 'add_ticket_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Ana Menü")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: Icon(Icons.person_add),
              label: Text("Yeni Müşteri Ekle"),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddCustomerScreen()),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.build),
              label: Text("Yeni Servis Kaydı"),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddTicketScreen()),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
