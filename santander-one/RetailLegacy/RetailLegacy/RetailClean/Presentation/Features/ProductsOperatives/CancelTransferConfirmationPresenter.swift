import CoreFoundationLib

class CancelTransferConfirmationPresenter: PrivatePresenter<CancelTransferConfirmationViewController, CancelTransferConfirmationNavigatorProtocol, CancelTransferConfirmationPresenterProtocol> {
    
    private let scheduledTransfer: TransferScheduled
    private let scheduledTransferDetail: ScheduledTransferDetail
    private let account: Account
    
    override var shouldRegisterAsDeeplinkHandler: Bool {
        return false
    }
    
    override var screenId: String? {
        return TrackerPagePrivate.CancelScheduledTransferConfirmation().page
    }
    
    override func getTrackParameters() -> [String: String]? {
        return [
            TrackerDimensions.scheduledTransferType: scheduledTransfer.periodicTrackerDescription
        ]
    }
    
    private weak var operativeDelegate: OperativeLauncherDelegate?
    
    init(transferScheduled: TransferScheduled, scheduledTransferDetail: ScheduledTransferDetail, account: Account, operativeDelegate: OperativeLauncherDelegate, dependencies: PresentationComponent, sessionManager: CoreSessionManager, navigator: CancelTransferConfirmationNavigatorProtocol) {
        self.scheduledTransfer = transferScheduled
        self.scheduledTransferDetail = scheduledTransferDetail
        self.account = account
        self.operativeDelegate = operativeDelegate
        super.init(dependencies: dependencies, sessionManager: sessionManager, navigator: navigator)
    }
    
    override func loadViewData() {
        super.loadViewData()
        
        if scheduledTransfer.isPeriodic {
            view.alertTitle = stringLoader.getString("periodicOnePay_label_cancelPeriodic")
        } else {
            view.alertTitle = stringLoader.getString("delayedOnePay_label_cancelOnePay")
        }
        
        view.summaryInfo = getSummaryItems(from: getDataInfo())
        
        view.configure(cancelWithTitle: stringLoader.getString("generic_button_cancel"))
        
        view.configure(confirmWithTitle: stringLoader.getString("generic_buttom_delete"))
        
    }
    
    private func getSummaryItems(from info: [SummaryItemData]) -> [SummaryItem] {
        return info.map { $0.createSummaryItem() }
    }
    
    private func getDataInfo() -> [SummaryItemData] {
        var data: [SummaryItemData] = []
        
        data.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_amount"), value: scheduledTransfer.amount?.getFormattedAmountUI() ?? ""))
        
        let concept: String
        if let transferConcept = scheduledTransfer.concept, !transferConcept.isEmpty {
            concept = transferConcept
        } else {
            concept = dependencies.stringLoader.getString("onePay_label_genericProgrammed").text
        }
        
        data.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_concept"), value: concept))
        data.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_periodicity"), value: dependencies.stringLoader.getString(scheduledTransfer.keyForPeriodicalType).text))
        
        if scheduledTransfer.isPeriodic {
            if let date = dependencies.timeManager.toString(date: scheduledTransferDetail.nextExecutionDate, outputFormat: .dd_MMM_yyyy) {
                data.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_nextIssuanceDate"), value: date))
            }
            
            data.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_endDate"), value: dependencies.timeManager.toString(date: scheduledTransferDetail.endDate, outputFormat: .dd_MMM_yyyy) ?? dependencies.stringLoader.getString("confirmation_label_indefinite").text ))
            
        } else {
            data.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_issuanceDate"), value: dependencies.timeManager.toString(date: scheduledTransferDetail.nextExecutionDate, outputFormat: .dd_MMM_yyyy) ?? "" ))
            
        }
        
        data.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_beneficiary"), value: scheduledTransferDetail.beneficiaryName ?? ""))
        
        return data
    }
    
}

extension CancelTransferConfirmationPresenter: CancelTransferConfirmationPresenterProtocol {
    func cancelButtonTouched() {
        navigator.dismiss(completion: nil)
    }
    
    func confirmButtonTouched() {
        navigator.dismiss(completion: { [weak self] in
            self?.startCancelTransferOperative(transferScheduled: self?.scheduledTransfer, account: self?.account, scheduledTransferDetail: self?.scheduledTransferDetail, delegate: self?.operativeDelegate)
        })
    }
    
}

extension CancelTransferConfirmationPresenter: OperativeLauncherPresentationDelegate {
    func startOperativeLoading(completion: @escaping () -> Void) {
        let type = LoadingViewType.onScreen(controller: view, completion: completion)
        let text = LoadingText(title: localized(key: "generic_popup_loading"), subtitle: localized(key: "loading_label_moment"))
        let info = LoadingInfo(type: type, loadingText: text, placeholders: nil, topInset: nil)
        showLoading(info: info)
    }
    
    func hideOperativeLoading(completion: @escaping () -> Void) {
        hideLoading(completion: completion)
    }
    
    func showOperativeAlert(title: LocalizedStylableText?, body message: LocalizedStylableText, withAcceptComponent accept: DialogButtonComponents, withCancelComponent cancel: DialogButtonComponents?) {
        Dialog.alert(title: title, body: message, withAcceptComponent: accept, withCancelComponent: cancel, source: view)
    }
    
    func showOperativeAlertError(keyTitle: String?, keyDesc: String?, completion: (() -> Void)?) {
        showError(keyTitle: keyTitle, keyDesc: keyDesc, phone: nil, completion: completion)
    }
    
    var errorOperativeHandler: GenericPresenterErrorHandler {
        return genericErrorHandler
    }
}

extension CancelTransferConfirmationPresenter: CancelTransferLauncher {}
