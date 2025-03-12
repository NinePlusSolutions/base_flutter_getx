import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

class DownloadServices extends GetxService {
  String cacheDir = '';

  @override
  void onInit() async {
    super.onInit();
    cacheDir = (await getApplicationCacheDirectory()).path;
  }

  Future<void> downloadFile(String url) async {}

  String fileName(String url) {
    final uri = Uri.parse(url);
    final name = uri.pathSegments.last;
    return name;
  }
}
