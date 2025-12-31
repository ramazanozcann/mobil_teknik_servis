import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ticket_model.dart';
import '../models/customer_model.dart';

class ApiService {
  // Backend Adresi (Android Emülatör: 10.0.2.2, Gerçek Cihaz: Bilgisayar IP'si)
  final String baseUrl = "http://10.0.2.2:5000/api";

  // ===========================================================================
  // 1. KİMLİK DOĞRULAMA (AUTH) - EKSİK OLAN KISIM BURASIYDI
  // ===========================================================================
  Future<bool> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/Auth/Login');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Gelen Token ve Şube Bilgilerini Telefona Kaydet
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token'] ?? "");
        await prefs.setString('username', username);

        // Backend'den BranchId dönüyorsa kaydet (Filtreleme için kritik!)
        if (data['branchId'] != null) {
          await prefs.setString('branchId', data['branchId']);
        }

        return true;
      } else {
        print("Login hatası: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Bağlantı hatası: $e");
      return false;
    }
  }

  // ===========================================================================
  // 2. MÜŞTERİ İŞLEMLERİ
  // ===========================================================================

  // Müşteri Listesi
  Future<List<dynamic>> getCustomers() async {
    final url = Uri.parse('$baseUrl/Customer/GetAll');
    try {
      final response = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print("Müşteri listesi hatası: $e");
    }
    return [];
  }

  // Şirket Listesi
  Future<List<String>> getCompanies() async {
    final url = Uri.parse('$baseUrl/Customer/GetCompanies');
    try {
      final response = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.cast<String>();
      }
    } catch (e) {
      print("Şirket listesi hatası: $e");
    }
    return [];
  }

  // Yeni Müşteri Ekleme
  Future<bool> addCustomer(CustomerDto customer) async {
    final url = Uri.parse('$baseUrl/Customer/Create');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(customer.toJson()),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Müşteri ekleme hatası: $e");
      return false;
    }
  }

  // ===========================================================================
  // 3. SERVİS KAYDI (TICKET) İŞLEMLERİ
  // ===========================================================================

  // Form Verileri (Tür, Marka, Teknisyen) - Şube ID Parametreli
  Future<Map<String, dynamic>> getTicketFormData({String? branchId}) async {
    String queryString = branchId != null ? "?branchId=$branchId" : "";
    final url = Uri.parse('$baseUrl/TicketApi/FormData$queryString');

    try {
      final response = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print("Form datası hatası: $e");
    }
    return {};
  }

  // Servis Kaydı Ekleme
  Future<String?> addTicket(ServiceTicketDto ticket) async {
    final url = Uri.parse('$baseUrl/TicketApi/Create');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(ticket.toJson()),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['fisNo'] ?? responseData['FisNo'];
      } else {
        print("Servis kaydı hatası: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Bağlantı hatası: $e");
      return null;
    }
  }
}
