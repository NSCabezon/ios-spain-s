//

import Foundation

class TodayWidgetNavigator: TodayWidgetNavigatorProtocol {
    var context: NSExtensionContext?
    
    func openURL(_ url: URL?) {
        guard let url = url else { return }
        context?.open(url)
    }
    
}
