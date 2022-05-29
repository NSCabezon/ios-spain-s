import Foundation
import CoreFoundationLib

class UpdateUsualTransferInputDataPresenter: OperativeStepPresenter<FormViewController, VoidNavigator, FormPresenterProtocol> {
    // MARK: - Overrided methods
    private var operativeData: UpdateUsualTransferOperativeData?
    
    override var shouldShowProgress: Bool {
        return true
    }
    
    override var screenId: String? {
        return TrackerPagePrivate.UpdateUsualTransfer().sepaAccountSelector
    }
    
    override func loadViewData() {
        super.loadViewData()
        guard let container = container else {
            return
        }
        operativeData = container.provideParameter()
        view.styledTitle = dependencies.stringLoader.getString("toolbar_title_editFavoriteRecipients")
        view.backgroundColorProgressBar = .uiBackground
        
        infoObtained()
    }
    
    private func infoObtained() {
        guard let container = container else {
            return
        }
        operativeData = container.provideParameter()
                
        guard let sections = buildOptionsSection() else { return }
        view.dataSource.reloadSections(sections: [sections])
        view.continueButton.set(localizedStylableText: stringLoader.getString("generic_button_continue"), state: .normal)
    }
    
    private func buildOptionsSection() -> StackSection? {
        let section = StackSection()
        var items: [StackItemProtocol] = []
        
        let alias = TitleLabelStackModel(title: dependencies.stringLoader.getString("onePay_label_favoriteRecipients"), insets: Insets(left: 11, right: 10, top: 30, bottom: 6))
        alias.accessibilityIdentifier = "onePay_label_favoriteRecipients"
        items.append(alias)
        
        let favoriteModel = FavoriteRecipientWithCurrencyStackModel(
            title: dependencies.stringLoader.getString("onePay_label_alias").text,
            alias: operativeData?.favourite?.alias ?? "",
            country: operativeData?.newCountry?.name ?? "",
            currency: operativeData?.newCurrency?.name ?? "")
        favoriteModel.accessibilityIdentifier = "onePay_label_alias"
        items.append(favoriteModel)

        let beneficiaryName = TitleLabelStackModel(title: dependencies.stringLoader.getString("onePay_label_holder"))
        beneficiaryName.accessibilityIdentifier = "onePay_label_holder"
        items.append(beneficiaryName)
        
        let beneficiaryNameModel = TextFieldStackModel(inputIdentifier: "beneficiaryName", placeholder: nil, maxLength: 50)
        beneficiaryNameModel.setCurrentValue(operativeData?.favourite?.baoName ?? "")
        beneficiaryNameModel.accessibilityIdentifier = "beneficiaryName"
        items.append(beneficiaryNameModel)
        
        var destinationAccount = getDestinationAccount(typeTransfer: operativeData?.typeTransfer)
        destinationAccount.accessibilityIdentifier = operativeData?.typeTransfer?.accessibilityIdentifier
        items.append(destinationAccount)
        
        guard let type = operativeData?.typeTransfer, let country = operativeData?.newCountry else {
            return nil
        }
        
        let key: String
        switch type {
        case .national:
            key = "onePayNational_hint_destinationAccounts"
        case .sepa:
            key = "onePayInternational_hint_destinationAccounts"
        case .noSepa:
            key = "onePayInternational_hint_destinationAccounts"
        }
        
        var ibanText: String = ""
        if operativeData?.newCountry == operativeData?.currentCountry {
            ibanText = operativeData?.favourite?.accountDescription ?? ""
        }

        let bankingUtils: BankingUtilsProtocol = self.dependencies.dependenciesEngine.resolve()
        bankingUtils.setCountryCode(country.code)
        let ibanTextFieldModel = IBANTextFieldStackModel(inputIdentifier: "destinationAccount", placeholder: dependencies.stringLoader.getString(key), country: country, bankingUtils: bankingUtils, initialText: ibanText)
        ibanTextFieldModel.accessibilityIdentifier = "destinationAccount"
        
        items.append(ibanTextFieldModel)
        
        section.add(items: items)
        
        return section
    }
    
    func getDestinationAccount(typeTransfer: OnePayTransferType?) -> StackItemProtocol {
        if case OnePayTransferType.national? = typeTransfer {
            return TitleLabelInfoStackModel(title: dependencies.stringLoader.getString("onePay_label_destinationAccount"),
                                            tooltipText: dependencies.stringLoader.getString("tooltip_text_destinationAccount"),
                                            tooltipTitle: dependencies.stringLoader.getString("tooltip_title_destinationAccount"),
                                            actionDelegate: self)
        } else {
            return TitleLabelStackModel(title: dependencies.stringLoader.getString("newSendOnePay_label_destinationAccounts"),
                                        insets: Insets(left: 11, right: 10, top: 30, bottom: 6))
        }
    }
}

extension UpdateUsualTransferInputDataPresenter: FormPresenterProtocol {
    func onContinueButtonClicked() {
        let beneficiaryIdentifier = view.dataSource.findData(identifier: "beneficiaryName")
        let destinationAccountIdentifier = view.dataSource.findData(identifier: "destinationAccount")
        
        guard beneficiaryIdentifier?.isEmpty == false else {
            showError(keyTitle: "generic_alert_title_errorData", keyDesc: "onePay_alert_holderValidation")
            return
        }
        guard let country = operativeData?.newCountry else { return }
        
        showOperativeLoading(titleToUse: nil, subtitleToUse: nil, source: nil)
        let input = PreValidateUpdateUsualTransferUseCaseInput(iban: destinationAccountIdentifier, country: country)
        UseCaseWrapper(
            with: useCaseProvider.getPreValidateUpdateUsualTransferUseCase(input: input),
            useCaseHandler: dependencies.useCaseHandler,
            errorHandler: genericErrorHandler,
            onSuccess: { [weak self] response in
                self?.hideAllLoadings { [weak self] in
                    guard let strongSelf = self else { return }
                    let parameter: UpdateUsualTransferOperativeData = strongSelf.containerParameter()
                    parameter.newBeneficiaryName = beneficiaryIdentifier
                    parameter.newDestinationAccount = response.iban
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

// MARK: - TooltipTextFieldActionDelegate

extension UpdateUsualTransferInputDataPresenter: TooltipTextFieldActionDelegate {
    func auxiliaryButtonAction(completion: (TooltipTextFieldAuxiliaryAction) -> Void) {
        completion(.toolTip(delegate: view))
    }
}
