enum MifidAdvisoryClausesResponse {
    case success(state: MifidAdviceState)
    case error(response: UseCaseError<MifidAdvicesUseCaseErrorOutput>)
}

class MifidAdvisoryClausesStepPresenter: MifidPresenter<MifidAdvisoryClausesStepViewController, VoidNavigator, MifidAdvisoryClausesStepPresenterProtocol> {
    override var mifidStep: MifidStep {
        return .advisoryClauses
    }
    
    private var mifidAdviceState: MifidAdviceState?
    private var onValidationsFinish: ((Bool) -> Void)?
    override var shouldShowProgress: Bool {
        return false
    }
    
    required init(withProvider provider: MifidPresenterProvider) {
        super.init(dependencies: provider.dependencies, sessionManager: provider.sessionManager, navigator: provider.navigatorProvider.voidNavigator)
    }
    
    override func viewShown() {
        super.viewShown()
        
        guard let state = mifidAdviceState else {
            fatalError()
        }
        
        var dialogTitle: LocalizedStylableText?
        let dialogMessage: LocalizedStylableText
        let accept: DialogButtonComponents
        let cancel: DialogButtonComponents?
        switch state {
        case .none:
            fatalError()
        case .adviceAndContinue(let title, let message):
            if let title = title {
                dialogTitle = LocalizedStylableText(text: title, styles: nil)
            }
            dialogMessage = LocalizedStylableText(text: message, styles: nil)
            accept = DialogButtonComponents(titled: stringLoader.getString("generic_button_continue")) { [weak self] in
                guard let thisStep = self else {
                    return
                }
                thisStep.container?.mifidStepFinished(presenter: thisStep)
            }
            cancel = DialogButtonComponents(titled: stringLoader.getString("generic_button_cancel")) { [weak self] in
                self?.container?.cancelMifid()
            }
        case .adviceBlocking(let title, let message):
            if let title = title {
                dialogTitle = LocalizedStylableText(text: title, styles: nil)
            }
            dialogMessage = LocalizedStylableText(text: message, styles: nil)
            accept = DialogButtonComponents(titled: stringLoader.getString("generic_button_accept")) { [weak self] in
                self?.container?.cancelMifid()
            }
            cancel = nil
        }
        
        Dialog.alert(title: dialogTitle, body: dialogMessage, withAcceptComponent: accept, withCancelComponent: cancel, showsCloseButton: false, source: view)
    }
    
    func validate(completion: @escaping (MifidAdvisoryClausesResponse) -> Void) {
        fatalError()
    }
    
    override func evaluateBeforeShowing(onSuccess: @escaping (Bool) -> Void) {
        container?.showCommonLoading(completion: { [weak self] in
            guard let thisPresenter = self else {
                return
            }
            thisPresenter.onValidationsFinish = onSuccess
            thisPresenter.performValidations()
        })
    }
}

extension MifidAdvisoryClausesStepPresenter {
    
    private func performValidations() {
        validate { (response) in
            self.handleMifidAdviceResponse(response: response)
        }
    }
    
    func handleMifidAdviceResponse(response: MifidAdvisoryClausesResponse) {
        switch response {
        case .success(let state):
            evaluate(state: state)
        case .error(let  errorType):
            container?.hideCommonLoading { [weak self] in
                guard let strongSelf = self else { return }
                switch errorType {
                case .error(let error):
                    strongSelf.showError(keyDesc: error?.getErrorDesc())
                case .networkUnavailable:
                    strongSelf.showError(keyDesc: "generic_error_needInternetConnection")
                case .generic, .intern, .unauthorized:
                    strongSelf.showError(keyDesc: nil)
                }
            }
        }
    }
    
    private func evaluate(state: MifidAdviceState) {
        mifidAdviceState = state
        let show: Bool
        switch state {
        case .none:
            show = false
        case .adviceBlocking,
             .adviceAndContinue:
            show = true
        }
        if show {
            container?.hideCommonLoading { [weak self] in
                self?.onValidationsFinish?(show)
            }
        } else {
            onValidationsFinish?(show)
        }
        
    }
}

extension MifidAdvisoryClausesStepPresenter: MifidAdvisoryClausesStepPresenterProtocol {}
