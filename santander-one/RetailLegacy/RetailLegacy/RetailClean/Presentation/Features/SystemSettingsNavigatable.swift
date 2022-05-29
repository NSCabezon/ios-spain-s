import UIKit

public protocol SystemSettingsNavigatable: UrlActionsCapable {
    func navigateToSettings()
}

extension SystemSettingsNavigatable {
    func navigateToSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString), canOpen(url) {
            open(url)
        }
    }
}
