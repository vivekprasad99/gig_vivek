import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:meta/meta.dart';

part 'internet_state.dart';

class InternetCubit extends Cubit<InternetState> {
  final Connectivity? connectivity;
  StreamSubscription? connectivityStreamSubscription;

  InternetCubit(this.connectivity) : super(InternetLoading()) {
    monitorInternetConnection();
  }

  void emitInternetConnected(ConnectionType _connectionType) =>
      emit(InternetConnected(connectionType: _connectionType));

  void emitInternetDisconnected() => emit(InternetDisconnected());

  @override
  Future<void> close() {
    connectivityStreamSubscription?.cancel();
    return super.close();
  }

  StreamSubscription<ConnectivityResult>? monitorInternetConnection() {
    return connectivityStreamSubscription =
        connectivity?.onConnectivityChanged.listen((connectivityResult) async {
      ConnectionType connectionType = await checkInternetConnection();
      if (connectionType == ConnectionType.Online) {
        emitInternetConnected(connectionType);
      } else {
        emitInternetDisconnected();
      }
    });
  }

  Future<ConnectionType> checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        // printWrapped('connected...');
        return ConnectionType.Online;
      } else {
        return ConnectionType.Offline;
      }
    } on SocketException catch (_) {
      // printWrapped('not connected...');
      return ConnectionType.Offline;
    }
  }
}
