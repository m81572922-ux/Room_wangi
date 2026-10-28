package com.example.rwgacor

import android.content.pm.PackageManager
import android.os.Bundle
import rikka.shizuku.Shizuku
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "rw_gacor/shizuku"
    private val requestCode = 9021
    private var pendingResult: MethodChannel.Result? = null

    private val permissionListener =
        Shizuku.OnRequestPermissionResultListener { code, grantResult ->
            if (code == requestCode) {
                pendingResult?.success(grantResult == PackageManager.PERMISSION_GRANTED)
                pendingResult = null
            }
        }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Shizuku.addRequestPermissionResultListener(permissionListener)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isServiceRunning" -> result.success(Shizuku.pingBinder())
                    "hasPermission" -> result.success(
                        Shizuku.pingBinder() &&
                            Shizuku.checkSelfPermission() == PackageManager.PERMISSION_GRANTED
                    )
                    "requestPermission" -> {
                        when {
                            !Shizuku.pingBinder() -> result.success(false)
                            Shizuku.checkSelfPermission() == PackageManager.PERMISSION_GRANTED ->
                                result.success(true)
                            else -> {
                                pendingResult = result
                                Shizuku.requestPermission(requestCode)
                            }
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    override fun onDestroy() {
        Shizuku.removeRequestPermissionResultListener(permissionListener)
        super.onDestroy()
    }
}
