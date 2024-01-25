import 'package:awign/packages/flutter_image_editor/model/image_details.dart';
import 'package:awign/workforce/core/data/model/kyc_details.dart';

class DocumentVerificationData {
  KYCType kycType;
  ImageDetails imageDetails;

  DocumentVerificationData({required this.kycType, required this.imageDetails});
}
