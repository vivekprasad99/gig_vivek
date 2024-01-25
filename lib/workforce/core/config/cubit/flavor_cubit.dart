import 'package:awign/workforce/core/config/flavor_config.dart';
import 'package:bloc/bloc.dart';

part 'flavor_state.dart';

class FlavorCubit extends Cubit<FlavorState> {
  final FlavorConfig flavorConfig;

  FlavorCubit(this.flavorConfig)
      : super(FlavorState(flavorConfig: flavorConfig));
}
