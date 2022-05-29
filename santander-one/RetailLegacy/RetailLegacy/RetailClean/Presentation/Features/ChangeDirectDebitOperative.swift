import Foundation
import CoreFoundationLib

class ChangeDirectDebitOperative: BillOperative {
    weak var container: OperativeContainerProtocol? {
        didSet {
            buildSteps()
        }
    }
    let isShareable = true
    let needsReloadGP = false
    var steps = [OperativeStep]()
    var finishedOperativeNavigator: StopOperativeProtocol {
        return dependencies.navigatorProvider.toBillHomeOperativeFinishNavigator
    }
    var opinatorPage: OpinatorPage? {
        return .changeDirectDebit
    }
    
    let dependencies: PresentationComponent
    
    init(dependencies: PresentationComponent) {
        self.dependencies = dependencies
    }
    
    func buildSteps() {
        guard let presenterProvider = container?.presenterProvider else {
            return
        }
        let factory = OperativeStepFactory(presenterProvider: presenterProvider)
        add(step: factory.createStep() as ChangeDirectDebitAccountSelection)
        add(step: factory.createStep() as ChangeDirectDebitConfirmation)
        add(step: factory.createStep() as OperativeSignatureWithToken)
        add(step: factory.createStep() as OperativeSummary)
    }
    
    func performSetup(for delegate: OperativeLauncherPresentationDelegate, container: OperativeContainerProtocol, success: @escaping () -> Void) {
        let operativeData: ChangeDirectDebitOperativeData = container.provideParameter()
        let input = SetupChangeDirectDebitUseCaseInput(bill: operativeData.bill)
        let usecase = dependencies.useCaseProvider.getSetupChangeDirectDebitUseCase(input: input)
        UseCaseWrapper(
            with: usecase,
            useCaseHandler: dependencies.useCaseHandler,
            errorHandler: delegate.errorOperativeHandler,
            onSuccess: { result in
                operativeData.update(accounts: result.accounts)
                container.saveParameter(parameter: result.operativeConfig)
                container.saveParameter(parameter: operativeData)
                success()
        }, onError: { error in
            delegate.hideOperativeLoading {
                delegate.showOperativeAlertError(keyTitle: nil, keyDesc: error?.getErrorDesc(), completion: nil)
            }
        }
        )
    }
    
    func performSignature(for presenter: GenericPresenterErrorHandler, completion: @escaping (Bool, GenericErrorSignatureErrorOutput?) -> Void) {
        guard let container = container else {
            return
        }
        let signatureFilled: SignatureFilled<SignatureWithToken> = container.provideParameter()
        let parameter: ChangeDirectDebitOperativeData = containerParameter()
        guard let destinationAccount = parameter.destinationAccount else { return }
        let input = ConfirmChangeDirectDebitUseCaseInput(bill: parameter.bill, destinationAccount: destinationAccount, signature: signatureFilled.signature)
        let useCase = dependencies.useCaseProvider.getConfirmChangeDirectDebitUseCase(input: input)
        UseCaseWrapper(with: useCase, useCaseHandler: dependencies.useCaseHandler, errorHandler: presenter, onSuccess: { _ in
            completion(true, nil)
        }, onError: { error in
            completion(false, error)
        })
    }
    
    func getSummaryTitle() -> LocalizedStylableText {
        return dependencies.stringLoader.getString("summary_label_domiciliationAccountModified")
    }
    
    func getSummarySubtitle() -> LocalizedStylableText? {
        return nil
    }
    
    func getSummaryInfo() -> [SummaryItemData]? {
        let parameter: ChangeDirectDebitOperativeData = containerParameter()
        guard let destinationAccount = parameter.destinationAccount else { return nil }
        let bill = parameter.bill
        let billDetail = parameter.billDetail
        return [
            SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_newAccount"), value: destinationAccount.getAliasAndInfo()),
            SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_holder"), value: bill.holder.capitalizingFirstLetter()),
            SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_EntityIssuing"), value: bill.name.capitalizingFirstLetter()),
            SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_issuingEntity"), value: bill.issuerCode),
            SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_authorisationReference"), value: billDetail.mandateReference)
            ,
            SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_description"), value: billDetail.concept?.capitalizingFirstLetter() ?? "")
        ]
    }
    
    func getAdditionalMessage() -> LocalizedStylableText? {
        return nil
    }
    
    func getSummaryContinueButtonText() -> LocalizedStylableText? {
        return dependencies.stringLoader.getString("generic_button_continue")
    }
    
    // MARK: - Tracker    
    var screenIdSignature: String? {
        return TrackerPagePrivate.ChangeDirectDebitSignature().page
    }
    
    var screenIdSummary: String? {
        return TrackerPagePrivate.ChangeDirectDebitSummary().page
    }
    
    func getTrackParametersSummary() -> [String: String]? {
        return nil
    }
}

struct ChangeDirectDebitAccountSelection: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.billsAndTaxesOperatives.changeDirectDebitAccountSelectionPresenter
    }
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}

struct ChangeDirectDebitConfirmation: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.billsAndTaxesOperatives.confirmationChangeDirectDebitPresenter
    }
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}
