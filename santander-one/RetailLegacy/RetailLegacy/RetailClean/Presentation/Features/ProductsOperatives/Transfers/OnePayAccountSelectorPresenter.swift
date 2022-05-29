import Foundation

class OnePayAccountSelectorPresenter: TransferAccountSelectorPresenter<OnePayTransferOperativeData, OnePayTransferNavigatorProtocol> {
    override var screenId: String? {
        return TrackerPagePrivate.TransferOriginAccountSelection().page
    }
}
