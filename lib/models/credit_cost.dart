/// Represents CreditCost configuration from /api/credit-costs (Workflow AI deduct 50 credits)
class CreditCost {
  final String id;
  final String featureKey;
  final int cost;
  final String featureNameVi;
  final String featureNameEn;
  final bool isActive;
  final String? createdAt;

  const CreditCost({
    required this.id,
    required this.featureKey,
    required this.cost,
    required this.featureNameVi,
    required this.featureNameEn,
    this.isActive = true,
    this.createdAt,
  });

  factory CreditCost.fromJson(Map<String, dynamic> json) {
    return CreditCost(
      id: json['id']?.toString() ?? '',
      featureKey: json['featureKey']?.toString() ?? '',
      cost: (json['cost'] as num?)?.toInt() ?? 50,
      featureNameVi: json['featureNameVi']?.toString() ?? 'Tạo nhân vật AI',
      featureNameEn: json['featureNameEn']?.toString() ?? 'AI Character Generation',
      isActive: json['isActive'] == true,
      createdAt: json['createdAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'featureKey': featureKey,
      'cost': cost,
      'featureNameVi': featureNameVi,
      'featureNameEn': featureNameEn,
      'isActive': isActive,
      if (createdAt != null) 'createdAt': createdAt,
    };
  }
}
