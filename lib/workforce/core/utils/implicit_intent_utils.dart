import 'dart:io';

import 'package:awign/workforce/core/utils/helper.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class ImplicitIntentUtils {
  Future<void> fireCallIntent(String phoneNumber) async {
    FlutterPhoneDirectCaller.callNumber(phoneNumber);
  }

  Future<void> fireLocationIntent(List<String> latlng) async {
    String url = '';
    String urlAppleMaps = '';
    if (Platform.isAndroid) {
      url = 'https://www.google.com/maps/search/?api=1&query=${latlng[0]},${latlng[1]}';
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        Helper.showInfoToast('location_not_found'.tr);
      }
    } else {
      urlAppleMaps = 'https://maps.apple.com/?q=${latlng[0]},${latlng[1]}';
      url = 'comgooglemaps://?saddr=&daddr=${latlng[0]},${latlng[1]}&directionsmode=driving';
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else if (await canLaunchUrl(Uri.parse(urlAppleMaps))) {
        await launchUrl(Uri.parse(urlAppleMaps));
      } else {
        Helper.showInfoToast('location_not_found'.tr);
      }
    }
  }

  Future<void> fireEmailIntent(
      List<String> emails, String subject, String text) async {
    var mailUri =
        Uri.parse('mailto:${emails[0].toString()}?subject=Awign-Email');
    if (await canLaunchUrl(mailUri)) {
      await launchUrl(mailUri, mode: LaunchMode.externalApplication);
    } else {
      Helper.showInfoToast('email_not_found'.tr);
    }
  }

  Future<void> fireWhatsAppIntent(String whatsAppNumber) async {
    var whatsappUri = Uri.parse("whatsapp://send?phone=$whatsAppNumber");
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } else {
      Helper.showInfoToast('whatsapp_not_found'.tr);
    }
  }
}
