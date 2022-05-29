import Foundation
import CoreFoundationLib

class BillDetailProfile: BaseTransactionDetailProfile<GetBillAndTaxesDetailUseCaseInput, GetBillAndTaxesDetailUseCaseOkOutput, GetBillAndTaxesDetailUseCaseErrorOutput>, TransactionDetailProfile {

    var screenId: String? {
        return TrackerPagePrivate.BillAndTaxesTransactionDetail().page
    }
    
    var useCaseProvider: UseCaseProvider {
        return dependencies.useCaseProvider
    }
    var useCaseHandler: UseCaseHandler {
        return dependencies.useCaseHandler
    }
    
    private var bill: Bill? {
        return (transaction as? BillAndAccount)?.bill
    }
    
    private var account: Account? {
        return (transaction as? BillAndAccount)?.account
    }
    
    var title: String? {
        return bill?.name.camelCasedString
    }
    
    var alias: String? {
        return account?.getAlias()
    }
    
    var amount: String? {
        return bill?.amountWithSymbol.getFormattedAmountUIWith1M()
    }
    
    var showSeePdf: Bool? {
        return true
    }
    
    var titleLeft: LocalizedStylableText? {
        return dependencies.stringLoader.getString("transaction_label_operationDate")
    }
    
    var infoLeft: String? {
        let operationDate = bill?.expirationDate
        return dependencies.timeManager.toString(date: operationDate, outputFormat: .d_MMM_yyyy)
    }
    
    var titleRight: LocalizedStylableText? {
        return dependencies.stringLoader.getString("transaction_label_valueDate")
    }
    
    var infoRight: String? {
        let paymentDate = bill?.paymentDate
        return dependencies.timeManager.toString(date: paymentDate, outputFormat: .d_MMM_yyyy)
    }
    
    var singleInfoTitle: LocalizedStylableText? {
        return dependencies.stringLoader.getString("transaction_label_balance")
    }
    
    var balance: String? {
        guard let transaction = transaction as? AccountTransaction else { return nil }
        return transaction.balance.getFormattedAmountUIWith1M()
    }
    
    var showLoading: Bool? {
        return true
    }
    
    var showActions: Bool? {
        return true
    }
    
    var showShare: Bool? {
        return true
    }
    
    var navigationTitleKey: String {
        return "toolbar_title_detailReceipt"
    }

    private var isChangeDirectDebitEnabled: Bool = false
    
    override func actions(withProductConfig productConfig: ProductConfig) {
        makeActionsIfPosible(productConfig: productConfig)
    }
    
    private func makeActionsIfPosible(productConfig: ProductConfig) {
        var actions = [TransactionDetailActionType]()
        addDuplicateOptionIn(productConfig: productConfig, actions: &actions)
        addDebitOptionIn(productConfig: productConfig, actions: &actions)
        addCancelDebitOptionIn(productConfig: productConfig, actions: &actions)
        addReturnReceiptOptionIn(productConfig: productConfig, actions: &actions)
        
        completionActions?(actions)
    }
    
    override func useCaseForTransactionDetail<Input, Response, Error: StringErrorOutput>() -> UseCase<Input, Response, Error>? {
        guard let bill = bill, let account = account else {
            return nil
        }
        let input = GetBillAndTaxesDetailUseCaseInput(bill: bill, account: account)
        return dependencies.useCaseProvider.getBillAndTaxesDetailUseCase(input: input) as? UseCase<Input, Response, Error>
    }
    
    override func requestActions() {
        if let bill = bill {
            let input = CheckerChangeDirectDebitUseCaseInput(bill: bill)
            UseCaseWrapper(with: dependencies.useCaseProvider.getCheckerChangeDirectDebitUseCase(input: input), useCaseHandler: dependencies.useCaseHandler, errorHandler: errorHandler, onSuccess: { [weak self] _ in
                self?.isChangeDirectDebitEnabled = true
                if let productConfig = self?.productConfig {
                    self?.makeActionsIfPosible(productConfig: productConfig)
                }
            }, onError: { [weak self] _ in
                self?.isChangeDirectDebitEnabled = false
                if let productConfig = self?.productConfig {
                    self?.makeActionsIfPosible(productConfig: productConfig)
                }
            })
        }
        super.requestActions()
    }
    
