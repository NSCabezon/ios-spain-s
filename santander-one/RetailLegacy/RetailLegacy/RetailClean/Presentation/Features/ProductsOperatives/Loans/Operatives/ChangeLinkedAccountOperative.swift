import CoreFoundationLib

class ChangeLinkedAccountOperative: Operative {
    weak var container: OperativeContainerProtocol? {
        didSet {
            buildSteps()
        }
    }
    var isShareable = true
    var needsReloadGP = true
    var steps = [OperativeStep]()
    var finishedOperativeNavigator: StopOperativeProtocol {
        return dependencies.navigatorProvider.toLoansHomeNavigator
    }
    var opinatorPage: OpinatorPage? {
        return .loanChangeAccount
    }
    
    let dependencies: PresentationComponent
    
    init(dependencies: PresentationComponent) {
        self.dependencies = dependencies
    }
    
    // MARK: - Tracker
    
    var screenIdSummary: String? {
        return TrackerPagePrivate.LoanChangeAssotiatedAccountSummary().page
    }
    var screenIdSignature: String? {
        return TrackerPagePrivate.LoanChangeAssotiatedAccountSignature().page
    }
    
    // MARK: -
    
    func buildSteps() {
        guard let presenterProvider = container?.presenterProvider else {
            return
        }
        let factory = OperativeStepFactory(presenterProvider: presenterProvider)
        
        add(step: factory.createStep() as SelectLoanLinkedAccount)
        add(step: factory.createStep() as ConfirmLinkedAccountChange)
        add(step: factory.createStep() as OperativeSimpleSignature)
        add(step: factory.createStep() as OperativeSummary)
    }
    
    func performSetup(for delegate: OperativeLauncherPresentationDelegate, container: OperativeContainerProtocol, success: @escaping () -> Void) {
        
        let loan: Loan = container.provideParameter()
        
        UseCaseWrapper(with: dependencies.useCaseProvider.setupChangeLoanLinkedAccount(input: SetupChangeLinkedAccountUseCaseInput(loan: loan)), useCaseHandler: dependencies.useCaseHandler, errorHandler: delegate.errorOperativeHandler, onSuccess: { result in
            container.saveParameter(parameter: result.loanDetail)
            container.saveParameter(parameter: result.operativeConfig)
            container.saveParameter(parameter: result.validList)
            
            if result.allowChangeAccount {
                success()
            } else {
                delegate.hideOperativeLoading {
                    delegate.showOperativeAlertError(keyTitle: nil, keyDesc: "changeAccount_error_loans", completion: nil)
                }
            }
        }, onError: { error in
            delegate.hideOperativeLoading {
                delegate.showOperativeAlertError(keyTitle: nil, keyDesc: error?.getErrorDesc(), completion: nil)
            }
        })
    }
    
    func performSignature(for presenter: GenericPresenterErrorHandler, completion: @escaping (Bool, GenericErrorSignatureErrorOutput?) -> Void) {
        guard let container = container else {
            return
        }
        let loan: Loan = container.provideParameter()
        let account: Account = container.provideParameter()
        let signatureFilled: SignatureFilled<Signature> = container.provideParameter()
        let useCase = dependencies.useCaseProvider.confirmChangeLinkedAccount(input: ConfirmChangeLinkedAccountUseCaseInput(signature: signatureFilled.signature, loan: loan, account: account))
        UseCaseWrapper(with: useCase, useCaseHandler: dependencies.useCaseHandler, errorHandler: presenter, onSuccess: { _ in
            completion(true, nil)
        }, onError: { error in
            completion(false, error)
        })
    }
    
    func getSummaryTitle() -> LocalizedStylableText {
        return dependencies.stringLoader.getString("summary_title_changeAccount")
    }
    
    func getSummarySubtitle() -> LocalizedStylableText? {
        return dependencies.stringLoader.getString("summary_text_changeAccount")
    }
    
    func getSummaryInfo() -> [SummaryItemData]? {
        guard let container = container else {
            return nil
        }
        let loan: Loan = container.provideParameter()
        let loanDetail: LoanDetail = container.provideParameter()
        let account: Account = container.provideParameter()
        
        let stringLoader = dependencies.stringLoader
        
        let contract = SimpleSummaryData(field: stringLoader.getString("changeAccount_label_loans"), value: loan.getAliasAndInfo())
        let owner = SimpleSummaryData(field: stringLoader.getString("summary_item_holder"), value: loanDetail.getHolder?.camelCasedString ?? "")
        let linkedAccount = SimpleSummaryData(field: stringLoader.getString("summary_item_associatedAccount"), value: account.getAliasAndInfo())
        let balance = SimpleSummaryData(field: stringLoader.getString("summary_item_balance"), value: account.getAmountUI())
        
        return [contract, owner, linkedAccount, balance]
    }
    
    func getAdditionalMessage() -> LocalizedStylableText? {
        return nil
    }
    
    func getSummaryContinueButtonText() -> LocalizedStylableText? {
        return dependencies.stringLoader.getString("generic_button_continue")
    }
}

struct SelectLoanLinkedAccount: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.loanOperatives.changeLoanAssociatedAccountPresenter
    }
    
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}

struct ConfirmLinkedAccountChange: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.loanOperatives.changeLinkedAccountConfirmationPresenter
    }
    
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}

struct DateRangeSearchParameters {
    var dateFrom: Date?
    var dateTo: Date?
}
