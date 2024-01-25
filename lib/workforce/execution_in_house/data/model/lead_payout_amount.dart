class LeadPayoutAmount {
  late num totalAmount;

  LeadPayoutAmount(this.totalAmount);

  LeadPayoutAmount.fromJson(Map<String, dynamic> json) {
    if (json['_total_amount'] is int) {
      totalAmount = double.parse(json['_total_amount'].toString());
    } else {
      totalAmount = json['_total_amount'] ?? 0;
    }
    if (totalAmount == 0) {
      totalAmount = 0;
    }
  }
}
