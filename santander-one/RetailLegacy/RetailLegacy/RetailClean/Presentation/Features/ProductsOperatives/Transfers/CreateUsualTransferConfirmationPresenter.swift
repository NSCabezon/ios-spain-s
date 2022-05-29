class CreateUsualTransferConfirmationPresenter: OperativeStepPresenter<OperativeConfirmationViewController, Void, OperativeConfirmationPresenterProtocol> {
    
    // MARK: - Private attributes
    
    private var operativeData: CreateUsualTransferOperativeData {
        return containerParameter()
    }
    
    override var screenId: String? {
        return TrackerPagePrivate.CreateSepaUsualTransferConfirmation().page
    }
    
    // MARK: - Public methods
    
    override func loadViewData() {
        super.loadViewData()
        let confirmationSection = TableModelViewSection()
        addConfirmation(to: confirmationSection)
        view.sections = [confirmationSection]
        view.update(title: dependencies.stringLoader.getString("genericToolbar_title_confirmation"))
        view.updateButton(title: stringLoader.getString("generic_button_confirm"))
    }
    
    // MARK: - Private methods
    
    private func addConfirmation(to confirmationSection: TableModelViewSection) {
        let title = TitledTableModelViewHeader(insets: Insets(left: 11, right: 10, top: CreateUsualTransferOperative.Constants.firstCellExtraTopInset, bottom: 6))
        title.title = stringLoader.getString("confirmation_text_newFavoriteRecipients")
        confirmationSection.setHeader(modelViewHeader: title)
        let confirmationBuilder = ConfirmationBuilder(dependencies: dependencies)
        confirmationBuilder.add("onePay_label_alias", string: operativeData.alias)
        confirmationBuilder.add("onePay_label_holder", string: operativeData.beneficiaryName)
        confirmationBuilder.add("confirmation_item_destinationAccount", string: operativeData.iban?.formatted, valueLines: 2)
        confirmationBuilder.add("onePay_label_destinationCountry", string: operativeData.country?.name)
        confirmationBuilder.add("onePay_label_currency", string: operativeData.currency?.name)
        confirmationSection.addAll(items: confirmationBuilder.build(withFirstElement: true))
    }
}

extension CreateUsualTransferConfirmationPresenter: OperativeConfirmationPresenterProtocol {
    
    var infoTitle: LocalizedStylableText? {
        return nil
    }
    
    var toolTipMessage: LocalizedStylableText? {
        return nil
    }

    func onContinueButtonClicked() {
        guard let alias = operativeData.alias, let beneficiaryName = operativeData.beneficiaryName, let iban = operativeData.iban else {
            return
        }
        let input = ValidateCreateUsualTransferUseCaseInput(alias: alias, beneficiaryName: beneficiaryName, iban: iban)
        showOperativeLoading(titleToUse: nil, subtitleToUse: nil, source: nil)
        UseCaseWrapper(
            with: useCaseProvider.getValidateCreateUsualTransferUseCase(input: input),
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
