class ServiceTicketDto {
  final String branchId; // <-- YENİ EKLENDİ
  final String customerId;
  final String deviceTypeId;
  final String deviceBrandId;
  final String? technicianId;
  final String? deviceModel;
  final String? serialNo;
  final String? problem;
  final String? accessories;
  final String? physicalDamage;
  final bool isWarranty;

  ServiceTicketDto({
    required this.branchId, // <-- Constructor'a eklendi
    required this.customerId,
    required this.deviceTypeId,
    required this.deviceBrandId,
    this.technicianId,
    this.deviceModel,
    this.serialNo,
    this.problem,
    this.accessories,
    this.physicalDamage,
    required this.isWarranty,
  });

  Map<String, dynamic> toJson() {
    return {
      'branchId': branchId, // <-- JSON'a eklendi
      'customerId': customerId,
      'deviceTypeId': deviceTypeId,
      'deviceBrandId': deviceBrandId,
      'technicianId': technicianId,
      'deviceModel': deviceModel,
      'serialNo': serialNo,
      'problem': problem,
      'accessories': accessories,
      'physicalDamage': physicalDamage,
      'isWarranty': isWarranty,
    };
  }
}
