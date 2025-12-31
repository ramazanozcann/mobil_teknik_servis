import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/customer_model.dart';
import '../services/api_service.dart';
import '../widgets/custom_text_field.dart';

class AddCustomerScreen extends StatefulWidget {
  @override
  _AddCustomerScreenState createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final _formKey = GlobalKey<FormState>();

  // --- Controllerlar ---
  final _adController = TextEditingController();
  final _soyadController = TextEditingController();
  final _telController = TextEditingController();
  final _tel2Controller = TextEditingController();
  final _emailController = TextEditingController();
  final _tcController = TextEditingController();
  final _adresController = TextEditingController();
  final _sehirController = TextEditingController();
  final _ilceController = TextEditingController();

  // Firma ve Vergi Alanları
  final _firmaController = TextEditingController();
  final _vergiDairesiController = TextEditingController();
  final _vergiNoController = TextEditingController();

  // --- Durum Değişkenleri ---
  bool _showCompanyFields = false; // Firma alanları açık mı?
  bool _isLoading = false;

  // Müşteri Tipleri ("Kurumsal" listeden çıkarıldı)
  final List<String> _customerTypes = ["Normal", "Esnaf", "Bayi", "Problemli"];
  String _selectedCustomerType = "Normal";

  // --- Dropdown (Firma Listesi) İçin ---
  final ApiService _apiService = ApiService();
  List<String> _companyList = [];
  String? _selectedCompany;
  bool _isNewCompanySelected = false;

  @override
  void initState() {
    super.initState();
    _loadCompanies();
  }

  // API'den kayıtlı firmaları çek
  void _loadCompanies() async {
    var companies = await _apiService.getCompanies();
    if (mounted) {
      setState(() {
        _companyList = companies;
      });
    }
  }

  // "Firma Bilgisi Ekle" anahtarı değişince
  void _onSwitchChanged(bool val) {
    setState(() {
      _showCompanyFields = val;
    });
  }

  void _saveCustomer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    String branchId = prefs.getString('branchId') ?? "";

    // Firma Adını Belirle:
    // Eğer alanlar açıksa ve (Yeni Ekle seçildiyse veya liste boşsa) -> Textbox'tan al
    // Değilse -> Dropdown'dan seçileni al
    String? finalCompanyName;
    if (_showCompanyFields) {
      if (_isNewCompanySelected || _companyList.isEmpty) {
        finalCompanyName = _firmaController.text;
      } else {
        finalCompanyName = _selectedCompany;
      }
    }

    CustomerDto newCustomer = CustomerDto(
      branchId: branchId,
      firstName: _adController.text,
      lastName: _soyadController.text,
      phone: _telController.text,
      phone2: _tel2Controller.text,
      email: _emailController.text,
      tcNo: _tcController.text,
      address: _adresController.text,
      city: _sehirController.text,
      district: _ilceController.text,

      // KRİTİK NOKTA: Seçilen tipi (Normal, Esnaf vs.) olduğu gibi gönderiyoruz.
      customerType: _selectedCustomerType,

      companyName: finalCompanyName,
      taxOffice: _showCompanyFields ? _vergiDairesiController.text : null,
      taxNumber: _showCompanyFields ? _vergiNoController.text : null,
    );

    bool success = await _apiService.addCustomer(newCustomer);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Müşteri Başarıyla Kaydedildi!"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context); // Önceki ekrana dön
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hata oluştu!"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Yeni Müşteri", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. MÜŞTERİ TİPİ SEÇİMİ ---
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "Müşteri Tipi",
                    prefixIcon: Icon(Icons.category, color: Colors.indigo),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  value: _selectedCustomerType,
                  items: _customerTypes.map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (val) =>
                      setState(() => _selectedCustomerType = val!),
                ),
              ),

              Text(
                "Kişisel Bilgiler",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
              SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _adController,
                      label: "Ad",
                      icon: Icons.person,
                      validator: (v) => v!.isEmpty ? "Zorunlu" : null,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: CustomTextField(
                      controller: _soyadController,
                      label: "Soyad",
                      icon: Icons.person_outline,
                    ),
                  ),
                ],
              ),
              CustomTextField(
                controller: _telController,
                label: "Telefon",
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (v) => v!.isEmpty ? "Zorunlu" : null,
              ),
              CustomTextField(
                controller: _tel2Controller,
                label: "Telefon 2 (Opsiyonel)",
                icon: Icons.phone_android,
                keyboardType: TextInputType.phone,
              ),
              CustomTextField(
                controller: _emailController,
                label: "E-Posta",
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),
              CustomTextField(
                controller: _tcController,
                label: "TC Kimlik No",
                icon: Icons.badge,
                keyboardType: TextInputType.number,
              ),

              SizedBox(height: 10),
              Text(
                "Adres Bilgileri",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
              SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _sehirController,
                      label: "İl",
                      icon: Icons.location_city,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: CustomTextField(
                      controller: _ilceController,
                      label: "İlçe",
                      icon: Icons.map,
                    ),
                  ),
                ],
              ),
              CustomTextField(
                controller: _adresController,
                label: "Açık Adres",
                icon: Icons.home,
                maxLines: 3,
              ),

              SizedBox(height: 10),

              // --- 2. FİRMA BİLGİSİ GİRME ANAHTARI ---
              SwitchListTile(
                title: Text(
                  "Firma Bilgisi Ekle",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text("Firma veya vergi bilgisi girmek için açınız"),
                value: _showCompanyFields,
                activeColor: Colors.indigo,
                onChanged: _onSwitchChanged,
              ),

              // --- 3. FİRMA ALANLARI (Gizle/Göster) ---
              if (_showCompanyFields) ...[
                SizedBox(height: 10),
                Text(
                  "Firma ve Vergi Bilgileri",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
                SizedBox(height: 15),

                // Firma Seçimi (Dropdown + Yeni Ekle Hibrit Yapı)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: "Firma Seçiniz",
                      prefixIcon: Icon(Icons.business, color: Colors.indigo),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    value: _selectedCompany,
                    items: [
                      DropdownMenuItem(
                        value: "YENI_EKLE_OPTION",
                        child: Text(
                          "+ YENİ FİRMA EKLE",
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ..._companyList.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                    ],
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCompany = newValue;
                        if (newValue == "YENI_EKLE_OPTION") {
                          _isNewCompanySelected = true;
                          _firmaController.clear();
                        } else {
                          _isNewCompanySelected = false;
                          _firmaController.text = newValue ?? "";
                        }
                      });
                    },
                  ),
                ),

                // Eğer "Yeni Ekle" seçildiyse Text Kutusunu Göster
                if (_isNewCompanySelected || _companyList.isEmpty)
                  CustomTextField(
                    controller: _firmaController,
                    label: "Yeni Firma Adı Giriniz",
                    icon: Icons.add_business,
                    validator: (v) =>
                        _showCompanyFields &&
                            (_isNewCompanySelected || _companyList.isEmpty) &&
                            (v == null || v.isEmpty)
                        ? "Firma adı zorunlu"
                        : null,
                  ),

                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _vergiDairesiController,
                        label: "Vergi Dairesi",
                        icon: Icons.account_balance,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: CustomTextField(
                        controller: _vergiNoController,
                        label: "Vergi No",
                        icon: Icons.numbers,
                      ),
                    ),
                  ],
                ),
              ],

              SizedBox(height: 20),

              // --- KAYDET BUTONU ---
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveCustomer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text("Kaydet", style: TextStyle(fontSize: 16)),
                ),
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
