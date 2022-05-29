import Foundation
import CoreFoundationLib

class DuplicateBillOperative: BillOperative {
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
        return .duplicateBill
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
        add(step: factory.createStep() as OperativeSimpleSignature)
        add(step: factory.createStep() as OperativeSummary)
    }
    
    func performSetup(for delegate: OperativeLauncherPresentationDelegate, container: OperativeContainerProtocol, success: @escaping () -> Void) {
        let operativeData: DuplicateBillOperativeData = container.provideParameter()
        let input = SetupDuplicateBillUseCaseInput(bill: operativeData.bill)
        let usecase = dependencies.useCaseProvider.getSetupDuplicateBillUseCase(input: input)
        UseCaseWrapper(
            with: usecase,
            useCaseHandler: dependencies.useCaseHandler,
            errorHandler: delegate.errorOperativeHandler,
            onSuccess: { result in
                operativeData.update(account: result.account, duplicateBill: result.duplicateBill)
                container.saveParameter(parameter: result.duplicateBill.signature)
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
        let signatureFilled: SignatureFilled<Signature> = container.provideParameter()
        let parameter: DuplicateBillOperativeData = containerParameter()
        guard let account = parameter.account else { return }
        let input = ConfirmDuplicateBillUseCaseInput(bill: parameter.bill, account: account, signature: signatureFilled.signature)
        let useCase = dependencies.useCaseProvider.getConfirmDuplicateBillUseCase(input: input)
        UseCaseWrapper(with: useCase, useCaseHandler: dependencies.useCaseHandler, errorHandler: presenter, onSuccess: { _ in
            completion(true, nil)
        }, onError: { error in
            completion(false, error)
        })
    }
    
    func getSummaryTitle() -> LocalizedStylableText {
        let parameter: DuplicateBillOperativeData = containerParameter()
        switch parameter.bill.type {
        case .receipt:
            return dependencies.stringLoader.getString("summary_title_duplicateOfReceipt")
        case .tax:
            return dependencies.stringLoader.getString("summary_title_duplicateOfTaxes")
        }
    }
    
    func getSummarySubtitle() -> LocalizedStylableText? {
        return nil
    }
    
    func getSummaryInfo() -> [SummaryItemData]? {
        let parameter: DuplicateBillOperativeData = containerParameter()
        guard let account = parameter.account, let duplicateBill = parameter.duplicateBill else { return nil }
        let bill = parameter.bill
        return [
            SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_amount"), value: bill.amountWithSymbol.getAbsFormattedAmountUI()),
            SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_concept"), value: duplicateBill.concept?.capitalizingFirstLetter() ?? ""),
            SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_authorisationReference"), value: duplicateBill.reference ?? ""),
            SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_EntityIssuing"), value: bill.name.capitalizingFirstLetter()),
            SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_code"), value: bill.issuerCode),
            SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_status"), value: dependencies.stringLoader.getString(bill.status.key ?? "").text),
            SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_holder"), value: bill.holder.capitalizingFirstLetter()),
            SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_chargeAccount"), value: account.getAliasAndInfo()),
            SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_datePayment"), value: dependencies.timeManager.toString(date: duplicateBill.datePayment, outputFormat: .d_MMM_yyyy) ?? "")
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
        return TrackerPagePrivate.DuplicateBillSignature().page
    }
    
    var screenIdSummary: String? {
        return TrackerPagePrivate.DuplicateBillSummary().page
    }
    
    func getTrackParametersSummary() -> [String: String]? {
        return nil
    }
}
