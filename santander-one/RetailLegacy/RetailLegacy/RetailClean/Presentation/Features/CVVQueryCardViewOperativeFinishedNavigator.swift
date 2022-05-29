import UIKit
import Cards

class CVVQueryCardViewOperativeFinishedNavigator {
    let presenterProvider: PresenterProvider
    let drawer: BaseMenuViewController
    
    init(presenterProvider: PresenterProvider, drawer: BaseMenuViewController) {
        self.presenterProvider = presenterProvider
        self.drawer = drawer
    }
}

extension CVVQueryCardViewOperativeFinishedNavigator: StopOperativeProtocol {
    func onSuccess(container: OperativeContainerProtocol) {
        let sourceView = container.operativeContainerNavigator.sourceView
        let cvvQueryOperativePresenter = presenterProvider.cvvQueryOperativePresenter
        cvvQueryOperativePresenter.numberCipher = container.provideParameter()
        if let productHome = sourceView as? CardsHomeViewController {
            sourceView?.navigationController?.popToViewController(productHome, animated: true)
        } else if let productView = sourceView as? TransactionDetailContainerViewController {
            sourceView?.navigationController?.popToViewController(productView, animated: true)
        } else if let sourceView = sourceView {
            sourceView.navigationController?.popToViewController(sourceView, animated: true)
        } else {
            sourceView?.navigationController?.popToRootViewController(animated: true)
        }
        cvvQueryOperativePresenter.view.modalPresentationStyle = .overCurrentContext
        sourceView?.present(cvvQueryOperativePresenter.view, animated: false, completion: nil)
    }
}
