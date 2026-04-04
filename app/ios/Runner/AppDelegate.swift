import Flutter
import Security
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private let trialStorageService = "com.denshetkin.budgetto"
  private let trialStorageAccount = "trial_started_at"
  private var trialStorageChannel: FlutterMethodChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    registerTrialStorageChannel(with: engineBridge.pluginRegistry)
  }

  private func registerTrialStorageChannel(with registry: FlutterPluginRegistry) {
    guard let registrar = registry.registrar(forPlugin: "TrialStorageChannel") else {
      return
    }

    let channel = FlutterMethodChannel(
      name: "com.denshetkin.budgetto/trial_storage",
      binaryMessenger: registrar.messenger()
    )

    channel.setMethodCallHandler { [weak self] call, result in
      guard let self else {
        result(FlutterError(code: "UNAVAILABLE", message: "App delegate deallocated", details: nil))
        return
      }

      switch call.method {
      case "readTrialStartedAtMillis":
        result(self.readTrialStartedAtMillis())
      case "writeTrialStartedAtMillis":
        guard
          let arguments = call.arguments as? [String: Any],
          let value = arguments["value"] as? Int
        else {
          result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing trial timestamp", details: nil))
          return
        }

        if self.writeTrialStartedAtMillis(value) {
          result(nil)
        } else {
          result(FlutterError(code: "WRITE_FAILED", message: "Failed to persist trial timestamp", details: nil))
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    trialStorageChannel = channel
  }

  private func readTrialStartedAtMillis() -> Int? {
    guard let data = readKeychainData() else {
      return nil
    }

    guard let value = String(data: data, encoding: .utf8) else {
      return nil
    }

    return Int(value)
  }

  private func writeTrialStartedAtMillis(_ value: Int) -> Bool {
    guard let data = String(value).data(using: .utf8) else {
      return false
    }

    return writeKeychainData(data)
  }

  private func readKeychainData() -> Data? {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: trialStorageService,
      kSecAttrAccount as String: trialStorageAccount,
      kSecReturnData as String: true,
      kSecMatchLimit as String: kSecMatchLimitOne
    ]

    var item: CFTypeRef?
    let status = SecItemCopyMatching(query as CFDictionary, &item)
    if status == errSecSuccess {
      return item as? Data
    }
    return nil
  }

  private func writeKeychainData(_ data: Data) -> Bool {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: trialStorageService,
      kSecAttrAccount as String: trialStorageAccount
    ]

    let attributes: [String: Any] = [
      kSecValueData as String: data
    ]

    let updateStatus = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
    if updateStatus == errSecSuccess {
      return true
    }

    if updateStatus == errSecItemNotFound {
      var addQuery = query
      addQuery[kSecValueData as String] = data
      addQuery[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
      return SecItemAdd(addQuery as CFDictionary, nil) == errSecSuccess
    }

    return false
  }
}
