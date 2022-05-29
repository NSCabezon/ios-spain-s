import CoreFoundationLib

class Mifid1FillStepPresenter: MifidPresenter<Mifid1FillStepViewController, VoidNavigator, Mifid3ComplexStepPresenterProtocol> {
    var mifidData: Mifid1Data?
    
    init(_ dependencies: PresentationComponent, sessionManager: CoreSessionManager, navigator: VoidNavigator) {
        
        super.init(dependencies: dependencies, sessionManager: sessionManager, navigator: navigator)
    }
    
    override func loadViewData() {
        super.loadViewData()
        
        view.title = dependencies.stringLoader.getString("mifid_title_acceptClosure").text
    }
    
    func showErrorValidation() {
        showError(keyTitle: dependencies.stringLoader.getString("mifid_alert_title_error").text,
                  keyDesc: dependencies.stringLoader.getString("mifid_alert_text_error").text)
    }
    
    override func evaluateBeforeShowing(onSuccess: @escaping (Bool) -> Void) {
        guard let container = container else { return }
        mifidData = container.provideParameter() as Mifid1Data
    }
    
    func continueAction() {
        guard let confirmation = view.confirmationQuestionText else { return }
        
        if !confirmation.isEmpty && confirmation == view.questionText {
            container?.mifidStepFinished(presenter: self)
        } else {
            showErrorValidation()
        }
    }
}

extension Mifid1FillStepPresenter: Mifid3ComplexStepPresenterProtocol {
    
    var cancelButtonTitle: LocalizedStylableText {
        return dependencies.stringLoader.getString("generic_button_cancel")
    }
    
    var continueButtonTitle: LocalizedStylableText {
        return dependencies.stringLoader.getString("generic_button_accept")
    }
    
    func cancelButtonAction() {
        container?.cancelMifid()
    }
}
