//

import Foundation

class ReemittedTransferSelectorSubtypePresenter: OnePayTransferSelectorSubtypePresenter {
    
    override var screenId: String? {
        let parameter: ReemittedTransferOperativeData = containerParameter()
        switch parameter.type {
        case .national?: return TrackerPagePrivate.ReemittedTransferSubTypeSelector().page
        default: return nil
        }
    }
    
    override func getTrackParameters() -> [String: String]? {
        return nil
    }
}
