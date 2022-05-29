import Foundation
import CoreFoundationLib

class CreateUsualTransferInputDataPresenter: OperativeStepPresenter<FormViewController, VoidNavigator, FormPresenterProtocol> {
    
    override var screenId: String? {
        return TrackerPagePrivate.CreateUsualTransferAccount().page
    }

    private var operativeData: CreateUsualTransferOperativeData?
    override func loadViewData() {
        super.loadViewData()
        guard let container = container else {
            return
        }
        operativeData = container.provideParameter()
        view.styledTitle = dependencies.stringLoader.getString("toolbar_title_newFavoriteRecipients")
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
        self.view.continueButton.accessibilityIdentifier = AccessibilityOthers.btnContinue.rawValue
    }
    
    private func buildOptionsSection() -> StackSection? {
        let section = StackSection()
        var items: [StackItemProtocol] = []
        
        let aliasTitle = TitleLabelStackModel(title: dependencies.stringLoader.getString("onePay_label_alias"), insets: Insets(left: 11, right: 10, top: CreateUsualTransferOperative.Constants.firstCellExtraTopInset, bottom: 6))
        aliasTitle.accessibilityIdentifier = AccessibilityUsualTransfer.aliasLabel.rawValue
        items.append(aliasTitle)
        let aliasModel = TextFieldStackModel(inputIdentifier: "alias", placeholder: nil, maxLength: 50)
        if let alias = operativeData?.alias {
            aliasModel.setCurrentValue(alias)
        }
        aliasModel.accessibilityIdentifier = AccessibilityUsualTransfer.alias.rawValue
        items.append(aliasModel)

        let beneficiaryName = TitleLabelStackModel(title: dependencies.stringLoader.getString("onePay_label_holder"))
        beneficiaryName.accessibilityIdentifier = AccessibilityUsualTransfer.holderLabel.rawValue
        items.append(beneficiaryName)
        let beneficiaryNameModel = TextFieldStackModel(inputIdentifier: "beneficiaryName", placeholder: nil, maxLength: 50)
        if let beneficiary = operativeData?.beneficiaryName {
            beneficiaryNameModel.setCurrentValue(beneficiary)
        }
        beneficiaryNameModel.accessibilityIdentifier = AccessibilityUsualTransfer.beneficiaryName.rawValue
        items.append(beneficiaryNameModel)
        
        guard let country = operativeData?.country else {
            return nil
        }
        let key: String
        if country.code == "ES" {
            key = "onePayNational_hint_destinationAccount"
            let destinationAccount = TitleLabelInfoStackModel(title: dependencies.stringLoader.getString("onePay_label_destinationAccount"), tooltipText: dependencies.stringLoader.getString("tooltip_text_destinationAccount"), tooltipTitle: dependencies.stringLoader.getString("tooltip_title_destinationAccount"), actionDelegate: self)
            destinationAccount.accessibilityIdentifier = AccessibilityUsualTransfer.destinationAccountLabel.rawValue
            items.append(destinationAccount)
        } else {
            key = "onePayInternational_hint_destinationAccounts"
            let title: String
            if country.sepa {
                title = "sendMoney_label_destinationAccounts"
            } else {
                title = "onePay_label_destinationAccount"
            }
            let destinationAccount = TitleLabelStackModel(title: dependencies.stringLoader.getString(title))
            destinationAccount.accessibilityIdentifier = title
            items.append(destinationAccount)
        }
        let bankingUtils: BankingUtilsProtocol = self.dependencies.dependenciesEngine.resolve()
        bankingUtils.setCountryCode(country.code)
        let ibanText = operativeData?.iban?.ibanString ?? ""
        let ibanTextFieldModel = IBANTextFieldStackModel(inputIdentifier: "destinationAccount", placeholder: dependencies.stringLoader.getString(key), country: country, bankingUtils: bankingUtils, initialText: ibanText)
        ibanTextFieldModel.accessibilityIdentifier = AccessibilityUsualTransfer.destinationAccount.rawValue
        items.append(ibanTextFieldModel)
        section.add(items: items)
        
        return section
    }
}

extension CreateUsualTransferInputDataPresenter: FormPresenterProtocol {
    func onContinueButtonClicked() {
        let aliasIdentifier = view.dataSource.findData(identifier: "alias")
        let beneficiaryIdentifier = view.dataSource.findData(identifier: "beneficiaryName")
        let destinationAccount = view.dataSource.findData(identifier: "destinationAccount")
        guard let country = operativeData?.country else { return }
        
        showOperativeLoading(titleToUse: nil, subtitleToUse: nil, source: nil)
        let input = PreValidateCreateUsualTransferUseCaseInput(iban: destinationAccount, beneficiaryName: beneficiaryIdentifier, alias: aliasIdentifier, country: country)
        UseCaseWrapper(
            with: useCaseProvider.getPreValidateCreateUsualTransferUseCase(input: input),
            useCaseHandler: dependencies.useCaseHandler,
            errorHandler: genericErrorHandler,
            onSuccess: { [weak self] response in
                self?.hideAllLoadings { [weak self] in
                    guard let strongSelf = self else { return }
                    let parameter: CreateUsualTransferOperativeData = strongSelf.containerParameter()
                    parameter.beneficiaryName = response.beneficiaryName
                    parameter.alias = response.alias
                    parameter.iban = response.iban
                    strongSelf.container?.saveParameter(parameter: parameter)
                    strongSelf.container?.stepFinished(presenter: strongSelf)
                }
            },
            onError: { [weak self] error in
                self?.hideAllLoadings { [weak self] in
                    guard let error = error else {
                        return
                    }
                    switch error.errorInfo {
                    case let .key(key):
                        self?.showError(keyTitle: "generic_alert_title_errorData", keyDesc: key)
                    case let .keyWithPlaceHolder(key, placeholder):
                        self?.showError(keyTitle: "generic_alert_title_errorData", keyDesc: key, placeholders: placeholder)
                    }
                }
            }
        )
    }
}

// MARK: - TooltipTextFieldActionDelegate

extension CreateUsualTransferInputDataPresenter: TooltipTextFieldActionDelegate {
    func auxiliaryButtonAction(completion: (TooltipTextFieldAuxiliaryAction) -> Void) {
        completion(.toolTip(delegate: view))
    }
}
