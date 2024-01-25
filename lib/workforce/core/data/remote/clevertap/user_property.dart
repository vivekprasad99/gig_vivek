import 'package:awign/workforce/auth/data/model/device_info.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/data/remote/clevertap/clevertap_constant.dart';
import 'package:awign/workforce/core/utils/device_info_utils.dart';

class UserProperty {
  static Future<Map<String, dynamic>> getUserProperty(
      UserData? userData) async {
    Map<String, dynamic> userProperty = {};
    userProperty[CleverTapConstant.userName] = userData?.name ?? '';
    userProperty[CleverTapConstant.userEmail] = userData?.email ?? '';
    userProperty[CleverTapConstant.userPhone] = userData?.mobileNumber ?? '';
    userProperty[CleverTapConstant.userGender] =
        userData?.userProfile?.gender?.name() ?? '';
    userProperty[CleverTapConstant.userDOB] = userData?.userProfile?.dob ?? '';
    if (userData?.userProfile?.addresses != null &&
        userData!.userProfile!.addresses!.isNotEmpty) {
      userProperty[CleverTapConstant.userState] =
          userData.userProfile!.addresses![0].state ?? '';
      userProperty[CleverTapConstant.userCity] =
          userData.userProfile!.addresses![0].city ?? '';
      userProperty[CleverTapConstant.userPincode] =
          userData.userProfile!.addresses![0].pincode ?? '';
    }
    if (userData?.userProfile?.education != null) {
      userProperty[CleverTapConstant.userCollege] =
          userData?.userProfile!.education?.collegeName ?? '';
    }
    DeviceInfo? deviceInfo = await DeviceInfoUtils.getDeviceInfoData();
    userProperty[CleverTapConstant.appVersion] =
        deviceInfo?.versionRelease ?? '';
    userProperty[CleverTapConstant.id] = userData?.id ?? '';
    userProperty[CleverTapConstant.language] =
        userData?.userProfile?.languages?.toString() ?? [];
    userProperty[CleverTapConstant.educationLevel] =
        userData?.userProfile?.professionalExperiences?.toString() ?? [];
    userProperty[CleverTapConstant.professionalExperience] =
        userData?.userProfile?.educationLevel ?? '';
    userProperty[CleverTapConstant.panStatus] =
        userData?.userProfile?.kycDetails?.panVerificationStatus?.value ?? '';
    return userProperty;
  }
}
