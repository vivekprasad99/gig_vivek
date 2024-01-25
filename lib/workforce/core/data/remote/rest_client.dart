import 'package:awign/workforce/auth/data/network/factory/headers_utils.dart';
import 'package:awign/workforce/core/config/flavor_config.dart';
import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/api_response.dart';
import 'package:awign/workforce/core/exception/exception.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/core/utils/helper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_alice/alice.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart' as get_context;
import 'package:get/get_utils/src/extensions/internacionalization.dart';

import '../../config/cubit/flavor_cubit.dart';
import '../../router/router.dart';

class RestClient {
  late Dio _dio;

  RestClient(String baseURL) {
    FlavorCubit? flavorCubit = get_context.Get.context?.read<FlavorCubit>();
    Alice alice = Alice(
        navigatorKey: MRouter.globalNavigatorKey,
        showNotification: flavorCubit?.flavorConfig.appFlavor != AppFlavor.production,
        showInspectorOnShake: flavorCubit?.flavorConfig.appFlavor != AppFlavor.production,
        darkTheme: true
    );

    BaseOptions options = BaseOptions(
      baseUrl: baseURL,
      followRedirects: false,
      connectTimeout: const Duration(milliseconds: 100000),
      receiveTimeout: const Duration(milliseconds: 100000),
    );
    _dio = Dio(options);
    _dio.interceptors
      ..add(LogInterceptor(requestBody: true, responseBody: true))
      ..add(alice.getDioInterceptor());
  }

  Future<Response> get(apiName,
      {body,Map<String, dynamic>? queryParams,Map<String, dynamic>? header, Options? option}) async {
    Map<String, dynamic> headers = await HeadersUtils.getHeaders();

    if (header != null) {
      headers.addAll(header);
    }

    if (option != null) {
      option.headers = headers;
    } else {
      option = Options(method: "get");
      option.headers = headers;
    }

    try {
      Response response =
          await _dio.request(apiName,queryParameters: queryParams, data: body, options: option);

      if (response.statusCode! < 200 || response.statusCode! > 400) {
        throw ServerException(response.statusCode, response.statusMessage);
      }
      return response;
    } catch (e) {
      AppLog.e('Exception caught: $e');

      if (e is DioError) {
        AppLog.e(e.response.toString());

        if (e.response != null && e.response?.statusCode == 401) {
          doLogout(e);
        }

        throw ServerException.fromErrorDioError(e);
      } else {
        AppLog.e('Unexpected error: $e');

        throw ServerException(0, 'server_error'.tr);
      }
    }
  }

  Future<Response> post(apiName,
      {body, Map<String, dynamic>? header, Options? option}) async {
    Map<String, dynamic> headers = await HeadersUtils.getHeaders();
    if (header != null) {
      headers.addAll(header);
    }

    if (option != null) {
      option.headers = headers;
    } else {
      option = Options(method: "post");
      option.headers = headers;
    }

    try {
      Response response =
          await _dio.request(apiName, data: body, options: option);

      if (response.statusCode! < 200 || response.statusCode! > 400) {
        throw ServerException(response.statusCode, response.statusMessage);
      }
      return response;
    } catch (e) {
      if (e is DioError) {
        AppLog.e(e.response.toString());

        if (e.response != null && e.response?.statusCode == 401) {
          doLogout(e);
        }

        throw ServerException.fromErrorDioError(e);
      } else {
        throw ServerException(0, 'server_error'.tr);
      }
    }
  }

  Future<Response> patch(apiName,
      {body, Map<String, dynamic>? header, Options? option}) async {
    Map<String, dynamic> headers = await HeadersUtils.getHeaders();

    if (header != null) {
      headers.addAll(header);
    }

    if (option != null) {
      option.headers = headers;
    } else {
      option = Options(method: "patch");
      option.headers = headers;
    }

    try {
      Response response =
          await _dio.request(apiName, data: body, options: option);

      if (response.statusCode! < 200 || response.statusCode! > 400) {
        throw ServerException(response.statusCode, response.statusMessage);
      }
      return response;
    } catch (e) {
      if (e is DioError) {
        AppLog.e(e.response.toString());

        if (e.response != null && e.response?.statusCode == 401) {
          doLogout(e);
        }

        throw ServerException.fromErrorDioError(e);
      } else {
        throw ServerException(0, 'server_error'.tr);
      }
    }
  }

  Future<Response> put(apiName,
      {body, Map<String, dynamic>? header, Options? option}) async {
    Map<String, dynamic> headers = await HeadersUtils.getHeaders();

    if (header != null) {
      headers.addAll(header);
    }

    if (option != null) {
      option.headers = headers;
    } else {
      option = Options(method: "put");
      option.headers = headers;
    }

    try {
      Response response =
          await _dio.request(apiName, data: body, options: option);

      if (response.statusCode! < 200 || response.statusCode! > 400) {
        throw ServerException(response.statusCode, response.statusMessage);
      }
      return response;
    } catch (e) {
      if (e is DioError) {
        AppLog.e(e.response.toString());

        if (e.response != null && e.response?.statusCode == 401) {
          doLogout(e);
        }

        throw ServerException.fromErrorDioError(e);
      } else {
        throw ServerException(0, 'server_error'.tr);
      }
    }
  }

