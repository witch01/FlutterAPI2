class FinanceRecord {
  int? id;
  int? transactionNumber;
  String? transactionName;
  String? description;
  String? category;
  DateTime? transactionDate;
  double? transactionAmount;
  bool is_deleted = false;

  FinanceRecord({
    this.id,
    this.transactionNumber,
    this.transactionName,
    this.description,
    this.category,
    this.transactionDate,
    this.transactionAmount,
    this.is_deleted = false,
  });

  factory FinanceRecord.fromJson(Map<String, dynamic> json) => FinanceRecord(
        id: json['id'],
        transactionNumber: json['transactionNumber'],
        transactionName: json['transactionName'],
        description: json['description'],
        category: json['category'],
        transactionDate: DateTime.parse(json['transactionDate']),
        transactionAmount: json['transactionAmount'].toDouble(),
        is_deleted: json['is_deleted'] ?? false,
      );
}
