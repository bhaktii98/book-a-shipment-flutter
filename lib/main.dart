import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'shipping_rate.dart'; // Ensure this file exists

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Book a Shipment',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: Colors.purple.shade50,
      ),
      home: const BookShipmentScreen(),
    );
  }
}

class BookShipmentScreen extends StatefulWidget {
  const BookShipmentScreen({super.key});

  @override
  State<BookShipmentScreen> createState() => _BookShipmentScreenState();
}

class _BookShipmentScreenState extends State<BookShipmentScreen> with SingleTickerProviderStateMixin {
  final _pickupController = TextEditingController();
  String? _selectedPickup;
  final _deliveryController = TextEditingController();
  String? _selectedDelivery;
  String? _selectedCourier;
  double _price = 0.0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // List of cities extracted from the JSON data
  final List<String> _cities = [
    'Delhi',
    'Mumbai',
    'Bangalore',
    'Chennai',
    'Kolkata',
    'Hyderabad',
    'Ahmedabad',
    'Pune',
    'Jaipur',
    'Lucknow'
  ];

  // List of couriers extracted from the JSON data
  final List<String> _couriers = [
    'Delhivery',
    'DTDC',
    'Bluedart',
    'Ecom Express',
    'India Post'
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pickupController.dispose();
    _deliveryController.dispose();
    super.dispose();
  }

  Future<void> _calculatePrice() async {
    final pickup = _pickupController.text.isNotEmpty ? _pickupController.text : _selectedPickup;
    final delivery = _deliveryController.text.isNotEmpty ? _deliveryController.text : _selectedDelivery;
    final courier = _selectedCourier;

    if (pickup == null || delivery == null || courier == null) {
      setState(() => _price = 0.0);
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('https://67db028c1fd9e43fe4733fb8.mockapi.io/api/v1/shipping_rates'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final rate = data.firstWhere(
          (item) =>
              item['pickup'] == pickup &&
              item['delivery'] == delivery &&
              item['courier'] == courier,
          orElse: () => {'price': 100.0}, // Fallback price
        );
        setState(() => _price = rate['price'].toDouble());
      } else {
        setState(() => _price = 100.0);
      }
    } catch (e) {
      setState(() => _price = 100.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.purple.shade50, Colors.purple.shade100],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Text(
                          'Book Your Shipment',
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Seamless Delivery, Every Time.',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Form Card
                        Card(
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                _buildHybridField(
                                  controller: _pickupController,
                                  selectedValue: _selectedPickup,
                                  hint: 'Pickup City',
                                  items: _cities,
                                  icon: Icons.location_on,
                                  onSelected: (value) {
                                    setState(() {
                                      _selectedPickup = value;
                                      _pickupController.text = value;
                                      _calculatePrice();
                                    });
                                  },
                                  onChanged: (_) {
                                    setState(() {
                                      _selectedPickup = null;
                                      _calculatePrice();
                                    });
                                  },
                                ),
                                const SizedBox(height: 20),
                                _buildHybridField(
                                  controller: _deliveryController,
                                  selectedValue: _selectedDelivery,
                                  hint: 'Delivery City',
                                  items: _cities,
                                  icon: Icons.local_shipping,
                                  onSelected: (value) {
                                    setState(() {
                                      _selectedDelivery = value;
                                      _deliveryController.text = value;
                                      _calculatePrice();
                                    });
                                  },
                                  onChanged: (_) {
                                    setState(() {
                                      _selectedDelivery = null;
                                      _calculatePrice();
                                    });
                                  },
                                ),
                                const SizedBox(height: 20),
                                _buildCourierDropdown(),
                                const SizedBox(height: 24),
                                _buildPriceDisplay(),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Slide to Payment Button
                        Center(
                          child: SlideToActionButton(
                            onSlideComplete: _handlePayment,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHybridField({
    required TextEditingController controller,
    required String? selectedValue,
    required String hint,
    required List<String> items,
    required IconData icon,
    required ValueChanged<String> onSelected,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Autocomplete<String>(
        optionsBuilder: (TextEditingValue textEditingValue) {
          if (textEditingValue.text.isEmpty) {
            return const Iterable<String>.empty();
          }
          return items.where((String option) {
            return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
          });
        },
        onSelected: (String selection) {
          controller.text = selection;
          onSelected(selection);
        },
        fieldViewBuilder: (BuildContext context, TextEditingController fieldController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
          fieldController.text = controller.text; // Sync the controller
          return TextField(
            controller: fieldController,
            focusNode: focusNode,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade600),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              prefixIcon: Icon(icon, color: Colors.purple.shade600),
              suffixIcon: PopupMenuButton<String>(
                icon: Icon(Icons.arrow_drop_down, color: Colors.purple.shade600),
                onSelected: (String value) {
                  controller.text = value;
                  onSelected(value);
                },
                itemBuilder: (BuildContext context) {
                  return items.map((String city) {
                    return PopupMenuItem<String>(
                      value: city,
                      child: Text(city),
                    );
                  }).toList();
                },
              ),
            ),
            onChanged: (value) {
              controller.text = value;
              onChanged(value);
            },
          );
        },
      ),
    );
  }

  Widget _buildCourierDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedCourier,
        hint: Text('Select Courier', style: TextStyle(color: Colors.grey.shade600)),
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(Icons.directions_car, color: Colors.purple.shade600),
          suffixIcon: Icon(Icons.arrow_drop_down, color: Colors.purple.shade600),
        ),
        items: _couriers.map((courier) {
          return DropdownMenuItem(
            value: courier,
            child: Text(courier, style: const TextStyle(fontSize: 16)),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedCourier = value;
            _calculatePrice();
          });
        },
      ),
    );
  }

