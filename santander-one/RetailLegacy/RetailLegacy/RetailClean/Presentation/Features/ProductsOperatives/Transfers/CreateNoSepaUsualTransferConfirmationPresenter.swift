class CreateNoSepaUsualTransferConfirmationPresenter: OperativeStepPresenter<OperativeConfirmationViewController, Void, OperativeConfirmationPresenterProtocol> {
    
    // MARK: - Private attributes
    
    private var operativeData: CreateNoSepaUsualTransferOperativeData {
        return containerParameter()
    }
    
    override var screenId: String? {
        return TrackerPagePrivate.CreateNoSepaUsualTransferConfirmation().page
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
        confirmationBuilder.add("confirmation_item_alias", string: operativeData.alias)
        confirmationBuilder.add("confirmation_item_holder", string: operativeData.beneficiaryName)
        confirmationBuilder.add("confirmation_item_destinationAccount", string: operativeData.account)
        
        if let address = operativeData.noSepaPayee?.address, !address.isEmpty {
            confirmationBuilder.add("confirmation_label_beneficiaryAddress", string: address)
        }
        if let town = operativeData.noSepaPayee?.town, !town.isEmpty {
            confirmationBuilder.add("confirmation_label_beneficiaryTown", string: town)
        }       
        if let countryNamePayee = operativeData.noSepaPayee?.countryName, !countryNamePayee.isEmpty {
            confirmationBuilder.add("confirmation_label_beneficiaryCountry", string: countryNamePayee)
        }
        confirmationBuilder.add("confirmation_item_destinationCountry", string: operativeData.country?.name)
        confirmationBuilder.add("confirmation_item_currency", string: operativeData.currency?.name)
        
        if let swiftCode = operativeData.noSepaPayee?.swiftCode, !swiftCode.isEmpty {
            confirmationBuilder.add("confirmation_label_bicSwift", string: swiftCode)
        }
        
        if let bankName = operativeData.noSepaPayee?.bankName, !bankName.isEmpty {
            confirmationBuilder.add("confirmation_item_nameBank", string: bankName)
        }
        
        if let bankAddress = operativeData.noSepaPayee?.bankAddress, !bankAddress.isEmpty {
            confirmationBuilder.add("confirmation_item_address", string: bankAddress)
        }
        
        if let bankTown = operativeData.noSepaPayee?.bankTown, !bankTown.isEmpty {
            confirmationBuilder.add("confirmation_item_town", string: bankTown)
        }
        
        if let bankCountry = operativeData.noSepaPayee?.bankCountryName, !bankCountry.isEmpty {
            confirmationBuilder.add("confirmation_item_country", string: bankCountry)
        }
        
        confirmationSection.addAll(items: confirmationBuilder.build(withFirstElement: true))
    }
}

extension CreateNoSepaUsualTransferConfirmationPresenter: OperativeConfirmationPresenterProtocol {
    
    var infoTitle: LocalizedStylableText? {
        return nil
    }
    
    var toolTipMessage: LocalizedStylableText? {
        return nil
    }
    
    func onContinueButtonClicked() {
        guard let alias = operativeData.alias,
            let currency = operativeData.currency?.currency else {
            return
        }
        
        let input = ValidateCreateNoSepaUsualTransferUseCaseInput(alias: alias, currency: currency, noSepaPayee: operativeData.noSepaPayee)
        showOperativeLoading(titleToUse: nil, subtitleToUse: nil, source: nil)
        UseCaseWrapper(
            with: useCaseProvider.getValidateCreateNoSepaUsualTransferUseCase(input: input),
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
