class CustomerDto {
  final String branchId;
  final String firstName;
  final String lastName;
  final String phone;
  final String? phone2; // Yeni
  final String? email;
  final String? address; // Yeni
  final String? city; // Yeni
  final String? district; // Yeni
  final String? tcNo; // Yeni
  final String? companyName; // Yeni
  final String customerType; // Yeni (Normal, Kurumsal)
  final String? taxOffice; // Yeni
  final String? taxNumber; // Yeni

  CustomerDto({
    required this.branchId,
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.phone2,
    this.email,
    this.address,
    this.city,
    this.district,
    this.tcNo,
    this.companyName,
    this.customerType = "Normal",
    this.taxOffice,
    this.taxNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'branchId': branchId,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'phone2': phone2,
      'email': email,
      'address': address,
      'city': city,
      'district': district,
      'tcNo': tcNo,
      'companyName': companyName,
      'customerType': customerType,
      'taxOffice': taxOffice,
      'taxNumber': taxNumber,
    };
  }
}
