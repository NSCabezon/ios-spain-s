import CoreFoundationLib

enum Mifid2Response {
    case success(response: Mifid2IndicatorsUseCaseOkOutput)
    case error(response: UseCaseError<Mifid2IndicatorsUseCaseErrorOutput>)
}

class Mifid2StepPresenter: MifidPresenter<Mifid2StepViewController, VoidNavigator, Mifid2StepPresenterProtocol> {
    override var mifidStep: MifidStep {
        return .mifid2
    }
    
    private var mifidValidationError: MifidIndicatorsError?
    private var onValidationsFinish: ((Bool) -> Void)?
    private var mifid2ErrorMessages: [String: String]?
    override var shouldShowProgress: Bool {
        return false
    }
    
    required init(withProvider provider: MifidPresenterProvider) {
        super.init(dependencies: provider.dependencies, sessionManager: provider.sessionManager, navigator: provider.navigatorProvider.voidNavigator)
    }
    
    override func viewShown() {
        super.viewShown()
        
        guard let error = mifidValidationError else {
            fatalError()
        }
        
        let title = stringLoader.getString("mifid_alert_title_error")
        let errorText = mifid2ErrorMessages?[error.appConfigKey] ?? ""
        let message = LocalizedStylableText(text: errorText, styles: nil)
        let accept = DialogButtonComponents(titled: stringLoader.getString("generic_button_accept")) { [weak self] in
            self?.container?.cancelMifid()
        }
        Dialog.alert(title: title, body: message, withAcceptComponent: accept, withCancelComponent: nil, showsCloseButton: false, source: view)
    }
    
    func validate(completion: @escaping (Mifid2Response) -> Void) {
        fatalError()
    }
    
    override  func evaluateBeforeShowing(onSuccess: @escaping (Bool) -> Void) {
        container?.showCommonLoading { [weak self] in
            guard let thisPresenter = self else {
                return
            }
            thisPresenter.onValidationsFinish = onSuccess
            thisPresenter.performValidations()
            
        }
    }
}

extension Mifid2StepPresenter {
    
    private func performValidations() {
        validate { (response) in
            self.handleMifid2Response(response: response)
        }
        
    }
    
    func handleMifid2Response(response: Mifid2Response) {
        switch response {
        case .success(let successResponse):
            mifid2ErrorMessages = successResponse.mifid2Errors
            evaluate(mifidIndicators: successResponse.mifidIndicators)
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
    
    private func evaluate(mifidIndicators: MifidIndicators) {
        let show: Bool
        switch mifidIndicators {
        case .nothingToDo:
            show = false
        case .invalid(let error):
            mifidValidationError = error
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

extension Mifid2StepPresenter: Mifid2StepPresenterProtocol {}
