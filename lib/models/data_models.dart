class User {
  final int? id;
  final String? userName;
  final String? userEmail;
  final String? userPassword;
  final String? userPhoneno;
  final String? userAddress;

  User({
    this.id,
    this.userName,
    this.userEmail,
    this.userPassword,
    this.userPhoneno,
    this.userAddress,
  });

  factory User.fromJson(Map<String, dynamic> jsonData) {
    return User(
      id: jsonData['id'],
      userName: jsonData['username'],
      userEmail: jsonData['email'],
      userPassword: jsonData['password'],
      userPhoneno: jsonData['phone_no'],
      userAddress: jsonData['address'],
    );
  }
}

class ServiceModel {
  final String name;
  final String description;
  final double price;
  final int duration;

  ServiceModel({
    required this.name,
    required this.description,
    required this.price,
    required this.duration,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      name: json['name'],
      description: json['description'],
      price: double.parse(json['price'].toString()),
      duration: int.parse(json['duration'].toString()),
    );
  }
}

class Bookings {
  final String id;
  final String serviceId;
  final String userId;
  final String username;
  final String phoneNo;
  final String dateOfBooking;
  final String timeOfBooking;
  final String status;
  final String serviceName;
  final String price; // Add this
  final String providerId;
  final String providerName;

  Bookings({
    required this.id,
    required this.serviceId,
    required this.userId,
    required this.username,
    required this.phoneNo,
    required this.dateOfBooking,
    required this.timeOfBooking,
    required this.status,
    required this.serviceName,
    required this.price, // Add this
    required this.providerId,
    required this.providerName,
  });

  factory Bookings.fromJson(Map<String, dynamic> json) {
    return Bookings(
      id: json['id'].toString(),
      serviceId: json['service_id'].toString(),
      userId: json['user_id'].toString(),
      username: json['username'] ?? '',
      phoneNo: json['phone_no'] ?? '',
      dateOfBooking: json['booking_date'] ?? '',
      timeOfBooking: json['booking_time'] ?? '',
      status: json['status'] ?? '',
      serviceName: json['service_name'] ?? '',
      price: json['price'].toString(), // Add this
      providerId: json['provider_id'].toString(),
      providerName: json['provider_name'] ?? '',
    );
  }
}
