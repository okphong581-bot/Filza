import UIKit
import Flutter

/// AppDelegate — Điểm vào chính của ứng dụng iOS.
///
/// Trách nhiệm:
/// 1. Khởi tạo Flutter engine.
/// 2. Đăng ký MethodChannel `ha.floating/overlay` để bridge với Flutter/Dart.
/// 3. Xử lý các lệnh overlay (show / hide / toggle / getState).
/// 4. Xử lý lỗi an toàn nếu API không khả dụng trên iOS version hiện tại.
@UIApplicationMain
class AppDelegate: FlutterAppDelegate {

    // ──────────────────────────────────────────────────────────────
    // Constants
    // ──────────────────────────────────────────────────────────────

    /// Tên channel phải khớp với Dart side: OverlayService._channel
    private static let channelName = "ha.floating/overlay"

    // ──────────────────────────────────────────────────────────────
    // Application lifecycle
    // ──────────────────────────────────────────────────────────────

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        // 1. Gọi super để Flutter engine khởi tạo đúng cách
        let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)

        // 2. Đăng ký MethodChannel sau khi Flutter engine sẵn sàng
        setupOverlayChannel()

        return result
    }

    // ──────────────────────────────────────────────────────────────
    // MethodChannel Setup
    // ──────────────────────────────────────────────────────────────

    private func setupOverlayChannel() {
        // Lấy FlutterViewController từ window root
        guard let controller = window?.rootViewController as? FlutterViewController else {
            // Nếu không có (ví dụ dùng SceneDelegate), channel sẽ được setup từ SceneDelegate
            print("[HaFloating] AppDelegate: không tìm thấy FlutterViewController, "
                  + "sẽ setup channel từ SceneDelegate.")
            return
        }

        let messenger = controller.binaryMessenger
        let channel = FlutterMethodChannel(
            name: AppDelegate.channelName,
            binaryMessenger: messenger
        )

        channel.setMethodCallHandler { [weak self] call, result in
            self?.handleMethodCall(call, result: result)
        }

        print("[HaFloating] MethodChannel '\(AppDelegate.channelName)' đã được đăng ký.")
    }

    // ──────────────────────────────────────────────────────────────
    // Method Call Handler
    // ──────────────────────────────────────────────────────────────

    func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        print("[HaFloating] Nhận lệnh: \(call.method)")

        switch call.method {

        case "showOverlay":
            OverlayWindowManager.shared.showOverlay { success, error in
                if success {
                    result("success")
                } else {
                    result(FlutterError(
                        code: error?.code ?? "SHOW_FAILED",
                        message: error?.message ?? "Không thể hiển thị overlay",
                        details: error?.details
                    ))
                }
            }

        case "hideOverlay":
            OverlayWindowManager.shared.hideOverlay { success, error in
                if success {
                    result("success")
                } else {
                    result(FlutterError(
                        code: error?.code ?? "HIDE_FAILED",
                        message: error?.message ?? "Không thể ẩn overlay",
                        details: error?.details
                    ))
                }
            }

        case "toggleOverlay":
            OverlayWindowManager.shared.toggleOverlay { isVisible, error in
                if let error = error {
                    result(FlutterError(
                        code: error.code,
                        message: error.message,
                        details: error.details
                    ))
                } else {
                    result(isVisible)
                }
            }

        case "getOverlayState":
            let isVisible = OverlayWindowManager.shared.isOverlayVisible
            result(isVisible)

        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
