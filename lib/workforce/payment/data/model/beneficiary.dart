import 'package:awign/workforce/core/data/model/enum.dart';

class BeneficiaryRequestParam {
  int? userId;
  String? paymentMode;
  BeneficiaryVerificationStatus? status;

  BeneficiaryRequestParam(
      {required this.userId, this.paymentMode, this.status});
}

class BeneficiaryVerificationStatus<String> extends Enum1<String> {
  const BeneficiaryVerificationStatus(String val) : super(val);

  static const BeneficiaryVerificationStatus verified =
      BeneficiaryVerificationStatus('verified');
  static const BeneficiaryVerificationStatus unverified =
      BeneficiaryVerificationStatus('unverified');
  static const BeneficiaryVerificationStatus rejected =
      BeneficiaryVerificationStatus('rejected');
  static const BeneficiaryVerificationStatus panVerificationRejected =
      BeneficiaryVerificationStatus('pan_verification_rejected');
}

class BeneficiaryType<String> extends Enum1<String> {
  const BeneficiaryType(String val) : super(val);

  static const BeneficiaryType upi = BeneficiaryType('upi');
  static const BeneficiaryType paytm = BeneficiaryType('paytm');
  static const BeneficiaryType payeeBank = BeneficiaryType('banktransfer');
}

class BeneficiaryResponse {
  List<Beneficiary>? beneficiaries;

  BeneficiaryResponse({this.beneficiaries});

  BeneficiaryResponse.fromJson(Map<String, dynamic> json) {
    if (json['beneficiaries'] != null) {
      beneficiaries = <Beneficiary>[];
      json['beneficiaries'].forEach((v) {
        beneficiaries!.add(Beneficiary.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (beneficiaries != null) {
      data['beneficiaries'] = beneficiaries!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Beneficiary {
  int? beneId;
  String? paymentChannelBeneficiaryId;
  int? paymentChannelId;
  String? name;
  String? email;
  String? phone;
  String? panCardNumber;
  String? paytmNumber;
  String? vpa;
  String? bankAccount;
  String? bankName;
  String? ifsc;
  String? address1;
  String? city;
  String? state;
  String? pincode;
  String? userId;
  String? paymentMode;
  String? verificationStatus;
  late bool active;
  bool? defaultBankAccount;
  String? validationStatus;
  String? verificationResponse;
  bool? deleted;
  String? createdAt;
  String? updatedAt;
  late bool isSelected;
  bool? verifyBeneficiary;
  late bool isVerifyLoading;

  Beneficiary({
    this.beneId,
    this.paymentChannelBeneficiaryId,
    this.paymentChannelId,
    this.name,
    this.email,
    this.phone,
    this.panCardNumber,
    this.paytmNumber,
    this.vpa,
    this.bankAccount,
    this.bankName,
    this.ifsc,
    this.address1,
    this.city,
    this.state,
    this.pincode,
    this.userId,
    this.paymentMode,
    this.verificationStatus,
    this.active = false,
    this.defaultBankAccount,
    this.validationStatus,
    this.verificationResponse,
    this.deleted,
    this.createdAt,
    this.updatedAt,
    this.isSelected = false,
    this.verifyBeneficiary,
    this.isVerifyLoading = false,
  });

  Beneficiary.fromJson(Map<String, dynamic> json) {
    beneId = json['id'];
    paymentChannelBeneficiaryId = json['payment_channel_beneficiary_id'];
    paymentChannelId = json['paymentChannelId'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    panCardNumber = json['panCardNumber'];
    paytmNumber = json['paytmNumber'];
    vpa = json['vpa'];
    bankAccount = json['bank_account'];
    bankName = json['bank_name'];
    ifsc = json['ifsc'];
    address1 = json['address1'];
    city = json['city'];
    state = json['state'];
    pincode = json['pincode'];
    userId = json['user_id'];
    paymentMode = json['payment_mode'];
    verificationStatus = json['verification_status'];
    active = json['active'] ?? false;
    defaultBankAccount = json['defaultBankAccount'];
    validationStatus = json['validationStatus'];
    verificationResponse = json['verificationResponse'];
    deleted = json['deleted'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    isSelected = false;
    isVerifyLoading = false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = beneId;
    data['payment_channel_beneficiary_id'] = paymentChannelBeneficiaryId;
    data['payment_channel_id'] = paymentChannelId;
    data['name'] = name;
    data['email'] = email;
    data['phone'] = phone;
    data['panCardNumber'] = panCardNumber;
    data['paytmNumber'] = paytmNumber;
    data['vpa'] = vpa;
    data['bank_account'] = bankAccount;
    data['bank_name'] = bankName;
    data['ifsc'] = ifsc;
    data['address1'] = address1;
    data['address'] = address1;
    data['city'] = city;
    data['state'] = state;
    data['pincode'] = pincode;
    data['user_id'] = userId;
    data['payment_mode'] = paymentMode;
    data['verification_status'] = verificationStatus;
    data['active'] = active;
    data['defaultBankAccount'] = defaultBankAccount;
    data['validationStatus'] = validationStatus;
    data['verificationResponse'] = verificationResponse;
    data['deleted'] = deleted;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['verify_beneficiary'] = verifyBeneficiary;
    data['verify_beneficiary_with_pan'] = true;
    return data;
  }
}

class AddBeneficiaryResponse {
  late Beneficiary? beneficiary;
  late String message;

  AddBeneficiaryResponse.fromJson(Map<String, dynamic> json) {
    beneficiary = json['beneficiary'] != null
        ? Beneficiary.fromJson(json['beneficiary'])
        : null;
    message = json['message'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['beneficiary'] = beneficiary;
    return data;
  }
}
