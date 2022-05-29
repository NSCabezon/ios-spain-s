import Foundation
import CoreFoundationLib

class DirectMoneyInputPresenter: OperativeStepPresenter<DirectMoneyInputViewController, VoidNavigator, DirectMoneyInputPresenterProtocol> {
    private lazy var card: Card? = {
        let directMoneyOperativeData: DirectMoneyCardOperativeData = containerParameter()
        return directMoneyOperativeData.card
    }()
    
    private lazy var directMoney: DirectMoney? = {
        let directMoneyOperativeData: DirectMoneyCardOperativeData = containerParameter()
        return directMoneyOperativeData.directMoney
    }()
    
    var cardTitle: String? {
        return card?.getAlias()
    }
    var cardSubtitle: String? {
        guard let card = card else {
            return nil
        }
        let panDescription = card.getPANShort()
        let key: String
        if card.isPrepaidCard {
            key = "pg_label_ecashCard"
        } else if card.isCreditCard {
            key = "pg_label_creditCard"
        } else {
            key = "pg_label_debitCard"
        }
        return dependencies.stringLoader.getString(key, [StringPlaceholder(.value, panDescription)]).text
    }
    var rightTitle: LocalizedStylableText? {
        guard let card = card else {
            return nil
        }
        if card.isPrepaidCard {
            return dependencies.stringLoader.getString("pg_label_balanceDots")
        } else if card.isCreditCard {
            return dependencies.stringLoader.getString("pg_label_outstandingBalanceDots")
        } else {
            return nil
        }
    }
    var amountText: String? {
        return card?.getAmountUI()
    }
    var cardImage: String? {
        return card?.buildImageRelativeUrl(true)
    }
    var imageLoader: ImageLoader {
        return dependencies.imageLoader
    }
    let amountId = "amount"

    // MARK: - Track (tarjetas_dinero_directo_importe) al pulsar opción Efectivo al instante
    override var screenId: String? {
        return TrackerPagePrivate.DirectMoneyAmount().page
    }
    
    override func loadViewData() {
        super.loadViewData()
        view.styledTitle = dependencies.stringLoader.getString("toolbar_title_directMoney")
        view.navigationBarTitleLabel.accessibilityIdentifier = "toolbar_title_directMoney"
        infoObtained()
    }
    
    private func infoObtained() {
        view.continueButton.set(localizedStylableText: stringLoader.getString("generic_button_continue"), state: .normal)
        view.continueButton.accessibilityIdentifier = AccessibilityOthers.btnContinue.rawValue
        view.continueButton.onTouchAction = { [weak self] _ in
            self?.onContinueButtonClicked()
        }
        let sectionHeader = TableModelViewSection()
        let sectionContent = TableModelViewSection()
        
        let headerViewModel = GenericHeaderCardViewModel(title: .plain(text: cardTitle),
                                                    subtitle: .plain(text: cardSubtitle),
                                                    rightTitle: rightTitle != nil ? rightTitle : .plain(text: ""),
                                                    amount: .plain(text: amountText),
                                                    imageURL: cardImage,
                                                    imageLoader: imageLoader)
        
        let headerCell = GenericHeaderViewModel(viewModel: headerViewModel, viewType: GenericOperativeCardHeaderView.self, dependencies: dependencies)
        sectionHeader.items = [headerCell]
        
        let inputLabelModel = AmountInputViewModel(inputIdentifier: amountId, titleText: stringLoader.getString("directMoney_label_amount"), textFormatMode: FormattedTextField.FormatMode.defaultCurrency(4, 2), dependencies: dependencies)
        sectionContent.add(item: inputLabelModel)
        if let minAmountDescription = directMoney?.minAmountDescription {
            let text = LocalizedStylableText(text: minAmountDescription, styles: nil)
            let infoLabelModel = OperativeLabelTableModelView(title: text, style: LabelStylist(textColor: .sanGreyDark, font: .latoRegular(size: 13), textAlignment: .left), insets: Insets(left: 10, right: 10, top: 7, bottom: 10), privateComponent: dependencies)
            sectionContent.add(item: infoLabelModel)
        }
        view.sections = [sectionHeader, sectionContent]
    }
    
    private func viewModelForIdentifier(identifier: String) -> String? {
        let sections = view.itemsSectionContent().compactMap({$0 as? InputIdentificable}).filter({$0?.inputIdentifier == identifier}).compactMap({$0})
        return sections.first?.dataEntered
    }
    
    private func displayError(text: LocalizedStylableText) {
        let stringLoader = dependencies.stringLoader
        let accept = DialogButtonComponents(titled: stringLoader.getString("generic_button_accept"), does: nil)
        Dialog.alert(title: stringLoader.getString("generic_alert_title_errorData"), body: text, withAcceptComponent: accept, withCancelComponent: nil, showsCloseButton: true, source: view, shouldTriggerHaptic: true)
    }
    
    func onContinueButtonClicked() {
        guard let enteredAmount = viewModelForIdentifier(identifier: amountId), !enteredAmount.isEmpty else {
            displayError(text: stringLoader.getString("generic_alert_text_errorAmount"))
            return
        }
        var numericCharacterSet = CharacterSet.decimalDigits
        numericCharacterSet.insert(charactersIn: ",")
        let convertedEnteredAmount = enteredAmount.replace(".", "")
        guard convertedEnteredAmount.rangeOfCharacter(from: numericCharacterSet.inverted) == nil else {
            displayError(text: stringLoader.getString("generic_alert_text_errorData_numberAmount"))
            return
        }
        guard let value = convertedEnteredAmount.stringToDecimal, value > 0 else {
            displayError(text: stringLoader.getString("generic_alert_text_errorData_amount"))
            return
        }
        let amount = Amount.createWith(value: value)
        let parameter: DirectMoneyCardOperativeData = containerParameter()
        parameter.amount = amount
        container?.saveParameter(parameter: parameter)
        container?.stepFinished(presenter: self)
    }
}

extension DirectMoneyInputPresenter: DirectMoneyInputPresenterProtocol {
    
}
