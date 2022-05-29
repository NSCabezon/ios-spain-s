import CoreFoundationLib
import UIKit

//NOTE: TransferConfirmationNoSepaViewController and TransferConfirmationNSPresenterProtocol are the old TransferConfirmationViewController, pending to migrate at modules
class ModifyDeferredTransferConfirmationPresenter: OperativeStepPresenter<TransferConfirmationNoSepaViewController, VoidNavigator, TransferConfirmationNSPresenterProtocol> {
    override func loadViewData() {
        super.loadViewData()
        loadTracker()
        view.update(title: dependencies.stringLoader.getString("genericToolbar_title_confirmation"))
        view.updateButton(title: stringLoader.getString("generic_button_confirm"))
        
        let parameter: ModifyDeferredTransferOperativeData = containerParameter()
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
        let parameter: ModifyDeferredTransferOperativeData = containerParameter()
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
        let parameter: ModifyDeferredTransferOperativeData = containerParameter()
        
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
        let periodicity = ConfirmationTableViewItemModel(stringLoader.getString("confirmation_item_periodicity"), stringLoader.getString(parameter.transferScheduled.keyForPeriodicalType).text, false, dependencies, .normal)
        confirmationSection.add(item: periodicity)
        let emissionDate = ConfirmationTableViewItemModel(stringLoader.getString("confirmation_item_issuanceDate"), dependencies.timeManager.toString(date: parameter.modifiedData?.date, outputFormat: TimeFormat.d_MMM_yyyy) ?? "", false, dependencies, .normal)
        confirmationSection.add(item: emissionDate)
        //TODO: Falta la comisión. No especificado por el banco en estos momentos
        let comission = ConfirmationTableViewItemModel(stringLoader.getString("confirmation_item_commission"), Amount.zero().getFormattedAmountUI(2), true, dependencies, .normal)
        confirmationSection.add(item: comission)
    }
    
    // Header second section
    private func addTransferInformation(operativeData: ModifyDeferredTransferOperativeData, to confirmationSection: TableModelViewSection) {
        guard let destinationAccountIBAN = operativeData.modifiedData?.iban else { return }
        let transferAmount = operativeData.modifiedData?.amount.getAbsFormattedAmountUI() ?? ""
        
        let concept: String
        if let transferConcept = operativeData.modifiedData?.concept, !transferConcept.isEmpty {
            concept = transferConcept
        } else {
            concept = dependencies.stringLoader.getString("onePay_label_genericProgrammed").text
        }
        
        let accountTransferHeader = TransferAccountHeaderViewModel(
            dependencies: dependencies,
            amount: transferAmount,
            destinationAccount: destinationAccountIBAN.description,
            concept: concept
        )
        confirmationSection.add(item: accountTransferHeader)
    }
    
    private func addFooterSection(to footSection: TableModelViewSection) {
        let foot = ClearLabelTableModelView(title: stringLoader.getString("confirmation_item_onePayCommission"), style: LabelStylist(textColor: .sanGreyMedium, font: UIFont.latoMedium(size: 14), textAlignment: .center), insets: Insets(left: 16, right: 16, top: 16, bottom: 16), privateComponent: dependencies)
        footSection.add(item: foot)
    }
}

extension ModifyDeferredTransferConfirmationPresenter: TransferConfirmationNSPresenterProtocol {
    func onContinueButtonClicked() {
        let parameter: ModifyDeferredTransferOperativeData = containerParameter()
        
        // First call of three of them
        let input = ModifyDeferredTransferUseCaseInput(account: parameter.account, transferScheduled: parameter.transferScheduled, scheduledTransferDetail: parameter.scheduledTransferDetail)

        showOperativeLoading(titleToUse: nil, subtitleToUse: nil, source: nil)
        UseCaseWrapper(with: dependencies.useCaseProvider.getModifyDeferredTransferUseCase(input: input), useCaseHandler: useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { [weak self] (result) in
            self?.hideLoading(completion: {
                guard let strongSelf = self else { return }
                parameter.modifyDeferredTransfer = result.modifyDeferredTransfer
                strongSelf.container?.saveParameter(parameter: result.signature)
                strongSelf.container?.saveParameter(parameter: parameter)
                strongSelf.container?.stepFinished(presenter: strongSelf)
            })
            }, onError: { [weak self] (error) in
                self?.hideLoading(completion: {
                    guard let strongSelfError = self else { return }
                    strongSelfError.showError(keyDesc: error?.getErrorDesc())
                })
        })
    }
}
