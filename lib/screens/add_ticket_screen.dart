import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ticket_model.dart';
import '../services/api_service.dart';
import '../widgets/custom_text_field.dart';

class AddTicketScreen extends StatefulWidget {
  @override
  _AddTicketScreenState createState() => _AddTicketScreenState();
}

class _AddTicketScreenState extends State<AddTicketScreen> {
  final _formKey = GlobalKey<FormState>();

  // --- Controllerlar (Metin Alanları) ---
  final _modelController = TextEditingController();
  final _serialController = TextEditingController();
  final _accessoriesController = TextEditingController();
  final _physicalController = TextEditingController();
  final _problemController = TextEditingController();

  // --- Liste ve Seçim Değişkenleri ---
  List<dynamic> _customerList = [];
  String? _selectedCustomerId;

  List<dynamic> _typeList = [];
  List<dynamic> _brandList = [];
  List<dynamic> _techList = [];

  String? _selectedTypeId;
  String? _selectedBrandId;
  String _selectedTechId = "HAVUZ"; // Varsayılan seçim
  String _selectedWarranty = "Yok";

  bool _isLoading = false;
  bool _isDataLoading = true;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  // Verileri Yükle (Kullanıcının şubesine göre)
  void _loadAllData() async {
    final prefs = await SharedPreferences.getInstance();
    String? currentBranchId = prefs.getString('branchId');

    // Konsola basıp kontrol edebilirsiniz
    print("MOBİLDEN GİDEN ŞUBE ID: $currentBranchId");

    var customers = await _apiService.getCustomers();
    var formData = await _apiService.getTicketFormData(
      branchId: currentBranchId,
    );

    if (mounted) {
      setState(() {
        _customerList = customers;

        _typeList = formData['types'] ?? formData['Types'] ?? [];
        _brandList = formData['brands'] ?? formData['Brands'] ?? [];

        // Teknisyen Listesini Hazırla
        List<dynamic> rawTechs =
            formData['technicians'] ?? formData['Technicians'] ?? [];
        _techList = List.from(rawTechs);

        // Listenin başına "Havuz" seçeneğini ekle
        _techList.insert(0, {
          'id': 'HAVUZ',
          'name': '⚠️ Havuzda Bırak (Atama Yapma)',
        });

        _selectedTechId = "HAVUZ";
        _isDataLoading = false;
      });
    }
  }

  // --- GÜNCELLENEN FONKSİYON BURASI ---
  void _saveTicket() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCustomerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Müşteri seçimi zorunludur."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // 1. Telefona kayıtlı BranchId'yi al
    final prefs = await SharedPreferences.getInstance();
    String branchId = prefs.getString('branchId') ?? "";

    // 2. Havuz kontrolü: Eğer HAVUZ seçiliyse null gönder
    String? finalTechId;
    if (_selectedTechId == "HAVUZ") {
      finalTechId = null;
    } else {
      finalTechId = _selectedTechId;
    }

    // 3. Modeli oluştururken branchId'yi veriyoruz
    ServiceTicketDto newTicket = ServiceTicketDto(
      branchId: branchId, // <-- EKLENEN KISIM
      customerId: _selectedCustomerId!,
      deviceTypeId: _selectedTypeId!,
      deviceBrandId: _selectedBrandId!,
      technicianId: finalTechId,

      deviceModel: _modelController.text,
      serialNo: _serialController.text,
      problem: _problemController.text,
      accessories: _accessoriesController.text,
      physicalDamage: _physicalController.text,
      isWarranty: _selectedWarranty == "Var",
    );

    String? createdFisNo = await _apiService.addTicket(newTicket);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (createdFisNo != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 10),
              Text("Başarılı"),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Servis kaydı oluşturuldu."),
              SizedBox(height: 10),
              Text(
                "Fiş No:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              Text(
                createdFisNo,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.indigo,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                finalTechId == null ? "(Havuza düştü)" : "(Teknisyen atandı)",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: Text("Tamam"),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hata oluştu!"), backgroundColor: Colors.red),
      );
    }
  }

  // Dropdown Helper Widget
  Widget _buildDropdown(
    String label,
    List<dynamic> items,
    String? currentValue,
    Function(String?) onChanged, {
    bool isRequired = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        value: currentValue,
        items: items.map<DropdownMenuItem<String>>((dynamic item) {
          return DropdownMenuItem<String>(
            value: item['id'] ?? item['Id'],
            child: Text(
              item['name'] ?? item['Name'] ?? "",
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: onChanged,
        validator: isRequired
            ? (val) => val == null ? "Seçim yapınız" : null
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Yeni Servis Kaydı", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: _isDataLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Müşteri Arama (Autocomplete)
                    Autocomplete<Map<String, dynamic>>(
                      optionsBuilder: (textValue) {
                        final list = _customerList.cast<Map<String, dynamic>>();
                        if (textValue.text == '') return list;
                        return list.where(
                          (opt) => (opt['text'] ?? opt['Text'])
                              .toString()
                              .toLowerCase()
                              .contains(textValue.text.toLowerCase()),
                        );
                      },
                      displayStringForOption: (opt) =>
                          (opt['text'] ?? opt['Text']).toString(),
                      onSelected: (selection) => _selectedCustomerId =
                          selection['id'] ?? selection['Id'],
                      fieldViewBuilder: (ctx, controller, focus, submitted) =>
                          CustomTextField(
                            controller: controller,
                            focusNode: focus,
                            label: "Müşteri Ara",
                            icon: Icons.search,
                          ),
                    ),
                    SizedBox(height: 20),

                    _buildDropdown(
                      "Cihaz Türü",
                      _typeList,
                      _selectedTypeId,
                      (val) => setState(() => _selectedTypeId = val),
                      isRequired: true,
                    ),
                    _buildDropdown(
                      "Marka",
                      _brandList,
                      _selectedBrandId,
                      (val) => setState(() => _selectedBrandId = val),
                      isRequired: true,
                    ),

                    CustomTextField(
                      controller: _modelController,
                      label: "Model",
                      icon: Icons.phone_android,
                    ),

                    // Garanti Durumu
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: "Garanti Durumu",
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        value: _selectedWarranty,
                        items: ["Var", "Yok"]
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                        onChanged: (val) =>
                            setState(() => _selectedWarranty = val!),
                      ),
                    ),

                    CustomTextField(
                      controller: _serialController,
                      label: "Seri No / IMEI",
                      icon: Icons.qr_code,
                    ),
                    CustomTextField(
                      controller: _accessoriesController,
                      label: "Aksesuarlar",
                      icon: Icons.headphones,
                    ),
                    CustomTextField(
                      controller: _physicalController,
                      label: "Fiziksel Durum",
                      icon: Icons.broken_image,
                    ),

                    // Teknisyen Seçimi (Havuz Dahil)
                    _buildDropdown(
                      "Teknisyen Ata",
                      _techList,
                      _selectedTechId,
                      (val) => setState(() => _selectedTechId = val!),
                    ),

                    CustomTextField(
                      controller: _problemController,
                      label: "Arıza Açıklaması",
                      icon: Icons.warning,
                      maxLines: 3,
                      validator: (v) => v!.isEmpty ? "Zorunlu" : null,
                    ),

                    SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveTicket,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                                "Kaydı Oluştur",
                                style: TextStyle(fontSize: 16),
                              ),
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
