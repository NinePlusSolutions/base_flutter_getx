// The file contains the common extension methods for the application.

import 'package:flutter_getx_boilerplate/api/api_constants.dart';
import 'package:flutter_getx_boilerplate/shared/enum/flavors_enum.dart';

extension FlavorExtension on Flavor {
  bool get isDev => this == Flavor.dev;
  bool get isProd => this == Flavor.prod;

  String get toBaseurl {
    switch (this) {
      case Flavor.dev:
        return ApiConstants.baseUrlDev;
      case Flavor.prod:
        return ApiConstants.baseUrlProd;
      default:
        return '';
    }
  }
}
