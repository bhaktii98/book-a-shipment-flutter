class ShippingRate {
  final String id;
  final String pickup;
  final String delivery;
  final String courier;
  final double price;

  ShippingRate({
    required this.id,
    required this.pickup,
    required this.delivery,
    required this.courier,
    required this.price,
  });

  factory ShippingRate.fromJson(Map<String, dynamic> json) {
    return ShippingRate(
      id: json['id'],
      pickup: json['pickup'],
      delivery: json['delivery'],
      courier: json['courier'],
      price: json['price'].toDouble(),
    );
  }
}