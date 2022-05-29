import UIKit
import Cards

class PINQueryCardViewOperativeFinishedNavigator {
    let presenterProvider: PresenterProvider
    let drawer: BaseMenuViewController
    
    init(presenterProvider: PresenterProvider, drawer: BaseMenuViewController) {
        self.presenterProvider = presenterProvider
        self.drawer = drawer
    }
}

extension PINQueryCardViewOperativeFinishedNavigator: StopOperativeProtocol {
    func onSuccess(container: OperativeContainerProtocol) {
        let sourceView = container.operativeContainerNavigator.sourceView
        let pinQueryOperativePresenter = presenterProvider.pinQueryOperativePresenter
        pinQueryOperativePresenter.numberCipher = container.provideParameter()        
        if let productHome = sourceView as? CardsHomeViewController {
            sourceView?.navigationController?.popToViewController(productHome, animated: true)
        } else if let productView = sourceView as? TransactionDetailContainerViewController {
            sourceView?.navigationController?.popToViewController(productView, animated: true)
        } else {
            sourceView?.navigationController?.popToRootViewController(animated: true)
        }
        pinQueryOperativePresenter.view.modalPresentationStyle = .overCurrentContext
        sourceView?.present(pinQueryOperativePresenter.view, animated: false, completion: nil)
    }
}
