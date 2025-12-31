import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ticket_model.dart';
import '../models/customer_model.dart';

class ApiService {
  // ===========================================================================
  // ÖNEMLİ AYAR: IP VE PORT ADRESİ
  // ===========================================================================
  // 1. Eğer Android Emülatör kullanıyorsanız şu satırı açın:

  // 2. Eğer Gerçek Telefon (USB/Wi-Fi) kullanıyorsanız üstteki satırı yorum yapıp
  // bilgisayarınızın IP'sini (örn: 192.168.1.35) aşağıya yazın:
  // static const String _ip = "192.168.1.35";

  // Backend'inizin standart portu 5246'dır. Bunu değiştirmeyin.
  final String baseUrl = "http://10.0.2.2:5158/api";

  // ===========================================================================
  // 1. KİMLİK DOĞRULAMA (LOGIN)
  // ===========================================================================
  Future<bool> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/Auth/Login');
    print("Bağlanılıyor: $url"); // Hata ayıklama için log

    try {
      final response = await http
          .post(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"username": username, "password": password}),
          )
          .timeout(const Duration(seconds: 15)); // 15 saniye bekleme süresi

      print("Sunucu Cevabı Kodu: ${response.statusCode}");

      // Login fonksiyonunun içindeki "if (response.statusCode == 200)" bloğunu güncelleyin:

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString('token', data['token'] ?? "");
        await prefs.setString('username', username);

        // --- YENİ EKLENENLER ---
        if (data['branchId'] != null) {
          await prefs.setString('branchId', data['branchId'].toString());
        }
        // Şube adını kaydet
        if (data['branchName'] != null) {
          await prefs.setString('branchName', data['branchName'].toString());
        }
        // -----------------------

        if (data['userId'] != null) {
          await prefs.setString('userId', data['userId'].toString());
        }

        return true;
      } else {
        print("Giriş Başarısız: ${response.body}");
        return false;
      }
    } catch (e) {
      print("KRİTİK BAĞLANTI HATASI: $e");
      return false;
    }
  }

  // ===========================================================================
  // Müşteri Listesi (GÜNCELLENDİ)
  Future<List<dynamic>> getCustomers() async {
    // Önce telefondaki kayıtlı şube ID'yi al
    final prefs = await SharedPreferences.getInstance();
    String? branchId = prefs.getString('branchId');

    // URL'ye parametre olarak ekle
    final url = Uri.parse('$baseUrl/Customer/GetAll?branchId=$branchId');

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

  // Şirket Listesi (GÜNCELLENDİ)
  Future<List<String>> getCompanies() async {
    // 1. Şube ID'sini telefondan al
    final prefs = await SharedPreferences.getInstance();
    String? branchId = prefs.getString('branchId');

    // 2. URL'ye parametre olarak ekle (?branchId=...)
    final url = Uri.parse('$baseUrl/Customer/GetCompanies?branchId=$branchId');

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
      return false;
    }
  }

  // ===========================================================================
  // 3. SERVİS KAYDI (TICKET)
  // ===========================================================================
  Future<Map<String, dynamic>> getTicketFormData({String? branchId}) async {
    String queryString = branchId != null ? "?branchId=$branchId" : "";
    final url = Uri.parse('$baseUrl/TicketApi/FormData$queryString');
    try {
      final response = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode == 200) return jsonDecode(response.body);
    } catch (e) {
      print("Hata: $e");
    }
    return {};
  }

  Future<String?> addTicket(ServiceTicketDto ticket) async {
    final url = Uri.parse('$baseUrl/TicketApi/Create');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(ticket.toJson()),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['fisNo'] ?? data['FisNo'];
      }
    } catch (e) {
      print("Hata: $e");
    }
    return null;
  }
}