    override func transactionDetailFrom(response: GetBillAndTaxesDetailUseCaseOkOutput) -> GenericTransactionProtocol? {
        productDetail = response.billDetail
        requestActions()
        return response.billDetail
    }
    
    var nonDetailRowsToAppend: [TransactionLine]? {
        guard let availableBalance = account?.getAvailableAmount()?.getFormattedAmountUI(), let currentBalance = account?.currentBalance?.getFormattedAmountUI() else {
            return []
        }
        let available = (dependencies.stringLoader.getString("transaction_label_availableBalance"), availableBalance)
        let current = (dependencies.stringLoader.getString("transaction_label_realBalance"), currentBalance)

        return [(available, current)]
    }
    
    override func getInfoFromTransactionDetail(transactionDetail: GenericTransactionProtocol) -> [TransactionLine]? {
        guard let bill = bill, let billDetail = transactionDetail as? BillDetail else {
            return []
        }
        let issuerName = (dependencies.stringLoader.getString("transaction_label_holder"), bill.holder.camelCasedString)
        let issuerCode = (dependencies.stringLoader.getString("transaction_label_codeIssuingEntity"), bill.issuerCode)
        let reference = (dependencies.stringLoader.getString("transaction_label_reference"), billDetail.reference)
        let status = (dependencies.stringLoader.getString("transaction_label_statusDetail"), billDetail.statusDescription.capitalizingFirstLetter())
        
        shareableInfo = [(issuerName, nil), (issuerCode, nil), (reference, nil), (status, nil)]
        
        return shareableInfo
    }
    
    func stringToShare() -> String? {
        var stringToShare = ""
        if let title = title {
            stringToShare.append("\(title)\n")
        }
        if let amount = amount {
            let titleAmount = dependencies.stringLoader.getString("summary_item_quantity").text
            stringToShare.append("\(titleAmount) \(amount)\n")
        }
        if let titleLeft = titleLeft, let infoLeft = infoLeft {
            stringToShare.append("\(titleLeft.text) \(infoLeft)\n")
        }
        
        if let titleRight = titleRight, let infoRight = infoRight {
            stringToShare.append("\(titleRight.text) \(infoRight)\n")
        }
        
        if let singleInfoTitle = singleInfoTitle, let balance = balance {
            stringToShare.append("\(singleInfoTitle.text) \(balance)\n")
        }
        
        for line in shareableInfo {
            stringToShare.append("\(line.0.title.text) \(line.0.info)\n")
            if let second = line.1 {
                stringToShare.append("\(second.title.text) \(second.info)\n")
            }
        }
        
        return stringToShare
    }
    
    func seePDFDidTouched(completion: @escaping (Data?, StringErrorOutput?, PdfSource) -> Void) {
        guard let bill = self.bill else {
            return
        }
        let input = DownloadPdfBillUseCaseInput(bill: bill)
        let useCase = dependencies.useCaseProvider.downloadPdfBillUseCase(input: input)
        UseCaseWrapper(with: useCase, useCaseHandler: dependencies.useCaseHandler, errorHandler: errorHandler, onSuccess: { [weak self] response in
            guard let strongSelf = self else { return }
            strongSelf.dependencies.trackerManager.trackScreen(screenId: TrackerPagePrivate.BillAndTaxesTransactionDetailPdf().page, extraParameters: [:])
            completion(response.document, nil, PdfSource.bill)
        }, onError: { error in
            completion(nil, error, PdfSource.bill)
        })
    }
    
}

