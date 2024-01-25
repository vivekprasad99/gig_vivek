import 'package:awign/workforce/aw_questions/data/model/configuration/configuration.dart';
import 'package:awign/workforce/aw_questions/data/model/configuration/configuration_type.dart';
import 'package:awign/workforce/aw_questions/widget/attachment/data/image_sync_state.dart';

class FileConfiguration extends Configuration {
  FileConfiguration({
    this.imageMetaData,
    this.blockAccess = false,
    this.overWriteMetadata,
    this.supperImposeMetadata,
  }) : super(configurationType: ConfigurationType.text);

  late String? imageMetaData;
  late bool blockAccess;
  late List<String>? overWriteMetadata;
  late List<String>? supperImposeMetadata;
  late ImageSyncStatus? imageSyncStatus;
}