  Widget _buildPriceDisplay() {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.currency_rupee, color: Colors.green, size: 24),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'Price: ${_price.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handlePayment() {
    final pickup = _pickupController.text.isNotEmpty ? _pickupController.text : _selectedPickup;
    final delivery = _deliveryController.text.isNotEmpty ? _deliveryController.text : _selectedDelivery;
    final courier = _selectedCourier;

    if (pickup != null && delivery != null && courier != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConfirmationScreen(
            pickup: pickup,
            delivery: delivery,
            courier: courier,
            price: _price,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select all fields'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            left: 16,
            right: 16,
          ),
        ),
      );
    }
  }
}

// Custom Slide to Action Button Widget
class SlideToActionButton extends StatefulWidget {
  final VoidCallback onSlideComplete;

  const SlideToActionButton({super.key, required this.onSlideComplete});

  @override
  _SlideToActionButtonState createState() => _SlideToActionButtonState();
}

class _SlideToActionButtonState extends State<SlideToActionButton> {
  double _dragPosition = 0.0;
  final double _maxDrag = 200.0; // Width of the draggable area

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background text
          const Text(
            'Slide to Payment',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          // Draggable slider
          Positioned(
            left: _dragPosition,
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                setState(() {
                  _dragPosition += details.delta.dx;
                  // Constrain the drag position
                  if (_dragPosition < 0) _dragPosition = 0;
                  if (_dragPosition > _maxDrag) _dragPosition = _maxDrag;
                });
              },
              onHorizontalDragEnd: (details) {
                // If dragged to the end, trigger the action
                if (_dragPosition >= _maxDrag) {
                  widget.onSlideComplete();
                }
                // Reset position
                setState(() {
                  _dragPosition = 0.0;
                });
              },
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.arrow_forward,
                  color: Colors.black87,
                  size: 30,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ConfirmationScreen extends StatelessWidget {
  final String pickup;
  final String delivery;
  final String courier;
  final double price;

  const ConfirmationScreen({
    super.key,
    required this.pickup,
    required this.delivery,
    required this.courier,
    required this.price,
  });

  // List of positive quotes
  static const List<String> quotes = [
    "Your journey begins with a single step – your shipment is on its way!",
    "Great things are coming your way, just like this delivery!",
    "A package delivered is a promise kept. We’ve got you covered!",
    "Happiness is on its way – your shipment has been placed!",
    "Every delivery brings a new opportunity. Enjoy the ride!"
  ];

  String getRandomQuote() {
    final random = Random();
    return quotes[random.nextInt(quotes.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.purple.shade50, Colors.purple.shade100],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Success Icon
                Icon(
                  Icons.check_circle,
                  size: 100,
                  color: Colors.purple.shade800,
                ),
                const SizedBox(height: 20),
                // Confirmation Message
                Text(
                  'Your Delivery is Placed!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    shadows: [
                      Shadow(
                        color: Colors.black12,
                        offset: Offset(2, 2),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                // Delivery Details
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Delivery Details',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'From: $pickup',
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          'To: $delivery',
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          'Courier: $courier',
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          'Price: ₹${price.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                // Positive Quote
                Text(
                  getRandomQuote(),
                  style: TextStyle(
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                // Back Button
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 8,
                  ),
                  child: const Text(
                    'Back to Home',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}