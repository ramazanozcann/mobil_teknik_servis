class ServiceTicketDto {
  final String customerId;
  final String deviceTypeId; // ID
  final String deviceBrandId; // ID
  final String? technicianId; // ID (Null olabilir)

  final String deviceModel;
  final String serialNo;
  final String problem;
  final String accessories;
  final String physicalDamage;
  final bool isWarranty;

  ServiceTicketDto({
    required this.customerId,
    required this.deviceTypeId,
    required this.deviceBrandId,
    this.technicianId,
    required this.deviceModel,
    required this.serialNo,
    required this.problem,
    required this.accessories,
    required this.physicalDamage,
    required this.isWarranty,
  });

  Map<String, dynamic> toJson() {
    return {
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
