import Foundation

class UpdateNoSepaUsualTransferConfirmationPresenter: OperativeStepPresenter<OperativeConfirmationViewController, Void, OperativeConfirmationPresenterProtocol> {
    
    // MARK: - Private attributes
    
    private var operativeData: UpdateNoSepaUsualTransferOperativeData {
        return containerParameter()
    }
    
    private var noSepaUpdate: UpdateNoSepaFieldsBuilderType {
        return NoSepaFieldsBuilderFactory.create(operativeData)
    }
    
    override var screenId: String? {
        return TrackerPagePrivate.UpdateUsualTransfer().noSepaConfirmation
    }
    
    // MARK: - Public methods
    
    override func loadViewData() {
        super.loadViewData()
        view.styledTitle = stringLoader.getString("genericToolbar_title_confirmation")
        view.updateButton(title: stringLoader.getString("generic_button_confirm"))
        self.view.sections = [contentSections()]
    }
    
    // MARK: - Private methods
    
    private func contentSections() -> TableModelViewSection {
        let confirmationSection = TableModelViewSection()

        let title = TitledTableModelViewHeader()
        title.title = stringLoader.getString("confirmation_label_changeAccount")
        confirmationSection.setHeader(modelViewHeader: title)
        confirmationSection.addAll(items: noSepaUpdate.createConfirmationFields(data: operativeData, dependencies: dependencies))

        return confirmationSection
    }
    
}

extension UpdateNoSepaUsualTransferConfirmationPresenter: OperativeConfirmationPresenterProtocol {
    var infoTitle: LocalizedStylableText? {
        return nil
    }
    
    var toolTipMessage: LocalizedStylableText? {
        return nil
    }
    
    func onContinueButtonClicked() {
        
        guard let alias = operativeData.payeeAlias, let newAccount = operativeData.newDestinationAccount, let currency = operativeData.transferCurrency else {
            return
        }
        
        showOperativeLoading(titleToUse: nil, subtitleToUse: nil, source: nil)
        let input = ValidateUpdateNoSepaUsualTransferUseCaseInput(alias: alias,
                                                                  payeeName: operativeData.newName,
                                                                  payeeAccount: newAccount,
                                                                  payeeAddress: operativeData.newPayeeAddress,
                                                                  payeeLocation: operativeData.newPayeeLocation,
                                                                  payeeCountryName: operativeData.newPayeeCountry,
                                                                  payeeCountryCode: operativeData.transferCountryCode,
                                                                  bicSwift: operativeData.newBicSwift,
                                                                  bankName: operativeData.newBankName,
                                                                  bankAddress: operativeData.newBankAddress,
                                                                  bankLocation: operativeData.newBankLocation,
                                                                  bankCountryCode: operativeData.transferCountryCode,
                                                                  bankCountryName: operativeData.newBankCountry,
                                                                  currency: currency)
        UseCaseWrapper(
            with: useCaseProvider.getValidateUpdateNoSepaUsualTransferUseCase(input: input),
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
