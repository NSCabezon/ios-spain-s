import Foundation
import CoreFoundationLib

class CreateNoSepaUsualTransferInputDataPresenter: OperativeStepPresenter<FormViewController, VoidNavigator, FormPresenterProtocol> {
    private enum InputIdentifier: String {
        case alias
        case beneficiaryName
        case destinationAccount
    }
    private var operativeData: CreateNoSepaUsualTransferOperativeData?
    
    override var screenId: String? {
        return TrackerPagePrivate.CreateUsualTransferAccount().page
    }
    
    //Aquí hay que preguntarse si es sepa o noSepa
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
        let aliasModel = TextFieldStackModel(inputIdentifier: InputIdentifier.alias.rawValue, placeholder: nil, maxLength: 50)
        if let alias = operativeData?.alias {
            aliasModel.setCurrentValue(alias)
        }
        aliasModel.accessibilityIdentifier = InputIdentifier.alias.rawValue
        items.append(aliasModel)
        
        let beneficiaryName = TitleLabelStackModel(title: dependencies.stringLoader.getString("onePay_label_holder"))
        beneficiaryName.accessibilityIdentifier = AccessibilityUsualTransfer.holderLabel.rawValue
        items.append(beneficiaryName)
        let beneficiaryNameModel = TextFieldStackModel(inputIdentifier: InputIdentifier.beneficiaryName.rawValue, placeholder: nil, maxLength: 50)
        if let beneficiary = operativeData?.beneficiaryName {
            beneficiaryNameModel.setCurrentValue(beneficiary)
        }
        beneficiaryNameModel.accessibilityIdentifier = InputIdentifier.beneficiaryName.rawValue
        items.append(beneficiaryNameModel)
        
        let titleHeader = TitleLabelStackModel(title: dependencies.stringLoader.getString("sendMoney_label_destinationAccount"))
        titleHeader.accessibilityIdentifier = AccessibilityUsualTransfer.sendMoneyDestinationAccountLabel.rawValue
        items.append(titleHeader)
        let accountTextFieldModel = TextFieldStackModel(inputIdentifier: InputIdentifier.destinationAccount.rawValue, placeholder: nil, maxLength: 50, characterSet: CharacterSet.ibanNoSepa)
        accountTextFieldModel.accessibilityIdentifier = InputIdentifier.destinationAccount.rawValue
        items.append(accountTextFieldModel)
        
        section.add(items: items)
        return section
    }
    
    private func dataEnteredForIdentifier(_ identifier: InputIdentifier) -> String? {
        return view.dataSource.findData(identifier: identifier.rawValue)
    }
}

extension CreateNoSepaUsualTransferInputDataPresenter: FormPresenterProtocol {
    func onContinueButtonClicked() {
        let aliasIdentifier = dataEnteredForIdentifier(.alias)
        let beneficiaryIdentifier = dataEnteredForIdentifier(.beneficiaryName)
        let destinationAccount = dataEnteredForIdentifier(.destinationAccount)
        guard let country = operativeData?.country else { return }
        
        showOperativeLoading(titleToUse: nil, subtitleToUse: nil, source: nil)
        let input = PreValidateCreateNoSepaUsualTransferUseCaseInput(account: destinationAccount, beneficiaryName: beneficiaryIdentifier, alias: aliasIdentifier, country: country)
        UseCaseWrapper(
            with: useCaseProvider.getPreValidateCreateNoSepaUsualTransferUseCase(input: input),
            useCaseHandler: dependencies.useCaseHandler,
            errorHandler: genericErrorHandler,
            onSuccess: { [weak self] response in
                self?.hideAllLoadings { [weak self] in
                    guard let strongSelf = self else { return }
                    let parameter: CreateNoSepaUsualTransferOperativeData = strongSelf.containerParameter()
                    parameter.beneficiaryName = response.beneficiaryName
                    parameter.alias = response.alias
                    parameter.account = response.account
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
