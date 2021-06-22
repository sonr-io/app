import 'package:connectivity/connectivity.dart';
import 'package:sonr_app/style.dart';

extension ConnectivityResultUtils on ConnectivityResult {
  /// Convert Package Enum to ConnectionRequest_InternetType enum
  ConnectionRequest_InternetType toInternetType() {
    switch (this) {
      case ConnectivityResult.wifi:
        return ConnectionRequest_InternetType.Wifi;
      case ConnectivityResult.mobile:
        return ConnectionRequest_InternetType.Mobile;
      case ConnectivityResult.none:
        return ConnectionRequest_InternetType.None;
    }
  }
}
