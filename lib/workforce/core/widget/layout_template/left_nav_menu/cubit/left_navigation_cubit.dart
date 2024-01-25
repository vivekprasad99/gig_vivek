import 'dart:async';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/widget/layout_template/left_nav_menu/left_navigation.dart';
import 'package:bloc/bloc.dart';
import 'package:rxdart/rxdart.dart';

class LeftNavigationCubit extends Cubit<String> {
  StreamSubscription<String>? _routeNameSubscription;

  final _isLeftNavigationVisible = BehaviorSubject<bool>.seeded(true);
  Stream<bool> get isLeftNavigationVisible => _isLeftNavigationVisible.stream;
  Function(bool) get changeLeftNavigationVisible =>
      _isLeftNavigationVisible.sink.add;

  void toggleLeftNavigation() {
    if (_isLeftNavigationVisible.value) {
      changeLeftNavigationVisible(false);
    } else {
      changeLeftNavigationVisible(true);
    }
  }

  LeftNavigationCubit() : super("") {
    _routeNameSubscription = sl<MRouter>().currentRouteStream.listen((route) {
      if (LeftNavigation.possibleRoutes.contains(route)) {
        emit(route);
      }
    });
  }

  @override
  Future<void> close() {
    _routeNameSubscription?.cancel();
    _isLeftNavigationVisible.close();
    return super.close();
  }
}
