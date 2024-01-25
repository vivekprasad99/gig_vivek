import 'package:awign/workforce/core/config/cubit/flavor_cubit.dart';
import 'package:awign/workforce/core/config/flavor_config.dart';
import 'package:awign/workforce/core/data/firebase/remote_config/remote_config_helper.dart';
import 'package:awign/workforce/core/data/remote/facebook/facebook_helper.dart';
import 'package:awign/workforce/core/data/remote/moengage/moengage_helper.dart';
import 'package:awign/workforce/core/data/local/database/hive_helper.dart';
import 'package:awign/workforce/core/data/remote/rest_client.dart' as rc;
import 'package:awign/workforce/core/deep_link/cubit/deep_link_cubit.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart' as di;
import 'package:awign/workforce/core/intl/strings.dart';
import 'package:awign/workforce/core/push_notification/firebase_messaging_service.dart';
import 'package:awign/workforce/core/router/my_route_observer.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/helper.dart';
import 'package:awign/workforce/core/utils/zoho/zoho_helper.dart';
import 'package:awign/workforce/core/widget/network_sensitive/cubit/internet_cubit.dart';
import 'package:awign/workforce/core/widget/theme/cubit/theme_cubit.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' show PlatformDispatcher;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:showcaseview/showcaseview.dart';
import 'firebase_options.dart';

void mainCommon(FlavorConfig flavorConfig) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  FlutterError.onError = (errorDetails) {
    // If you wish to record a "non-fatal" exception, please use `FirebaseCrashlytics.instance.recordFlutterError` instead
    // FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails); //ToDo when firebase crashes(because of svg) reduces.
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    // If you wish to record a "non-fatal" exception, please remove the "fatal" parameter
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  await FirebaseMessagingService().requestAndRegisterNotification();
  di.init();
  rc.init(flavorConfig);
  ZohoHelper.init(flavorConfig.zohoAppKey, flavorConfig.zohoAccessKey);
  MoEngage.init(flavorConfig.moEngageAppId);
  FaceBookEventHelper.init();
  RemoteConfigHelper.instance();
  await HiveHelper.hiveInit();
  // Boxes.getUploadEntityBox().clear();
  runApp(MultiBlocProvider(
    providers: [
      BlocProvider<FlavorCubit>(
        create: (_) => FlavorCubit(flavorConfig),
      ),
      BlocProvider<InternetCubit>(
        create: (_) => InternetCubit(sl<Connectivity>()),
      ),
      BlocProvider<ThemeCubit>(
        create: (_) => ThemeCubit(),
      ),
    ],
    child: ShowCaseWidget(
      disableBarrierInteraction: true,
      builder: Builder(builder: (context) => const AwignApp()),
    ),
  ));
}

class AwignApp extends StatefulWidget {
  const AwignApp({Key? key}) : super(key: key);

  @override
  _AwignAppState createState() => _AwignAppState();
}

class _AwignAppState extends State<AwignApp> with WidgetsBindingObserver {
  final DeepLinkCubit _deepLinkCubit = sl<DeepLinkCubit>();

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    _deepLinkCubit.initURIHandler();
    _deepLinkCubit.incomingLinkHandler();
  }

  @override
  void didChangePlatformBrightness() {
    context.read<ThemeCubit>().updateAppTheme();
    super.didChangePlatformBrightness();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    Helper.shouldShowProfileCompletionBottomSheet();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        Helper.shouldShowProfileCompletionBottomSheet();
        break;
    }
  }


  @override
  Widget build(BuildContext context) {
    FlavorCubit flavorCubit = context.read<FlavorCubit>();
    return GetMaterialApp(
      title: flavorCubit.flavorConfig.appName,
      debugShowCheckedModeBanner:
      flavorCubit.flavorConfig.appFlavor != AppFlavor.production
          ? true
          : false,
      theme: ThemeManager.appTheme,
      darkTheme: ThemeManager.appThemeDark,
      translations: Strings(),
      locale: const Locale('en', ''),
      supportedLocales: const [Locale('en', ''), Locale('hi', '')],
      onGenerateRoute: sl<MRouter>().onGenerateRoute,
      initialRoute: MRouter.splashRoute,
      navigatorKey: MRouter.globalNavigatorKey,
      navigatorObservers: [MyRouteObserver()],
    );
  }
}
