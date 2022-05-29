import UIKit
import CoreFoundationLib

public protocol SystemSettingsNavigatable: OpenUrlCapable {
    func navigateToSettings()
}

extension SystemSettingsNavigatable {
    public func navigateToSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString), canOpenUrl(url) {
            openUrl(url)
        }
    }
}
