import Foundation

public protocol AccessibilityCapable {
    func setAccessibility(setViewAccessibility: @escaping () -> Void)
}

public extension AccessibilityCapable {
    func setAccessibility(setViewAccessibility: @escaping () -> Void) {
        DispatchQueue.main.async {
            if UIAccessibility.isVoiceOverRunning {
                setViewAccessibility()
            }
        }
    }
}
