import UIKit

class CancelOrderOperativeFinishedNavigator {
    let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider) {
        self.presenterProvider = presenterProvider
    }
}

extension CancelOrderOperativeFinishedNavigator: StopOperativeProtocol {
    func onSuccess(container: OperativeContainerProtocol) {
        guard let source = container.operativeContainerNavigator.sourceView else {
            return
        }
        let operativeData: CancelOrderOperativeData = container.provideParameter()
        let dialogPresenter = presenterProvider.operativeFinishedDialogPresenter
        dialogPresenter.dialogTitle = operativeData.dialogTitle
        dialogPresenter.dialogMessage = operativeData.dialogMessage
        dialogPresenter.acceptTitle = operativeData.acceptTitle
        let viewController: UIViewController?
        if let detailViewController = (source.navigationController?.viewControllers.first { $0 is OrderDetailViewController }) {
            viewController = detailViewController
            dialogPresenter.finishAction = {
                if let homeViewController = (source.navigationController?.viewControllers.first { $0 is ProductHomeViewController }) {
                    source.navigationController?.popToViewController(homeViewController, animated: true)
                } else {
                    source.navigationController?.popToRootViewController(animated: true)
                }
            }
        } else if let homeViewController = (source.navigationController?.viewControllers.first { $0 is ProductHomeViewController }) {
            viewController = homeViewController
        } else {
            viewController = source.navigationController?.viewControllers.first
        }
        guard let destinationView = viewController else {
            return
        }
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            dialogPresenter.view.modalPresentationStyle = .overCurrentContext
            viewController?.present(dialogPresenter.view, animated: false, completion: nil)
        }
        source.navigationController?.popToViewController(destinationView, animated: true)
        CATransaction.commit()
    }
    
    func onSignatureError(container: OperativeContainerProtocol) {
        guard let sourceView = container.operativeContainerNavigator.sourceView else {
            return
        }
        sourceView.navigationController?.popToViewController(sourceView, animated: true)
    }
}
