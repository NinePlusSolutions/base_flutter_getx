package com.example.flutter_getx_boilerplate

import io.flutter.embedding.android.FlutterActivity
import com.ttlock.ttlock_flutter.TtlockFlutterPlugin

class MainActivity: FlutterActivity() {
    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<String>, grantResults: IntArray) {
        val ttlockflutterpluginPlugin = flutterEngine!!.plugins[TtlockFlutterPlugin::class.java] as TtlockFlutterPlugin?
        ttlockflutterpluginPlugin?.onRequestPermissionsResult(requestCode, permissions, grantResults)
    }
}
