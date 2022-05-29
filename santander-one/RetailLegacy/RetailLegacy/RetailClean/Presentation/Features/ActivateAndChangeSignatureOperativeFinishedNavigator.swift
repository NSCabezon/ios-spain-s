import UIKit

class ActivateAndChangeSignatureOperativeFinishedNavigator: StopOperativeProtocol {
    
    private let presenterProvider: PresenterProvider

    init(presenterProvider: PresenterProvider) {
        self.presenterProvider = presenterProvider
    }
    
    func onSuccess(container: OperativeContainerProtocol) {
        guard let source = container.operativeContainerNavigator.sourceView, let navigationController = source.navigationController else {
            return
        }
        let dialogPresenter = presenterProvider.operativeFinishedDialogPresenter
        let operativeData: ActivateAndChangeSignatureOperativeData = container.provideParameter()
        
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            dialogPresenter.dialogTitle = operativeData.successDialogTitle
            dialogPresenter.dialogMessage = operativeData.successDialogMessage
            dialogPresenter.acceptTitle = operativeData.successAcceptTitle
            dialogPresenter.view.modalPresentationStyle = .overCurrentContext
            source.present(dialogPresenter.view, animated: false, completion: nil)
        }
        navigationController.popToViewController(source, animated: true)
        CATransaction.commit()
    }
    
}
