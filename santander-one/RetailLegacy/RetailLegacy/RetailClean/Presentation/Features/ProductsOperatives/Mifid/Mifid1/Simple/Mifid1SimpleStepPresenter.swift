enum Mifid1SimpleResponse {
    case success(response: Mifid1UseCaseOkOutput)
    case error(response: UseCaseError<Mifid1UseCaseErrorOutput>)
}

class Mifid1SimpleStepPresenter: MifidPresenter<Mifid1SimpleStepViewController, VoidNavigator, Mifid1StepPresenterProtocol> {
    override var mifidStep: MifidStep {
        return .mifid1Simple
    }
    
    private var mifidValidationError: MifidIndicatorsError?
    private var onValidationsFinish: ((Bool) -> Void)?
    private var variableMessage = ""
    
    required init(withProvider provider: MifidPresenterProvider) {
        super.init(dependencies: provider.dependencies, sessionManager: provider.sessionManager, navigator: provider.navigatorProvider.voidNavigator)
    }
    
    override func loadViewData() {
        super.loadViewData()
        
        guard let container = container else { return }
        let mifidData = container.provideParameter() as Mifid1Data
        
        switch container.mifidOperative {
        case .fundsSubscription, .fundsTransfer, .pensionsExtraordinaryContribution:
            if mifidData.userIsPb {
                view.hideTitle()
            } else {
                view.titleMessage = dependencies.stringLoader.getString("mifid_popupError_mifidInformation")
            }
        case .stocksBuy, .stocksSell:
            view.titleMessage = dependencies.stringLoader.getString("mifid_popupError_stocksMifidInformation")
        }
        
        view.messageSubtitle = variableMessage
        view.styledTitle = dependencies.stringLoader.getString("mifid_title_acceptClosure")
    }
    
    func validate(completion: @escaping (Mifid1SimpleResponse) -> Void) {
        fatalError()
    }
    
    override func evaluateBeforeShowing(onSuccess: @escaping (Bool) -> Void) {
        
        container?.showCommonLoading { [weak self] in
            guard let thisPresenter = self else {
                return
            }
            thisPresenter.onValidationsFinish = onSuccess
            thisPresenter.performValidations()
        }
    }
}

extension Mifid1SimpleStepPresenter {
    
    private func performValidations() {
        validate { (response) in
            self.handleMifid1Response(response: response)
        }
        
    }

    func handleMifid1Response(response: Mifid1SimpleResponse) {
        switch response {
        case .success(let successResponse):
            guard let mifid1Data = successResponse.mifid1Data else {
                onValidationsFinish?(false)
                return
            }
            handleResponse(withData: mifid1Data)
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
    
    private func handleResponse(withData mifid1Data: Mifid1Data) {
        container?.saveParameter(parameter: mifid1Data)
        let show: Bool
        switch mifid1Data.mifid1Status {
        case .simple(let variable),
             .complex(let variable, _, _),
             .simpleMfm(let variable, _),
             .complexMfm(let variable, _, _, _):
            variableMessage = variable ?? ""
            show = true
        case .none, .mfm:
            show = false
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

extension Mifid1SimpleStepPresenter: Mifid1StepPresenterProtocol {
    
    var cancelButtonTitle: LocalizedStylableText {
        return dependencies.stringLoader.getString("generic_button_cancel")
    }
    
    var continueButtonTitle: LocalizedStylableText {
        return dependencies.stringLoader.getString("generic_button_continue")
    }
    
    func cancelButton() {
        container?.cancelMifid()
    }
    
    func continueButton() {
        container?.mifidStepFinished(presenter: self)
    }
    
}
