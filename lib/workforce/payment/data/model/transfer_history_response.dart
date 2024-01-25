class TransferHistoryResponse {
  List<Transfer>? transfers;
  Transfer? transfer;

  TransferHistoryResponse({this.transfers});

  TransferHistoryResponse.fromJson(Map<String, dynamic> json) {
    if (json['transfers'] != null) {
      transfers = <Transfer>[];
      json['transfers'].forEach((v) {
        transfers!.add(Transfer.fromJson(v));
      });
    }
    if (json['transfer'] != null) {
      transfer = Transfer.fromJson(json['transfer']);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (transfers != null) {
      data['transfers'] = transfers!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class RetryWithdrawalResponse {
  Transfer? transfers;
  String? message;

  RetryWithdrawalResponse({this.transfers, this.message});

  RetryWithdrawalResponse.fromJson(Map<String, dynamic> json, String? msg) {
    if (json['transfer'] != null) {
      transfers = Transfer.fromJson(json['transfer']);
    }
    message = msg;
  }
}

class UpdateBeneficiaryResponse {
  Transfer? transfers;

  UpdateBeneficiaryResponse({this.transfers});

  UpdateBeneficiaryResponse.fromJson(Map<String, dynamic> json, String? msg) {
    if (json['transfer'] != null) {
      transfers = Transfer.fromJson(json['transfer']);
    }
  }
}

class TransferDetailsResponse {
  Transfer? transfer;
  TDSEntry? tdsEntry;

  TransferDetailsResponse({this.transfer, this.tdsEntry});

  TransferDetailsResponse.fromJson(Map<String, dynamic> json) {
    transfer =
        json['transfer'] != null ? Transfer.fromJson(json['transfer']) : null;
    tdsEntry =
        json['tds_entry'] != null ? TDSEntry.fromJson(json['tds_entry']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (transfer != null) {
      data['transfer'] = transfer!.toJson();
    }
    if (tdsEntry != null) {
      data['tds_entry'] = tdsEntry!.toJson();
    }
    return data;
  }
}

class Transfer {
  int? id;
  int? userId;
  int? beneficiaryId;
  String? description;
  double? amount;
  String? utr;
  String? remarks;
  String? createdAt;
  String? updatedAt;
  String? status;
  double? discount;
  String? referenceId;
  String? expectedTransferTime;
  String? statusReasonRemarkExternal;
  String? statusReason;

  Transfer(
      {this.id,
      this.userId,
      this.beneficiaryId,
      this.description,
      this.amount,
      this.utr,
      this.remarks,
      this.createdAt,
      this.updatedAt,
      this.status,
      this.discount,
      this.referenceId,
      this.expectedTransferTime,
      this.statusReasonRemarkExternal,
      this.statusReason
      });

  Transfer.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    beneficiaryId = json['beneficiary_id'];
    description = json['description'];
    if (json['amount'] is int) {
      amount = double.parse(json['amount'].toString());
    } else {
      amount = json['amount'];
    }
    utr = json['utr'];
    remarks = json['remarks'];
    createdAt = json['created_at'];
    status = json['status'].toString().toLowerCase();
    referenceId = json['reference_id'];
    updatedAt = json['updated_at'];
    discount = json['discount'];
    expectedTransferTime = json['expected_transfer_time'];
    statusReasonRemarkExternal = json['status_reason_remark_external'];
    statusReason = json['status_reason'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['beneficiary_id'] = beneficiaryId;
    data['amount'] = amount;
    data['status'] = status;
    data['remarks'] = remarks;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['reference_id'] = referenceId;
    data['discount'] = discount;
    return data;
  }
}

class TDSEntry {
  int? id;
  double? taxableAmount;
  double? tdsPercentage;
  double? tdsAmount;
  String? userId;
  String? createdAt;
  String? updatedAt;

  TDSEntry(
      {this.id,
      this.taxableAmount,
      this.tdsPercentage,
      this.tdsAmount,
      this.userId,
      this.createdAt,
      this.updatedAt});

  TDSEntry.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    if (json['taxable_amount'] is int) {
      taxableAmount = double.parse(json['taxable_amount'].toString());
    } else {
      taxableAmount = json['taxable_amount'];
    }
    if (json['tds_percentage'] is int) {
      tdsPercentage = double.parse(json['tds_percentage'].toString());
    } else {
      tdsPercentage = json['tds_percentage'];
    }
    if (json['tds_amount'] is int) {
      tdsAmount = double.parse(json['tds_amount'].toString());
    } else {
      tdsAmount = json['tds_amount'];
    }
    userId = json['user_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['taxable_amount'] = taxableAmount;
    data['tds_percentage'] = tdsPercentage;
    data['tds_amount'] = tdsAmount;
    data['user_id'] = userId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
