import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'attendance_capture_image_state.dart';

class AttendanceCaptureImageCubit extends Cubit<AttendanceCaptureImageState> {
  AttendanceCaptureImageCubit() : super(AttendanceCaptureImageInitial());
}
