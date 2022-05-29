//

import Foundation

final class ReemittedTransferConfirmationPresenter: OnePayTransferConfirmationPresenter {
    
    override var screenId: String? {
        let parameter: ReemittedTransferOperativeData = containerParameter()
        switch parameter.type {
        case .national?: return TrackerPagePrivate.ReemittedTransferConfirmation().page
        default: return nil
        }
    }
    
    override func getTrackParameters() -> [String: String]? {
        let parameter: ReemittedTransferOperativeData = containerParameter()
        return [
            TrackerDimensions.transferType: parameter.subType?.trackerDescription ?? ""
        ]
    }
    override func modifyAmountAndConcept() {
        self.container?.backModify(controller: FormViewController.self)
    }
    
    override func modifyOriginAccount() {
        self.container?.backModify(controller: OnePayAccountSelectorViewController.self)
    }
    
    override func modifyTransferType() {
        self.container?.backModify(controller: TransferSelectorSubtypeViewController.self)
    }
}
