import Foundation

class UpdateNoSepaUsualTransferInputDataPresenter: OperativeStepPresenter<FormViewController, VoidNavigator, FormPresenterProtocol> {
    
    // MARK: - Overrided methods
    private var operativeData: UpdateNoSepaUsualTransferOperativeData?
    
    override var shouldShowProgress: Bool {
        return true
    }
    
    override var screenId: String? {
        return TrackerPagePrivate.UpdateUsualTransfer().noSepaAccountSelector
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
        items.append(alias)
        let aliasTitle = dependencies.stringLoader.getString("onePay_label_alias").text
        let favoriteModel = FavoriteRecipientWithCurrencyStackModel(title: aliasTitle, alias: operativeData?.payeeAlias ?? "", country: operativeData?.transferCountry ?? "", currency: operativeData?.payeeCurrency ?? "")
        items.append(favoriteModel)
        
        let beneficiaryName = TitleLabelStackModel(title: dependencies.stringLoader.getString("onePay_label_holder"))
        items.append(beneficiaryName)
        let beneficiaryNameModel = TextFieldStackModel(inputIdentifier: payeeNameIdentifier, placeholder: nil, maxLength: 50)
        beneficiaryNameModel.setCurrentValue(operativeData?.payeeName ?? "")
        items.append(beneficiaryNameModel)
        
        let title = operativeData?.isIbanType == true ? "sendMoney_label_destinationAccounts" : "onePay_label_destinationAccount"
        let destinationAccount = TitleLabelStackModel(title: dependencies.stringLoader.getString(title))
        items.append(destinationAccount)
        
        let accountModel = TextFieldStackModel(inputIdentifier: payeeAccountIdentifier, placeholder: nil, maxLength: 50)
        accountModel.setCurrentValue(operativeData?.accountNumber ?? "")
        items.append(accountModel)
        
        section.add(items: items)
        
        return section
    }
    
}

extension UpdateNoSepaUsualTransferInputDataPresenter: UpdateNoSepaOperativeSharedIdentifiers {}

extension UpdateNoSepaUsualTransferInputDataPresenter: FormPresenterProtocol {
    func onContinueButtonClicked() {
        
        let payeeName = view.dataSource.findData(identifier: payeeNameIdentifier)
        let payeeDestinationAccount = view.dataSource.findData(identifier: payeeAccountIdentifier)
        
        guard payeeName?.isEmpty == false else {
            showError(keyTitle: "generic_alert_title_errorData", keyDesc: "onePay_alert_holderValidation")
            return
        }
        guard payeeDestinationAccount?.isEmpty == false else {
            showError(keyTitle: "generic_alert_title_errorData", keyDesc: "onePay_alert_destinationAccounts")
            return
        }
        
        operativeData?.newName = payeeName
        operativeData?.newDestinationAccount = payeeDestinationAccount
        container?.stepFinished(presenter: self)
    }
}
