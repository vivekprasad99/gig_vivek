import 'package:awign/workforce/aw_questions/data/model/upload_or_sync/upload_operation.dart';
import 'package:awign/workforce/core/data/local/database/upload_entity_ho/upload_entity_ho.dart';

class PriorityOperation {
  UploadEntityHO uploadEntityHO;
  UploadOperation uploadOperation;

  PriorityOperation(this.uploadEntityHO, this.uploadOperation);
}
