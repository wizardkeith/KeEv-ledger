package com.keev.ledger

import android.content.Context
import android.net.ConnectivityManager
import android.net.Network
import android.net.NetworkCapabilities
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel

class MainActivity : FlutterFragmentActivity() {
    private var callback: ConnectivityManager.NetworkCallback? = null
    private var connectivitySink: EventChannel.EventSink? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.keev.ledger/sync_connectivity"
        ).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                val manager = getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
                connectivitySink = events
                fun emit() {
                    val network = manager.activeNetwork
                    val capabilities = network?.let(manager::getNetworkCapabilities)
                    val potentiallyOnline = capabilities?.hasCapability(
                        NetworkCapabilities.NET_CAPABILITY_INTERNET
                    ) == true
                    mainHandler.post {
                        if (connectivitySink === events) events.success(potentiallyOnline)
                    }
                }
                emit()
                callback?.let(manager::unregisterNetworkCallback)
                callback = object : ConnectivityManager.NetworkCallback() {
                    override fun onAvailable(network: Network) = emit()
                    override fun onLost(network: Network) = emit()
                    override fun onCapabilitiesChanged(network: Network, caps: NetworkCapabilities) = emit()
                }
                manager.registerDefaultNetworkCallback(callback!!)
            }

            override fun onCancel(arguments: Any?) {
                val manager = getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
                connectivitySink = null
                callback?.let {
                    try { manager.unregisterNetworkCallback(it) } catch (_: IllegalArgumentException) {}
                }
                callback = null
            }
        })
    }
}