  Future<Response> delete(apiName,
      {body, Map<String, dynamic>? header, Options? option}) async {
    Map<String, dynamic> headers = await HeadersUtils.getHeaders();

    if (header != null) {
      headers.addAll(header);
    }

    if (option != null) {
      option.headers = headers;
    } else {
      option = Options(method: "delete");
      option.headers = headers;
    }

    try {
      Response response =
          await _dio.request(apiName, data: body, options: option);

      if (response.statusCode! < 200 || response.statusCode! > 400) {
        throw ServerException(response.statusCode, response.statusMessage);
      }
      return response;
    } catch (e) {
      if (e is DioError) {
        AppLog.e(e.response.toString());

        if (e.response != null && e.response?.statusCode == 401) {
          doLogout(e);
        }

        throw ServerException.fromErrorDioError(e);
      } else {
        throw ServerException(0, 'server_error'.tr);
      }
    }
  }

  Future<ApiResponse> downloadFile(
      BuildContext context,
      String savePath,
      String url,
      Function(int received, int total) onReceiveProgressFunction) async {
    try {
      final response = await _dio.download(url, savePath,
          onReceiveProgress: onReceiveProgressFunction);
      if (response.statusCode! < 200 || response.statusCode! > 400) {
        throw ServerException(response.statusCode, response.statusMessage);
      } else if (response.statusCode == 200) {
        throw ServerException(response.statusCode, response.statusMessage);
      } else {
        throw ServerException(0, 'server_error'.tr);
      }
    } catch (e) {
      if (e is DioError) {
        AppLog.e(e.response.toString());

        if (e.response != null && e.response?.statusCode == 401) {
          doLogout(e);
        }

        throw ServerException.fromErrorDioError(e);
      } else {
        throw ServerException(0, 'server_error'.tr);
      }
    }
  }

  void doLogout(DioError e) async {
    if (!e.requestOptions.path.contains('/auth/email/sign_in') ||
        !e.requestOptions.path.contains('/workforce/auth/google/sign_up')) {
      SPUtil? spUtil = await SPUtil.getInstance();
      spUtil?.clear();
      Helper.doLogout();
    }
  }
}

late RestClient authRestClient;
late RestClient authV2RestClient;
late RestClient wosRestClient;
late RestClient inHouseOMSRestClient;
late RestClient coreRestClient;
late RestClient ptsRestClient;
late RestClient pdsRestClient;
late RestClient loggingRestClient;
late RestClient documentsRestClient;
late RestClient learningRestClient;
late RestClient bffRestClient;
late RestClient otpLessRestClient;
late RestClient whatsappSigninRestClient;

void init(FlavorConfig flavorConfig) {
  initAuthRestClient(flavorConfig);
  initAuthV2RestClient(flavorConfig);
  initWosRestClient(flavorConfig);
  initInHouseOMSRestClient(flavorConfig);
  initCoreRestClient(flavorConfig);
  initPTSRestClient(flavorConfig);
  initPDSRestClient(flavorConfig);
  initLoggingRestClient(flavorConfig);
  initDocumentsRestClient(flavorConfig);
  initLearningRestClient(flavorConfig);
  initBFFRestClient(flavorConfig);
  initOtpLessRestClient(flavorConfig);
  initWhatsappSigninRestClient(flavorConfig);
}

void initAuthRestClient(FlavorConfig flavorConfig) {
  authRestClient = RestClient(flavorConfig.authEndPoint);
}

void initAuthV2RestClient(FlavorConfig flavorConfig) {
  authV2RestClient = RestClient(flavorConfig.authV2EndPoint);
}

void initWosRestClient(FlavorConfig flavorConfig) {
  wosRestClient = RestClient(flavorConfig.wosEndPoint);
}

void initInHouseOMSRestClient(FlavorConfig flavorConfig) {
  inHouseOMSRestClient = RestClient(flavorConfig.inHouseOMSEndPoint);
}

void initCoreRestClient(FlavorConfig flavorConfig) {
  coreRestClient = RestClient(flavorConfig.coreEndPoint);
}

void initPTSRestClient(FlavorConfig flavorConfig) {
  ptsRestClient = RestClient(flavorConfig.ptsEndPoint);
}

void initPDSRestClient(FlavorConfig flavorConfig) {
  pdsRestClient = RestClient(flavorConfig.pdsEndPoint);
}

void initLoggingRestClient(FlavorConfig flavorConfig) {
  loggingRestClient = RestClient(flavorConfig.loggingEndPoint);
}

void initDocumentsRestClient(FlavorConfig flavorConfig) {
  documentsRestClient = RestClient(flavorConfig.documentsEndPoint);
}

void initLearningRestClient(FlavorConfig flavorConfig) {
  learningRestClient = RestClient(flavorConfig.learningEndpoint);
}

void initBFFRestClient(FlavorConfig flavorConfig) {
  bffRestClient = RestClient(flavorConfig.bffEndpoint);
}

void initOtpLessRestClient(FlavorConfig flavorConfig) {
  otpLessRestClient = RestClient(flavorConfig.otpLessEndpoint);
}

void initWhatsappSigninRestClient(FlavorConfig flavorConfig) {
  whatsappSigninRestClient = RestClient(flavorConfig.whatsappSigninEndpoint);
}
