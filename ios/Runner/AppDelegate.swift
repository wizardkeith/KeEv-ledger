import Flutter
import Network
import AppTrackingTransparency
import UIKit

final class SyncConnectivityStreamHandler: NSObject, FlutterStreamHandler {
  private let monitor = NWPathMonitor()
  private let queue = DispatchQueue(label: "com.keev.ledger.sync-connectivity")
  private var sink: FlutterEventSink?

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    sink = events
    monitor.pathUpdateHandler = { [weak self] path in
      DispatchQueue.main.async { self?.sink?(path.status == .satisfied) }
    }
    monitor.start(queue: queue)
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    sink = nil
    monitor.cancel()
    return nil
  }
}

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var connectivityHandler: SyncConnectivityStreamHandler?
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "KeEvSyncConnectivity")
    let handler = SyncConnectivityStreamHandler()
    FlutterEventChannel(
      name: "com.keev.ledger/sync_connectivity",
      binaryMessenger: registrar.messenger()
    ).setStreamHandler(handler)
    connectivityHandler = handler

    let trackingRegistrar = engineBridge.pluginRegistry.registrar(forPlugin: "KeEvTrackingAuthorization")
    FlutterMethodChannel(
      name: "com.keev.ledger/tracking",
      binaryMessenger: trackingRegistrar.messenger()
    ).setMethodCallHandler { call, result in
      guard #available(iOS 14, *) else {
        result("notSupported")
        return
      }
      func value(_ status: ATTrackingManager.AuthorizationStatus) -> String {
        switch status {
        case .notDetermined: return "notDetermined"
        case .restricted: return "restricted"
        case .denied: return "denied"
        case .authorized: return "authorized"
        @unknown default: return "restricted"
        }
      }
      switch call.method {
      case "status":
        result(value(ATTrackingManager.trackingAuthorizationStatus))
      case "request":
        DispatchQueue.main.async {
          ATTrackingManager.requestTrackingAuthorization { status in
            DispatchQueue.main.async { result(value(status)) }
          }
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
