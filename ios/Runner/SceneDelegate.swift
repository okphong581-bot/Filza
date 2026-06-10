import UIKit
import Flutter

/// SceneDelegate — Quản lý UIWindowScene lifecycle (iOS 13+).
///
/// Khi dùng scene-based app, cần đăng ký MethodChannel tại đây
/// thay vì (hoặc bổ sung) AppDelegate, vì FlutterViewController
/// được gắn vào UIWindowScene, không phải UIApplication.
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    // ──────────────────────────────────────────────────────────────
    // Constants
    // ──────────────────────────────────────────────────────────────

    private static let channelName = "ha.floating/overlay"

    // ──────────────────────────────────────────────────────────────
    // Properties
    // ──────────────────────────────────────────────────────────────

    var window: UIWindow?
    private var methodChannel: FlutterMethodChannel?

    // ──────────────────────────────────────────────────────────────
    // UIWindowSceneDelegate
    // ──────────────────────────────────────────────────────────────

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        // Lấy FlutterViewController được Flutter engine tạo sẵn
        // Flutter thường tự tạo window và rootViewController khi dùng
        // default GeneratedPluginRegistrant flow.
        // Nếu rootViewController đã là FlutterViewController, setup channel ngay.
        if let flutterVC = window?.rootViewController as? FlutterViewController {
            setupMethodChannel(messenger: flutterVC.binaryMessenger)
        } else {
            // Fallback: tìm từ UIApplication
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
               let rootVC = appDelegate.window?.rootViewController as? FlutterViewController {
                setupMethodChannel(messenger: rootVC.binaryMessenger)
            }
        }

        // Thiết lập OverlayWindowManager với scene
        if #available(iOS 13.0, *) {
            OverlayWindowManager.shared.setScene(windowScene)
        }

        _ = windowScene // sử dụng để tránh warning unused
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Scene bị ngắt kết nối — có thể là background hoặc đóng ứng dụng
        // Overlay vẫn tồn tại nếu windowLevel đủ cao
        print("[HaFloating] Scene disconnected.")
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        print("[HaFloating] Scene did become active.")
    }

    func sceneWillResignActive(_ scene: UIScene) {
        print("[HaFloating] Scene will resign active.")
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Sync lại trạng thái overlay khi app vào foreground
        OverlayWindowManager.shared.syncOverlayState()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Lưu vị trí overlay khi vào background
        OverlayWindowManager.shared.savePositionIfNeeded()
    }

    // ──────────────────────────────────────────────────────────────
    // MethodChannel Setup
    // ──────────────────────────────────────────────────────────────

    private func setupMethodChannel(messenger: FlutterBinaryMessenger) {
        let channel = FlutterMethodChannel(
            name: SceneDelegate.channelName,
            binaryMessenger: messenger
        )

        self.methodChannel = channel

        channel.setMethodCallHandler { [weak self] call, result in
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                result(FlutterError(
                    code: "NO_APP_DELEGATE",
                    message: "Không tìm thấy AppDelegate",
                    details: nil
                ))
                return
            }
            appDelegate.handleMethodCall(call, result: result)
        }

        print("[HaFloating] SceneDelegate: MethodChannel đã được đăng ký.")
    }
}
