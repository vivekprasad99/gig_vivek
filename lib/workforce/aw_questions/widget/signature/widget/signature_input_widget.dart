import 'dart:io';

import 'package:awign/workforce/aw_questions/data/model/question.dart';
import 'package:awign/workforce/aw_questions/widget/signature/cubit/signature_cubit.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../../core/widget/buttons/my_ink_well.dart';
import '../../../../core/widget/theme/theme_manager.dart';

class SignatureInputWidget extends StatefulWidget {
  final Question question;
  final Function(Question question) onAnswerUpdate;
  const SignatureInputWidget(this.question, this.onAnswerUpdate,{Key? key}) : super(key: key);

  @override
  State<SignatureInputWidget> createState() => _SignatureInputWidgetState();
}

class _SignatureInputWidgetState extends State<SignatureInputWidget> {
  final _signatureCubitCubit = sl<SignatureCubit>();

  @override
  void initState() {
    super.initState();
    if (widget.question.answerUnit?.stringValue != null) {
      _signatureCubitCubit.changeSignatureStatus(widget.question.answerUnit?.stringValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    return buildSignatureOrAnswerWidget(context);
  }

  Widget buildSignatureOrAnswerWidget(BuildContext context) {
    return StreamBuilder<String?>(
      stream: _signatureCubitCubit.signatureStatusStream,
        builder: (context, signatureStatus)
        {
          if (signatureStatus.hasData && signatureStatus.data != null)
            {
              return buildSignatureWidget(context,true);
            }else{
            return buildSignatureWidget(context,false);
          }
        }
    );
  }

  Widget buildSignatureWidget(BuildContext context,bool value) {
    return MyInkWell(
      onTap: ()  async {
        File? file =  await MRouter.pushNamed(MRouter.signatureWidget,arguments:widget.question);
        if(file != null)
          {
            _signatureCubitCubit.upload(widget.question,file,widget.onAnswerUpdate);
          }
      },
      child: Container(
        height: Dimens.etHeight_48,
        decoration: BoxDecoration(
          color: Get.theme.inputBoxBackgroundColor,
          border: Border.all(color: Get.theme.inputBoxBorderColor),
          borderRadius: const BorderRadius.all(
            Radius.circular(Dimens.radius_8),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: Dimens.padding_12),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              SvgPicture.asset(
                'assets/images/signature.svg',color: Get.theme.iconColorNormal,width: Dimens.padding_24,
              ),
              const SizedBox(width: Dimens.padding_12),
              Expanded(
                child: Text('add_signature'.tr,
                    style: Get.textTheme.bodyText1
                        ?.copyWith(color: context.theme.hintColor)),
              ),
              const SizedBox(width: Dimens.padding_12),
              Visibility(
                visible: value,
                child: Text('change'.tr,
                    style: Get.textTheme.bodyMedium
                        ?.copyWith(color: AppColors.primaryMain,fontWeight: FontWeight.w400)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