extension BillDetailProfile {

    fileprivate func addDuplicateOptionIn(productConfig: ProductConfig, actions: inout [TransactionDetailActionType]) {
        let transfersOption = TransactionDetailAction(title: dependencies.stringLoader.getString("transaction_buttonOption_requestDuplicate")) { [weak self ] in
            guard
                let bill = self?.bill,
                let transactionDetailManager = self?.transactionDetailManager
            else { return }
            self?.showDuplicateBill(bill: bill, delegate: transactionDetailManager)
        }

        actions.append(transfersOption)
    }
    
    fileprivate func addDebitOptionIn(productConfig: ProductConfig, actions: inout [TransactionDetailActionType]) {
        guard self.productDetail != nil, isChangeDirectDebitEnabled else {
            return
        }
        let transfersOption = TransactionDetailAction(title: dependencies.stringLoader.getString("transaction_buttonOption_domicileOtherAccount")) {
            guard
                let bill = self.bill,
                let billDetail = self.productDetail as? BillDetail,
                let delegate = self.transactionDetailManager
            else { return }
            self.showChangeDirectDebit(bill: bill, billDetail: billDetail, delegate: delegate)
        }
        actions.append(transfersOption)
    }
    
    fileprivate func addCancelDebitOptionIn(productConfig: ProductConfig, actions: inout [TransactionDetailActionType]) {
        guard productDetail != nil else {
            return
        }
        let transfersOption = TransactionDetailAction(title: dependencies.stringLoader.getString("transaction_buttonOption_cancelReceipt")) { [weak self] in
            guard
                let bill = self?.bill,
                let transactionDetailManager = self?.transactionDetailManager,
                let productDetail = self?.productDetail as? BillDetail
            else { return }
            self?.showCancelDirectBilling(bill: bill, billDetail: productDetail, delegate: transactionDetailManager)
        }
        actions.append(transfersOption)
    }
    
    fileprivate func addReturnReceiptOptionIn(productConfig: ProductConfig, actions: inout [TransactionDetailActionType]) {
        guard productDetail != nil, let bill = bill else {
            return
        }
        let status = bill.status
        guard status != .unknown, status != .canceled, status != .returned else {
            return
        }
        let transfersOption = TransactionDetailAction(title: dependencies.stringLoader.getString("transaction_buttonOption_returnedReceipt")) { [weak self] in
            guard
                let bill = self?.bill,
                let transactionDetailManager = self?.transactionDetailManager,
                let productDetail = self?.productDetail as? BillDetail
            else { return} 
            self?.receiptReturnAction(bill: bill,
                                      billDetail: productDetail,
                                      transactionDetailManager: transactionDetailManager,
                                      delegate: transactionDetailManager)
        }
        actions.append(transfersOption)
    }
    
    fileprivate func receiptReturnAction(bill: Bill,
                                         billDetail: BillDetail,
                                         transactionDetailManager: ProductLauncherOptionsPresentationDelegate,
                                         delegate: OperativeLauncherDelegate) {
        let useCase = useCaseProvider.getGetInsurancBillEmittersUseCase()
        Scenario(useCase: useCase).execute(on: useCaseHandler)
            .onSuccess { output in
                if output.insuranceBillEmitters.contains(billDetail.sourceNIFSurf.trimed) {
                    transactionDetailManager.showBillInsuranceEmitterPrompt {
                        self.showReceiptReturn(bill: bill, billDetail: billDetail, delegate: delegate)
                    }
                } else {
                    self.showReceiptReturn(bill: bill, billDetail: billDetail, delegate: delegate)
                }
            }
    }
}

extension BillDetailProfile: ChangeDirectDebitOperativeLauncher {}
extension BillDetailProfile: ReceiptReturnOperativeLauncher {}
extension BillDetailProfile: DuplicateBillOperativeLauncher {}
extension BillDetailProfile: CancelDirectBillingLauncher {}
