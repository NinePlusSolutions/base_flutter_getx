enum Flavor {
  dev,
  prod,
}

class F {
  static Flavor? appFlavor;

  static String get name => appFlavor?.name ?? '';

  static String get title {
    switch (appFlavor) {
      case Flavor.dev:
        return '[DEV] Flutter GetX';
      case Flavor.prod:
        return 'Flutter GetX';
      default:
        return 'title';
    }
  }

}
