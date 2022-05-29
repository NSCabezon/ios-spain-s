import Foundation

class ReemittedNoSepaTransferConfirmationPresenter: OperativeStepPresenter<TransferConfirmationNoSepaViewController, Void, TransferConfirmationNSPresenterProtocol> {
    
    private enum InputIdentifier: String {
        case mail
    }
    
    override var screenId: String? {
        let parameter: ReemittedNoSepaTransferOperativeData = containerParameter()
        switch parameter.operativeOrigin {
        case .emittedTransfer:
            return TrackerPagePrivate.NoSepaReemittedTransfer().confirmationPage
        case .favorite:
            return TrackerPagePrivate.NoSepaUsualTransfer().confirmationPage
        }
    }
    
    // MARK: - Public methods
    
    override func loadViewData() {
        super.loadViewData()
        let operativeData: ReemittedNoSepaTransferOperativeData = containerParameter()
        // Add account section
        
        var sections: [TableModelViewSection] = []
        
        if let account = operativeData.productSelected {
            let accountSection = TableModelViewSection()
            addAccount(account, to: accountSection)
            sections.append(accountSection)
        }
        // Add confirmation items
        let confirmationSection = TableModelViewSection()
        addConfirmation(to: confirmationSection)
        sections.append(confirmationSection)
        view.sections = sections
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
        let operativeData: ReemittedNoSepaTransferOperativeData = containerParameter()
        let confirmationBuilder = ConfirmationBuilder(dependencies: dependencies)
        confirmationBuilder.add("confirmation_item_beneficiary", string: operativeData.transferDetail.payee?.name ?? "")
        if let beneficiaryAddress = operativeData.transferDetail.payee?.address, !beneficiaryAddress.isEmpty {
            confirmationBuilder.add("confirmation_label_beneficiaryAddress", string: beneficiaryAddress)
        }
        
        if let beneficiaryAddressLocality = operativeData.transferDetail.payee?.town, !beneficiaryAddressLocality.isEmpty {
            confirmationBuilder.add("confirmation_label_beneficiaryTown", string: beneficiaryAddressLocality)
        }
        
        if let beneficiaryAddressCountryCode = operativeData.transferDetail.countryCode,
            let beneficiaryCountryName = operativeData.sepaInfoList?.countryFor(beneficiaryAddressCountryCode),
            !beneficiaryCountryName.isEmpty,
            !operativeData.isSepaNoEur,
            operativeData.operativeOrigin == .emittedTransfer {
            confirmationBuilder.add("confirmation_label_beneficiaryCountry", string: beneficiaryCountryName.capitalized)
        }
        
        var titleDestinationCountry: String = ""
        if operativeData.isSepaNoEur {
            titleDestinationCountry = "confirmation_item_destinationCountry"
        } else {
            titleDestinationCountry = "confirmation_label_destinationCountryToPayement"
        }
        confirmationBuilder.add(titleDestinationCountry, string: operativeData.selectedCountry?.name.capitalized ?? "")
        
        confirmationBuilder.add("confirmation_item_currency", string: operativeData.selectedCurrency?.name.capitalized ?? "")
        
        if let bicSwift = operativeData.beneficiaryAccount?.bicSwift, !bicSwift.isEmpty {
            confirmationBuilder.add("confirmation_label_bicSwift", string: bicSwift)
        } else if let bankName = operativeData.beneficiaryAccount?.bankName, !bankName.isEmpty {
            confirmationBuilder.add("confirmation_item_nameBank", string: bankName)
        }
        if let bankAddress = operativeData.beneficiaryAccount?.bankAddress, !bankAddress.isEmpty {
            confirmationBuilder.add("confirmation_item_address", string: bankAddress)
        }
        if let bankLocality = operativeData.beneficiaryAccount?.bankLocality, !bankLocality.isEmpty {
            confirmationBuilder.add("confirmation_item_town", string: bankLocality)
        }
        if let bankCountry = operativeData.beneficiaryAccount?.bankCountry, !bankCountry.isEmpty {
            confirmationBuilder.add("confirmation_item_country", string: bankCountry)
        }
        confirmationBuilder.add("confirmation_item_periodicity", string: dependencies.stringLoader.getString("confirmation_item_timely").text)
        confirmationBuilder.add("confirmation_item_date", date: operativeData.date, format: .dd_MMM_yyyy)
        
        if operativeData.amount?.currency?.currencyType != .eur {
            confirmationBuilder.add("confirmation_label_counterValue", amount: operativeData.noSepaTransferValidation?.impCargoContraval)
        }
        
        switch operativeData.transferExpenses {
        case .shared?, .none:
            confirmationBuilder.add("confirmation_label_sharedExpenses", amount: operativeData.noSepaTransferValidation?.expenses)
        case .payer?:
            confirmationBuilder.add("confirmation_label_payerExpenses", amount: operativeData.noSepaTransferValidation?.expenses)
        case .beneficiary?:
            confirmationBuilder.add("confirmation_item_beneficiaryExpenses", amount: operativeData.noSepaTransferValidation?.expenses)
        }
        
        if !operativeData.isSepaNoEur {
            confirmationBuilder.add("confirmation_label_swiftExpenses", amount: operativeData.noSepaTransferValidation?.swiftExpenses)
        }
        confirmationBuilder.add("confirmation_item_mailExpenses", amount: operativeData.noSepaTransferValidation?.mailExpenses)
        confirmationBuilder.add("confirmation_label_payerAmountToDebt", amount: operativeData.noSepaTransferValidation?.settlementAmountPayer)
        confirmationBuilder.add("confirmation_label_amountBeneficiaryPay", amount: operativeData.noSepaTransferValidation?.settlementAmountBenef)
        addTransferInfo(to: confirmationSection)
        
        confirmationSection.add(item: ConfirmationTextFieldViewModel(inputIdentifier: InputIdentifier.mail.rawValue, title: dependencies.stringLoader.getString("confirmation_label_sentMail"), placeholder: dependencies.stringLoader.getString("confirmation_label_optional"), keyboardType: .emailAddress, privateComponent: dependencies))
        
        confirmationSection.addAll(items: confirmationBuilder.build())
        confirmationSection.add(item: OperativeLabelTableModelView(title: dependencies.stringLoader.getString("confirmation_item_onePayCommission"), style: LabelStylist(textColor: .sanGreyMedium, font: .latoRegular(size: 14), textAlignment: .center), privateComponent: dependencies))
    }
    
