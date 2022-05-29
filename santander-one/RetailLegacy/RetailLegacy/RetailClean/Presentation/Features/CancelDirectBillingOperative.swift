import Foundation
import CoreFoundationLib

class CancelDirectBillingOperative: BillOperative {
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
        return .cancelDirectBilling
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
        add(step: factory.createStep() as CancelDirectBillingConfirmFormStep)
        add(step: factory.createStep() as OperativeSimpleSignature)
        add(step: factory.createStep() as OperativeSummary)
    }
    
    func performSetup(for delegate: OperativeLauncherPresentationDelegate, container: OperativeContainerProtocol, success: @escaping () -> Void) {
        let operativeData: CancelDirectBillingOperativeData = container.provideParameter()
        let input = SetupCancelDirectBillingUseCaseInput(bill: operativeData.bill)
        let useCase = dependencies.useCaseProvider.setupCancelDirectBillingUseCase(input: input)
        UseCaseWrapper(with: useCase, useCaseHandler: dependencies.useCaseHandler, errorHandler: delegate.errorOperativeHandler, onSuccess: { result in
            operativeData.update(account: result.account)
            container.saveParameter(parameter: result.operativeConfig)
            container.saveParameter(parameter: operativeData)
            success()
        }, onError: { error in
            delegate.hideOperativeLoading {
                delegate.showOperativeAlertError(keyTitle: nil, keyDesc: error?.getErrorDesc(), completion: nil)
            }
        })
    }
    
    func performSignature(for presenter: GenericPresenterErrorHandler, completion: @escaping (Bool, GenericErrorSignatureErrorOutput?) -> Void) {
        let operativeData: CancelDirectBillingOperativeData = containerParameter()
        guard let account = operativeData.account, let cancelDirectBilling = operativeData.cancelDirectBilling else { return }
        let bill = operativeData.bill
        let signatureFilled: SignatureFilled<Signature> = containerParameter()
        
        let useCase = dependencies.useCaseProvider.getConfirmCancelDirectBillingUseCase(input: ConfirmCancelDirectBillingUseCaseInput(signature: signatureFilled.signature, account: account, bill: bill, cancelDirectBilling: cancelDirectBilling))
        UseCaseWrapper(with: useCase, useCaseHandler: dependencies.useCaseHandler, errorHandler: presenter, onSuccess: { _ in
            completion(true, nil)
        }, onError: { error in
            completion(false, error)
        })
    }
    
    func getSummaryTitle() -> LocalizedStylableText {
        return dependencies.stringLoader.getString("summary_title_cancelDomiciliationRight")
    }
    
    func getSummarySubtitle() -> LocalizedStylableText? {
        return nil
    }
    
    func getSummaryInfo() -> [SummaryItemData]? {
        let parameter: CancelDirectBillingOperativeData = containerParameter()
        let builder = CancelDirectBillingOperativeSummaryItemDataBuilder(parameter: parameter, dependencies: dependencies)
        builder.addHolder()
            .addAccount()
            .addEntityIssuing()
            .addCode()
            .addAuthorisationReference()
        return builder.build()
    }
    
    func getAdditionalMessage() -> LocalizedStylableText? {
        return nil
    }
    
    func getSummaryContinueButtonText() -> LocalizedStylableText? {
        return dependencies.stringLoader.getString("generic_button_continue")
    }
    
    // MARK: - Tracker
    var screenIdSignature: String? {
        return TrackerPagePrivate.CancelDirectBillingSignature().page
    }
    
    var screenIdSummary: String? {
        return TrackerPagePrivate.CancelDirectBillingsSummary().page
    }
}

// MARK: Steps
struct CancelDirectBillingConfirmFormStep: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.billsAndTaxesOperatives.cancelDirectBillingConfirmationPresenter
    }
    
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}

// MARK: - SummaryItemBuilder
private class CancelDirectBillingOperativeSummaryItemDataBuilder {
    let parameter: CancelDirectBillingOperativeData
    let dependencies: PresentationComponent
    private var fields: [SummaryItemData] = []
    
    init(parameter: CancelDirectBillingOperativeData, dependencies: PresentationComponent) {
        self.parameter = parameter
        self.dependencies = dependencies
    }
    
    @discardableResult
    func addHolder() -> CancelDirectBillingOperativeSummaryItemDataBuilder {
        fields.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_holder"), value: "\(parameter.bill.holder.camelCasedString)"))
        return self
    }
    
    @discardableResult
    func addAccount() -> CancelDirectBillingOperativeSummaryItemDataBuilder {
        fields.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_account"), value: "\(parameter.account?.getAliasAndInfo() ?? "")"))
        return self
    }
    
    @discardableResult
    func addEntityIssuing() -> CancelDirectBillingOperativeSummaryItemDataBuilder {
        fields.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_EntityIssuing"), value: "\(parameter.bill.name.camelCasedString)"))
        return self
    }
    
    @discardableResult
    func addCode() -> CancelDirectBillingOperativeSummaryItemDataBuilder {
        fields.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_code"), value: parameter.cancelDirectBilling?.cdinaut ?? ""))
        return self
    }
    
    @discardableResult
    func addAuthorisationReference() -> CancelDirectBillingOperativeSummaryItemDataBuilder {
        fields.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_authorisationReference"), value: parameter.billDetail.mandateReference))
        return self
    }
    
    func build() -> [SummaryItemData] {
        return fields
    }
}
