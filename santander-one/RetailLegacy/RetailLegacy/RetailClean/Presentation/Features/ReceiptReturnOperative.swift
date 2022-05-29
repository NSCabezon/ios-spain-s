import Foundation
import CoreFoundationLib

class ReceiptReturnOperative: BillOperative {
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
        return .receiptReturn
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
        let operativeData: ReceiptReturnOperativeData = container.provideParameter()
        let input = SetupReceiptReturnUseCaseInput(bill: operativeData.bill)
        let usecase = dependencies.useCaseProvider.getSetupReceiptReturnUseCase(input: input)
        UseCaseWrapper(
            with: usecase,
            useCaseHandler: dependencies.useCaseHandler,
            errorHandler: delegate.errorOperativeHandler,
            onSuccess: { result in
                operativeData.update(account: result.account, detailBill: result.billDetail)
                container.saveParameter(parameter: operativeData.detailBill.signature)
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
        let parameter: ReceiptReturnOperativeData = containerParameter()
        guard let account = parameter.account else { return }
        let input = ConfirmReceiptReturnUseCaseInput(bill: parameter.bill, detailBill: parameter.detailBill, account: account, signature: signatureFilled.signature)
        let useCase = dependencies.useCaseProvider.getConfirmReceiptReturnUseCase(input: input)
        UseCaseWrapper(with: useCase, useCaseHandler: dependencies.useCaseHandler, errorHandler: presenter, onSuccess: { _ in
            completion(true, nil)
        }, onError: { error in
            completion(false, error)
        })
    }
    
    func getSummaryTitle() -> LocalizedStylableText {
        return dependencies.stringLoader.getString("summary_title_returnedReceiptSuccess")
    }
    
    func getSummarySubtitle() -> LocalizedStylableText? {
        return nil
    }
    
    func getSummaryInfo() -> [SummaryItemData]? {
        let parameter: ReceiptReturnOperativeData = containerParameter()
        guard let account = parameter.account else { return nil }
        let bill = parameter.bill
        let detailBill = parameter.detailBill
        return [
            SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_receipt"), value: detailBill.reference),
            SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_holder"), value: bill.holder),
            SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_chargeAccount"), value: account.getAliasAndInfo()),
            SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_expirationDate"), value: dependencies.timeManager.toString(date: detailBill.chargeDate, outputFormat: .d_MMM_yyyy) ?? ""),
            SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_authorisationReference"), value: detailBill.mandateReference),
            SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_EntityIssuing"), value: bill.name.capitalizingFirstLetter()),
            SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_code"), value: bill.issuerCode),
            SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_amount"), value: bill.amountWithSymbol.getAbsFormattedAmountUI()),
            SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_concept"), value: detailBill.concept?.capitalizingFirstLetter() ?? "")
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
        return TrackerPagePrivate.ReceiptReturnSignature().page
    }
    
    var screenIdSummary: String? {
        return TrackerPagePrivate.ReceiptReturnSummary().page
    }
    
    func getTrackParametersSummary() -> [String: String]? {
        return nil
    }
}
