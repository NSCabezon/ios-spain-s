//

import Foundation

class InternalPeriodicTransferConfirmationPresenter: OperativeStepPresenter<InternalTransferConfirmationViewController, VoidNavigator, InternalTransferConfirmationPresenterProtocol> {
    
    // MARK: - Overrided methods
    
    override func loadViewData() {
        super.loadViewData()
        view.styledTitle = dependencies.stringLoader.getString("genericToolbar_title_confirmation")
        let parameter: InternalTransferOperativeData = containerParameter()
        guard let internalTransfer: InternalTransfer = parameter.internalTransfer else { return }
        guard let originAccount = internalTransfer.originAccount else { return }
        
        // Add account section
        let accountSection = TableModelViewSection()
        addAccount(originAccount, to: accountSection)
        
        // Add confimration items
        let confirmationSection = TableModelViewSection()
        addConfirmation(of: internalTransfer, to: confirmationSection)
        self.view.sections = [accountSection, confirmationSection]
    }
    
    override var screenId: String? {
        return TrackerPagePrivate.InternalTransferConfirmation().page
    }
    
    override func getTrackParameters() -> [String: String]? {
        let parameter: InternalTransferOperativeData = containerParameter()
        return [TrackerDimensions.scheduledTransferType: parameter.time?.trackerDescription ?? ""]
    }
    
    // MARK: - Private methods
   private func periodicity(_ time: OnePayTransferTime) -> ConfirmationTableViewItemModel {
        let periodicity: String
        //let parameter: InternalTransferOperativeData = containerParameter()
        switch time {
        case .periodic(_, _, let periodicityValue, _):
            switch periodicityValue {
            case .monthly: periodicity = dependencies.stringLoader.getString("confirmation_label_monthly").text
            case .quarterly: periodicity = dependencies.stringLoader.getString("confirmation_label_quarterly").text
            case .biannual: periodicity = dependencies.stringLoader.getString("confirmation_label_biannual").text
            case .weekly: periodicity = dependencies.stringLoader.getString("confirmation_label_weekly").text
            case .bimonthly: periodicity = dependencies.stringLoader.getString("confirmation_label_bimonthly").text
            case .annual: periodicity = dependencies.stringLoader.getString("confirmation_label_annual").text
        }
        default:
            periodicity = dependencies.stringLoader.getString("summary_label_standar").text
        }
        return ConfirmationTableViewItemModel(dependencies.stringLoader.getString("confirmation_item_periodicity"), dependencies.stringLoader.getString(periodicity).text, false, dependencies, .normal)
    }
    
    private func addEndDate(_ time: OnePayTransferTime) -> ConfirmationTableViewItemModel {
        let issueDate: String
        switch time {
        case .periodic(_, let endDate, _, _):
            switch endDate {
            case .never:
                issueDate = dependencies.stringLoader.getString("confirmation_label_indefinite").text
            case .date(let endDate):
                issueDate = dependencies.timeManager.toString(date: endDate, outputFormat: .dd_MMM_yyyy) ?? ""
            }
        default:
            issueDate = ""
        }
        return ConfirmationTableViewItemModel(dependencies.stringLoader.getString("confirmation_item_endDate"), issueDate, false, dependencies, .normal)
    }
    
    private func addAccount(_ account: Account, to accountSection: TableModelViewSection) {
        let accountItem = AccountConfirmationViewModel(
            accountName: account.getAlias() ?? stringLoader.getString("generic_confirm_associatedAccount").text,
            ibanNumber: account.getIBANShort(),
            amount: account.getAmountUI(),
            privateComponent: dependencies
        )
        let accountTitle = TitledTableModelViewHeader()
        accountTitle.title = stringLoader.getString("confirmation_label_originAccount")
        accountSection.setHeader(modelViewHeader: accountTitle)
        accountSection.add(item: accountItem)
    }
    
    private func addConfirmation(of internalTransfer: InternalTransfer, to confirmationSection: TableModelViewSection) {
        let parameter: InternalTransferOperativeData = containerParameter()
        guard let amount = internalTransfer.amount, let destinationAccount = internalTransfer.destinationAccount, let time = parameter.time else { return }
        guard let transferAccount: TransferAccount = parameter.transferAccount else { return }
        let title = TitledTableModelViewHeader()
        title.title = stringLoader.getString("transfer_label_transferBetweenAccounts")
        confirmationSection.setHeader(modelViewHeader: title)
        
        var concept: String = dependencies.stringLoader.getString("onePay_label_notConcept").text
        
        if let updateConcept = internalTransfer.concept, !updateConcept.isEmpty {
            concept = updateConcept
        }
        
        let accountTransferHeader = TransferAccountHeaderViewModel(dependencies: dependencies, amount: amount, destinationAccount: destinationAccount, concept: concept)
        confirmationSection.add(item: accountTransferHeader)
        let items = [
            periodicity(time),
            ConfirmationTableViewItemModel(stringLoader.getString("confirmation_item_startDate"), dependencies.timeManager.toString(date: transferAccount.issueDate, outputFormat: .dd_MMM_yyyy) ?? "", false, dependencies, .normal),
            addEndDate(time),
           ConfirmationTableViewItemModel(stringLoader.getString("confirmation_item_commission"), transferAccount.netAmount.getAbsFormattedAmountUI(), true, dependencies, .normal)
        ]
        confirmationSection.addAll(items: items)
    }
}

extension InternalPeriodicTransferConfirmationPresenter: InternalTransferConfirmationPresenterProtocol {
    
    var continueTitle: LocalizedStylableText {
        return dependencies.stringLoader.getString("generic_button_confirm")
    }
    
    func next() {
        let parameter: InternalTransferOperativeData = containerParameter()
        guard let internalTransfer: InternalTransfer = parameter.internalTransfer, let time = parameter.time else { return }
        guard
            let originAccount = internalTransfer.originAccount,
            let destinationAccount = internalTransfer.destinationAccount,
            let amount = internalTransfer.amount
            else {
                return
        }
        let validateData = ValidateLocalTransferUseCaseInput(
            originAccount: originAccount,
            destinationAccount: destinationAccount,
            amount: amount,
            concept: internalTransfer.concept ?? dependencies.stringLoader.getString("onePay_label_genericProgrammed").text,
            transferTime: time,
            scheduledTransfer: parameter.scheduledTransfer
        )
        showOperativeLoading(titleToUse: nil, subtitleToUse: nil, source: nil)
        UseCaseWrapper(
            with: dependencies.useCaseProvider.getValidateLocalTransferUseCase(input: validateData),
            useCaseHandler: dependencies.useCaseHandler,
            errorHandler: genericErrorHandler,
            onSuccess: { [weak self] response in
                self?.hideAllLoadings {
                    guard let strongSelf = self else { return }
                    strongSelf.container?.saveParameter(parameter: response.transferAccount.signature)
                    strongSelf.container?.stepFinished(presenter: strongSelf)
                }
            },
            onError: { [weak self] error in
                self?.hideLoading()
                self?.showError(keyDesc: error?.getErrorDesc())
            }
        )
    }
    
    func trackFaqEvent(_ question: String, url: URL?) {
        var dic: [String: String] = ["faq_question":question]
        if let link = url?.absoluteString {
            dic["faq_link"] = link
        }
        NotificationCenter.default.post(name: .transfersFaqsAnalytics, object: nil, userInfo: ["parameters": dic])
    }
}
