import Foundation

class UpdateUsualTransferConfirmationPresenter: OperativeStepPresenter<OperativeConfirmationViewController, Void, OperativeConfirmationPresenterProtocol> {
    
    // MARK: - Private attributes
    
    private var operativeData: UpdateUsualTransferOperativeData {
        return containerParameter()
    }
    
    override var screenId: String? {
        return TrackerPagePrivate.UpdateUsualTransfer().sepaConfirmation
    }
    
    // MARK: - Public methods
    
    override func loadViewData() {
        super.loadViewData()
        view.styledTitle = stringLoader.getString("genericToolbar_title_confirmation")
        view.updateButton(title: stringLoader.getString("generic_button_continue"))
        self.view.sections = [contentSections()]
    }
    
    // MARK: - Private methods
    
    private func contentSections() -> TableModelViewSection {
        let confirmationSection = TableModelViewSection()
        
        let header = TitledTableModelViewHeader(insets: Insets(left: 11, right: 10, top: 25, bottom: 6))
        header.title = stringLoader.getString("confirmation_text_editFavoriteRecipients")
        confirmationSection.setHeader(modelViewHeader: header)
        
        let items: [ConfirmationTableViewItemModel] = [
            ConfirmationTableViewItemModel(
                stringLoader.getString("confirmation_item_alias"),
                operativeData.favourite?.alias ?? "",
                false,
                dependencies,
                isFirst: true,
                accessibilityIdentifier: "confirmation_item_alias"),
            ConfirmationTableViewItemModel(
                stringLoader.getString("confirmation_item_holder"),
                operativeData.newBeneficiaryName ?? "",
                false,
                dependencies,
                accessibilityIdentifier: "confirmation_item_holder"),
            ConfirmationTableViewItemModel(
                stringLoader.getString("confirmation_item_destinationAccount"),
                operativeData.newDestinationAccount?.formatted ?? "",
                false, dependencies,
                valueLines: 2,
                lineBreak: .byCharWrapping,
                textAlignment: .left,
                accessibilityIdentifier: "confirmation_item_destinationAccount"),
            ConfirmationTableViewItemModel(
                stringLoader.getString("confirmation_item_destinationCountry"),
                operativeData.newCountry?.name.camelCasedString ?? "",
                false,
                dependencies,
                accessibilityIdentifier: "confirmation_item_destinationCountry"),
            ConfirmationTableViewItemModel(
                stringLoader.getString("confirmation_item_currency"),
                operativeData.newCurrency?.name.camelCasedString ?? "",
                true,
                dependencies,
                accessibilityIdentifier: "confirmation_item_currency")
        ]
        confirmationSection.addAll(items: items)
        return confirmationSection
    }
}

extension UpdateUsualTransferConfirmationPresenter: OperativeConfirmationPresenterProtocol {
    var infoTitle: LocalizedStylableText? {
        return nil
    }
    
    var toolTipMessage: LocalizedStylableText? {
        return nil
    }
    
    func onContinueButtonClicked() {
        guard let favourite = operativeData.favourite else { return }
        
        showOperativeLoading(titleToUse: nil, subtitleToUse: nil, source: nil)
        let input = ValidateUpdateUsualTransferUseCaseInput(favourite: favourite, newBeneficiaryName: operativeData.newBeneficiaryName, newDestinationAccount: operativeData.newDestinationAccount, newCurrency: operativeData.newCurrency)
        UseCaseWrapper(
            with: useCaseProvider.getValidateUpdateUsualTransferUseCase(input: input),
            useCaseHandler: dependencies.useCaseHandler,
            errorHandler: genericErrorHandler,
            onSuccess: { [weak self] response in
                self?.hideAllLoadings { [weak self] in
                    guard let strongSelf = self else { return }
                    let parameter: UpdateUsualTransferOperativeData = strongSelf.containerParameter()
                    strongSelf.container?.saveParameter(parameter: response.signatureWithToken)
                    strongSelf.container?.saveParameter(parameter: parameter)
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
