import Foundation

class ChangeMassiveDirectDebitsConfirmationPresenter: OperativeStepPresenter<OperativeConfirmationViewController, Void, OperativeConfirmationPresenterProtocol> {
    
    // MARK: - Private attributes
    
    private var operativeData: ChangeMassiveDirectDebitsOperativeData {
        return containerParameter()
    }
    
    override var screenId: String? {
        return TrackerPagePrivate.ChangeMassiveDirectDebitsConfirmation().page
    }
    
    // MARK: - Public methods
    
    override func loadViewData() {
        super.loadViewData()
        guard let account = operativeData.productSelected else { return }
        view.styledTitle = stringLoader.getString("genericToolbar_title_confirmation")
        // Add account section
        let accountSection = TableModelViewSection()
        addAccount(account, to: accountSection)
        // Add confirmation items
        let confirmationSection = TableModelViewSection()
        addConfirmation(to: confirmationSection)
        view.sections = [accountSection, confirmationSection]
        view.update(title: dependencies.stringLoader.getString("genericToolbar_title_confirmation"))
        view.updateButton(title: stringLoader.getString("generic_button_confirm"))
    }
    
    // MARK: - Private methods
    
    private func addAccount(_ account: Account, to accountSection: TableModelViewSection) {
        let accountItem = AccountConfirmationViewModel(
            accountName: account.getAlias() ?? stringLoader.getString("generic_confirm_associatedAccount").text,
            ibanNumber: account.getIBANShort(),
            amount: account.getAmountUI(),
            privateComponent: dependencies
        )
        let accountTitle = TitledTableModelViewHeader()
        accountTitle.title = stringLoader.getString("confirmationDepositCard_label_originAccount")
        accountSection.setHeader(modelViewHeader: accountTitle)
        accountSection.add(item: accountItem)
    }
    
    private func addConfirmation(to confirmationSection: TableModelViewSection) {
        let title = TitledTableModelViewHeader()
        title.title = stringLoader.getString("confirmation_label_changeAccount")
        confirmationSection.setHeader(modelViewHeader: title)
        let confirmationBuilder = ConfirmationBuilder(dependencies: dependencies)
        confirmationBuilder.add("confirmation_item_newAccount", string: operativeData.destinationAccount?.getAliasAndInfo())
        confirmationBuilder.add("confirmation_item_balance", string: operativeData.destinationAccount?.getAmountUI())
        confirmationBuilder.add("confirmation_item_date", date: Date(), format: .dd_MMM_yyyy)
        confirmationSection.addAll(items: confirmationBuilder.build(withFirstElement: true))
    }
}

extension ChangeMassiveDirectDebitsConfirmationPresenter: OperativeConfirmationPresenterProtocol {
    
    var infoTitle: LocalizedStylableText? {
        return nil
    }
    
    var toolTipMessage: LocalizedStylableText? {
        return nil
    }
    
    func onContinueButtonClicked() {
        guard let account = operativeData.productSelected, let destinationAccount = operativeData.destinationAccount else { return }
        showOperativeLoading(titleToUse: nil, subtitleToUse: nil, source: nil)
        UseCaseWrapper(
            with: useCaseProvider.getValidateChangeMassiveDirectDebitsUseCase(input: ValidateChangeMassiveDirectDebitsUseCaseInput(originAccount: account, destinationAccount: destinationAccount)),
            useCaseHandler: dependencies.useCaseHandler,
            errorHandler: genericErrorHandler,
            onSuccess: { [weak self] response in
                self?.hideAllLoadings { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.container?.saveParameter(parameter: response.signatureWithToken)
                    strongSelf.container?.stepFinished(presenter: strongSelf)
                }
            },
            onError: { [weak self] error in
                self?.hideAllLoadings { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.showError(keyDesc: error?.getErrorDesc())
                }
            }
        )
    }
}
