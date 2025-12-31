class LoginResponse {
  final String userId;
  final String username;
  final String fullName;
  final String branchId;

  LoginResponse({
    required this.userId,
    required this.username,
    required this.fullName,
    required this.branchId,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      userId: json['userId'] ?? "",
      username: json['username'] ?? "",
      fullName: json['fullName'] ?? "",
      branchId: json['branchId'] ?? "",
    );
  }
}
