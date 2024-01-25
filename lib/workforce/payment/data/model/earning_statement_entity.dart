class WithdrawalStatementResponse {
  List<WithdrawalStatement>? withdrawalStatements;

  WithdrawalStatementResponse({this.withdrawalStatements});

  WithdrawalStatementResponse.fromJson(Map<String, dynamic> json) {
    if (json['withdrawal_statements'] != null) {
      withdrawalStatements = <WithdrawalStatement>[];
      json['withdrawal_statements'].forEach((v) {
        withdrawalStatements!.add(WithdrawalStatement.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (withdrawalStatements != null) {
      data['withdrawal_statements'] =
          withdrawalStatements!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class WithdrawalStatement {
  int? userid;
  String? documentUrl;
  String? status;
  String? month;

  WithdrawalStatement({this.userid, this.documentUrl, this.status, this.month});

  WithdrawalStatement.fromJson(Map<String, dynamic> json) {
    userid = json['userid'];
    documentUrl = json['documentUrl'];
    status = json['status'];
    month = json['month'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userid'] = userid;
    data['documentUrl'] = documentUrl;
    data['status'] = status;
    data['month'] = month;
    return data;
  }
}
