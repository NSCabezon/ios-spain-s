import Foundation

class UsualTransferAccountSelectorPresenter: TransferAccountSelectorPresenter<UsualTransferOperativeData, VoidNavigator> {
    override var screenId: String? {
        return TrackerPagePrivate.UsualTransferOriginAccountSelection().page
    }
}
