class OperativeFinishedDialogPresenter: OperativeStepPresenter<OperativeFinishedDialogViewController, VoidNavigator, OperativeFinishedDialogPresenterProtocol> {
    
    var dialogTitle: LocalizedStylableText?
    var dialogMessage: LocalizedStylableText?
    var acceptTitle: LocalizedStylableText?
    var finishAction: (() -> Void)?
    
    override func viewShown() {
        super.viewShown()
        
        guard let message = dialogMessage, let acceptTitle = acceptTitle else {
            return
        }
        
        let accept = DialogButtonComponents(titled: acceptTitle) { [weak self] in
            self?.view.close {
                if let thisPresenter = self {
                    thisPresenter.finishAction?()
                    thisPresenter.container?.stepFinished(presenter: thisPresenter)
                }
            }
        }
        
        Dialog.alert(title: dialogTitle, body: message, withAcceptComponent: accept, withCancelComponent: nil, showsCloseButton: false, source: view)
    }
}

extension OperativeFinishedDialogPresenter: OperativeFinishedDialogPresenterProtocol {}