    private func addTransferInfo(to section: TableModelViewSection) {
        let operativeData: ReemittedNoSepaTransferOperativeData = containerParameter()
        guard let destinationAccount = operativeData.beneficiaryAccount?.account, let transferAmount = operativeData.amount?.getAbsFormattedAmountUI() else { return }
        let concept: String
        if let transferConcept = operativeData.concept, !transferConcept.isEmpty {
            concept = transferConcept
        } else {
            concept = dependencies.stringLoader.getString("onePay_label_notConcept").text
        }
        
        let accountTransferHeader = TransferAccountHeaderViewModel(
            dependencies: dependencies,
            amount: transferAmount,
            destinationAccount: destinationAccount,
            concept: concept
        )
        
        let title = TitledTableModelViewHeader()
        title.title = stringLoader.getString("confirmation_label_standardSent")
        section.setHeader(modelViewHeader: title)
        section.add(item: accountTransferHeader)
    }
    
    private func dataEntered(for identifier: String) -> String? {
        let sections = view.itemsSectionContent().compactMap({$0 as? InputIdentificable}).filter({$0?.inputIdentifier == identifier}).compactMap({$0})
        return sections.first?.dataEntered
    }
}

extension ReemittedNoSepaTransferConfirmationPresenter: TransferConfirmationNSPresenterProtocol {
    
    func onContinueButtonClicked() {
        let operativeData: ReemittedNoSepaTransferOperativeData = containerParameter()
        
        let address = Address(country: operativeData.transferDetail.countryName ?? "", address: operativeData.transferDetail.payee?.address, locality: operativeData.transferDetail.payee?.town)
        
        guard
            let beneficiary = operativeData.transferDetail.payee?.name,
            let beneficiaryAccount = operativeData.beneficiaryAccount,
            let swiftValidation = operativeData.swiftValidation,
            let transferAmount = operativeData.amount,
            let transferExpenses = operativeData.transferExpenses,
            let originAccount = operativeData.productSelected
        else {
                return
        }
        
        let input = ValidateNoSepaTransferUseCaseInput(
            originAccount: originAccount,
            beneficiary: beneficiary,
            beneficiaryAccount: beneficiaryAccount,
            beneficiaryAddress: address,
            dateOperation: Date(),
            transferAmount: transferAmount,
            expensiveIndicator: transferExpenses,
            countryCode: operativeData.transferDetail.destinationCountryCode ?? "",
            concept: operativeData.concept ?? "",
            swiftValidation: swiftValidation,
            beneficiaryEmail: dataEntered(for: InputIdentifier.mail.rawValue)
        )
        showOperativeLoading(titleToUse: nil, subtitleToUse: nil, source: nil)
        UseCaseWrapper(
            with: useCaseProvider.getValidateNoSepaTransferUseCase(input: input),
            useCaseHandler: useCaseHandler,
            errorHandler: genericErrorHandler,
            onSuccess: { [weak self] result in
                self?.hideAllLoadings { [weak self] in
                    guard let strongSelf = self, let signature = result.validation.signature else { return }
                    operativeData.noSepaTransferValidation = result.validation
                    operativeData.beneficiaryEmail = result.beneficiaryEmail
                    strongSelf.container?.saveParameter(parameter: operativeData)
                    strongSelf.container?.saveParameter(parameter: signature)
                    strongSelf.container?.stepFinished(presenter: strongSelf)
                }
            },
            onError: { [weak self] error in
                self?.hideAllLoadings { [weak self] in
                    switch error?.type {
                    case .service?, .none:
                        self?.showError(keyTitle: nil, keyDesc: error?.getErrorDesc())
                    case .notValidMail?:
                        self?.showError(keyTitle: "generic_alert_title_errorData", keyDesc: "onePay_alert_mailNotValid")
                    }
                }
            }
        )
    }
}
