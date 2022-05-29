import Foundation
import CoreFoundationLib

protocol TransfersHomeNavigatorProtocol: MenuNavigator, OperativesNavigatorProtocol, PullOffersActionsNavigatorProtocol {
    func navigateToTransferDetail(with trasnferDetailData: TransferDetailDataType)
}

class TransfersHomeNavigator: AppStoreNavigator {
    var presenterProvider: PresenterProvider
    var drawer: BaseMenuViewController
    
    required init(presenterProvider: PresenterProvider, drawer: BaseMenuViewController) {
        self.presenterProvider = presenterProvider
        self.drawer = drawer
    }
}

extension TransfersHomeNavigator: TransfersHomeNavigatorProtocol {
    func navigateToTransferDetail(with trasnferDetailData: TransferDetailDataType) {
        guard let navigation = drawer.currentRootViewController as? NavigationController else { return }
        let transferDetailPresenter = presenterProvider.transferDetailPresenter(with: trasnferDetailData)
        navigation.pushViewController(transferDetailPresenter.view, animated: true)
    }
}
