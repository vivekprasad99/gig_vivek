import 'package:awign/workforce/aw_questions/data/model/configuration/configuration.dart';
import 'package:awign/workforce/aw_questions/data/model/configuration/configuration_type.dart';
import 'package:awign/workforce/aw_questions/data/model/sub_type.dart';

class AudioConfiguration extends Configuration {
  AudioConfiguration({
    this.subType = SubType.audioRecording,
    this.recordingLength,
  }) : super(configurationType: ConfigurationType.audioRecording);

  late SubType subType;
  late double? recordingLength;
}
