import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Book a Shipment',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const BookShipmentScreen(),
    );
  }
}

class BookShipmentScreen extends StatefulWidget {
  const BookShipmentScreen({super.key});

  @override
  State<BookShipmentScreen> createState() => _BookShipmentScreenState();
}

class _BookShipmentScreenState extends State<BookShipmentScreen> {
  final _pickupController = TextEditingController();
  final _deliveryController = TextEditingController();
  String? _selectedCourier;
  double _price = 0.0;

  final List<String> _couriers = ['Delhivery', 'DTDC', 'Bluedart'];

  void _calculatePrice() {
    // Dummy price calculation for now (updated with API in Task 2)
    setState(() {
      _price = 100.0; // Placeholder value
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book a Shipment')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _pickupController,
              decoration: const InputDecoration(labelText: 'Pickup Address'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _deliveryController,
              decoration: const InputDecoration(labelText: 'Delivery Address'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCourier,
              hint: const Text('Select Courier'),
              items: _couriers.map((courier) {
                return DropdownMenuItem(value: courier, child: Text(courier));
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedCourier = value);
                _calculatePrice();
              },
            ),
            const SizedBox(height: 16),
            Text('Estimated Price: ₹$_price'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_pickupController.text.isNotEmpty &&
                    _deliveryController.text.isNotEmpty &&
                    _selectedCourier != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Payment Initiated!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                }
              },
              child: const Text('Proceed to Payment'),
            ),
          ],
        ),
      ),
    );
  }
}