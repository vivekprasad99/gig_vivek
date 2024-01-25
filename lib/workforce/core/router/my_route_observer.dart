import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:flutter/material.dart';

class MyRouteObserver extends NavigatorObserver {
  @override
  void didPush(Route? route, Route? previousRoute) {
    super.didPush(route!, previousRoute);
    sl<MRouter>().updateRoute(route.settings.name ?? '');
  }

  @override
  void didPop(Route? route, Route? previousRoute) {
    super.didPop(route!, previousRoute);
    sl<MRouter>().updateRoute(previousRoute?.settings.name ?? '');
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    sl<MRouter>().updateRoute(newRoute?.settings.name ?? '');
  }

  @override
  void didRemove(Route? route, Route? previousRoute) {
    super.didRemove(route!, previousRoute);
    sl<MRouter>().updateRoute(previousRoute?.settings.name ?? '');
  }
}
