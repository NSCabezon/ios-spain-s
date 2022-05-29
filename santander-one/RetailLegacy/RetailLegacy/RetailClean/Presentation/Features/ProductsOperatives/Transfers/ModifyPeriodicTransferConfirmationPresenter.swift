import CoreFoundationLib
import UIKit

//NOTE: TransferConfirmationNoSepaViewController and TransferConfirmationNSPresenterProtocol are the old TransferConfirmationViewController, pending to migrate at modules
class ModifyPeriodicTransferConfirmationPresenter: OperativeStepPresenter<TransferConfirmationNoSepaViewController, VoidNavigator, TransferConfirmationNSPresenterProtocol> {
    
    override func loadViewData() {
        super.loadViewData()
        loadTracker()
        view.update(title: dependencies.stringLoader.getString("genericToolbar_title_confirmation"))
        view.updateButton(title: stringLoader.getString("generic_button_confirm"))

        let parameter: ModifyPeriodicTransferOperativeData = containerParameter()
        let originAccount = parameter.account
        // Add account section
        let accountSection = TableModelViewSection()
        addAccount(originAccount, to: accountSection)
        // Add confirmation items
        let confirmationSection = TableModelViewSection()
        addConfirmation(to: confirmationSection)
        
        let footerSection = TableModelViewSection()
        addFooterSection(to: footerSection)
        
        self.view.sections = [accountSection, confirmationSection, footerSection]
    }
    
    func loadTracker() {
        let parameter: ModifyPeriodicTransferOperativeData = containerParameter()
        dependencies.trackerManager.trackScreen(
            screenId: TrackerPagePrivate.ModifyScheduledTransferConfirmation().page,
            extraParameters: [
                TrackerDimensions.scheduledTransferType: parameter.transferScheduled.periodicTrackerDescription
            ]
        )
    }
    
    // MARK: Visual presentation
    // Head section
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
    
    // Body section
    private func addConfirmation(to confirmationSection: TableModelViewSection) {
        let parameter: ModifyPeriodicTransferOperativeData = containerParameter()
        guard let modifiedData = parameter.modifiedData else { return }
        let title = TitledTableModelViewHeader()
        title.title = stringLoader.getString("confirmation_label_standardProgrammedSend")
        
        // Title
        confirmationSection.setHeader(modelViewHeader: title)
        
        // Cells associated to periodic detail
        addTransferInformation(operativeData: parameter, to: confirmationSection)
        let beneficiary = ConfirmationTableViewItemModel(stringLoader.getString("confirmation_item_beneficiary"), parameter.scheduledTransferDetail.beneficiaryName ?? "", false, dependencies, .normal)
        confirmationSection.add(item: beneficiary)
        let sourceCountry = ConfirmationTableViewItemModel(stringLoader.getString("confirmation_item_destinationCountry"), parameter.country?.name ?? "", false, dependencies, .normal)
        confirmationSection.add(item: sourceCountry)
        let currency = ConfirmationTableViewItemModel(stringLoader.getString("confirmation_item_currency"), parameter.currency?.name ?? "", false, dependencies, .normal)
        confirmationSection.add(item: currency)
        let periodicity = ConfirmationTableViewItemModel(stringLoader.getString("confirmation_item_periodicity"), stringLoader.getString(modifiedData.periodicity.description).text, false, dependencies, .normal)
        confirmationSection.add(item: periodicity)
        let initDate = ConfirmationTableViewItemModel(stringLoader.getString("confirmation_item_startDate"), dependencies.timeManager.toString(date: modifiedData.startDate, outputFormat: TimeFormat.d_MMM_yyyy) ?? "", false, dependencies, .normal)
        confirmationSection.add(item: initDate)
        switch modifiedData.endDate {
        case .never:
            let endDate = ConfirmationTableViewItemModel(stringLoader.getString("confirmation_item_endDate"), dependencies.stringLoader.getString("confirmation_label_indefinite").text, true, dependencies, .normal)
            confirmationSection.add(item: endDate)
        case .date(let date):
            let endDate = ConfirmationTableViewItemModel(stringLoader.getString("confirmation_item_endDate"), dependencies.timeManager.toString(date: date, outputFormat: TimeFormat.d_MMM_yyyy) ?? "", true, dependencies, .normal)
            confirmationSection.add(item: endDate)
        }
    }
    
    // Header second section
    private func addTransferInformation(operativeData: ModifyPeriodicTransferOperativeData, to confirmationSection: TableModelViewSection) {
        let parameter: ModifyPeriodicTransferOperativeData = containerParameter()
        guard let destinationAccountIBAN = parameter.modifiedData?.iban, let transferAmount = parameter.modifiedData?.amount else { return }
        
        let concept: String
        if let transferConcept = operativeData.modifiedData?.concept, !transferConcept.isEmpty {
            concept = transferConcept
        } else {
            concept = dependencies.stringLoader.getString("onePay_label_genericProgrammed").text
        }
        
        let accountTransferHeader = TransferAccountHeaderViewModel(
            dependencies: dependencies,
            amount: transferAmount.getAbsFormattedAmountUI(),
            destinationAccount: destinationAccountIBAN.formatted,
            concept: concept
        )
        confirmationSection.add(item: accountTransferHeader)
    }
    
    private func addFooterSection(to footSection: TableModelViewSection) {
        let foot = ClearLabelTableModelView(title: stringLoader.getString("confirmation_item_onePayCommission"), style: LabelStylist(textColor: .sanGreyMedium, font: UIFont.latoMedium(size: 14), textAlignment: .center), insets: Insets(left: 16, right: 12, top: 16, bottom: 16), privateComponent: dependencies)
        footSection.add(item: foot)
    }
}

extension ModifyPeriodicTransferConfirmationPresenter: TransferConfirmationNSPresenterProtocol {
    func onContinueButtonClicked() {
        let parameter: ModifyPeriodicTransferOperativeData = containerParameter()
        let input = ModifyPeriodicTransferUseCaseInput(
            account: parameter.account,
            scheduledTransfer: parameter.transferScheduled,
            scheduledTransferDetail: parameter.scheduledTransferDetail
        )
        showOperativeLoading(titleToUse: nil, subtitleToUse: nil, source: nil)
        UseCaseWrapper(
            with: dependencies.useCaseProvider.getModifyPeriodicTransferUseCase(input: input),
            useCaseHandler: useCaseHandler,
            errorHandler: genericErrorHandler,
            onSuccess: { [weak self] response in
                self?.hideAllLoadings { [weak self] in
                    guard let strongSelf = self else { return }
                    parameter.modifyPeriodicTransfer = response.modifyPeriodicTransfer
                    strongSelf.container?.saveParameter(parameter: parameter)
                    strongSelf.container?.saveParameter(parameter: response.signature)
                    strongSelf.container?.stepFinished(presenter: strongSelf)
                }
            },
            onError: { [weak self] error in
                self?.hideAllLoadings { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.showError(keyTitle: "generic_alert_title_errorData", keyDesc: error?.getErrorDesc())
                }
            }
        )
    }
}
