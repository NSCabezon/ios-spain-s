import Foundation

final class ReemittedTransferAccountSelectorPresenter: TransferAccountSelectorPresenter<ReemittedTransferOperativeData, VoidNavigator> {
    override var screenId: String? {
        return TrackerPagePrivate.ReemittedTransferOriginAccountSelection().page
    }
}
