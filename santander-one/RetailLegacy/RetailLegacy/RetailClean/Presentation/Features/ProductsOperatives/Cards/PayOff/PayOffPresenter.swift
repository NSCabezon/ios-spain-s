import Foundation

final class PayOffPresenter: OperativeStepPresenter<PayOffViewController, VoidNavigator, PayOffPresenterProtocol> {
    
    var operativeData: PayOffCardOperativeData? {
        return container?.provideParameter()
    }

    override var screenId: String? {
        return TrackerPagePrivate.PayOffAmount().page
    }
    
    private var imageLoader: ImageLoader {
        return dependencies.imageLoader
    }
    
    private var cardImage: String? {
        return operativeData?.productSelected?.buildImageRelativeUrl(true)
    }
    
    private var cardTitle: String? {
        return operativeData?.productSelected?.getAliasCamelCase()
    }
    
    private var cardSubtitle: String? {
        return formattedSubtitle()
    }
    
    private var rightTitle: LocalizedStylableText? {
        return formattedTitle()
    }
    
    private var availableCredit: String? {
        return operativeData?.productSelected?.getAmountUI()
    }
    
    override func loadViewData() {
        super.loadViewData()
        guard let container = container else { return }
        
        let sectionHeader = TableModelViewSection()
        let headerViewModel = GenericHeaderCardViewModel(title: .plain(text: cardTitle),
                                                         subtitle: .plain(text: cardSubtitle),
                                                         rightTitle: rightTitle,
                                                         amount: .plain(text: availableCredit),
                                                         imageURL: cardImage,
                                                         imageLoader: imageLoader)
        
        let headerCell = GenericHeaderViewModel(viewModel: headerViewModel, viewType: GenericOperativeCardHeaderView.self, dependencies: dependencies)
        sectionHeader.items = [headerCell]
        
        let sectionContent = TableModelViewSection()
        let amountLabelModel = AmountInputViewModel(inputIdentifier: "amount", titleText: stringLoader.getString("mobileRechange_label_import"), textFormatMode: FormattedTextField.FormatMode.defaultCurrency(6, 2), dependencies: dependencies)
        
        sectionContent.items += [amountLabelModel]
        view.sections = [sectionHeader, sectionContent]
    }
    
    private func formattedTitle() -> LocalizedStylableText? {
        guard let card = operativeData?.productSelected else { return nil }
        if card.isPrepaidCard {
            return dependencies.stringLoader.getString("pg_label_balanceDots")
        } else if card.isCreditCard {
            return dependencies.stringLoader.getString("pg_label_outstandingBalanceDots")
        } else {
            return LocalizedStylableText(text: "", styles: nil)
        }
    }
    
    private func formattedSubtitle() -> String? {
        guard
            let card = operativeData?.productSelected,
            let pan = card.getDetailUI().substring(card.getDetailUI().count - 4)
            else { return nil }
        let panDescription = "***" + pan
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
    
    fileprivate func displayError(withBody body: String) {
        let accept = DialogButtonComponents(titled: stringLoader.getString("generic_button_accept"), does: nil)
        Dialog.alert(title: stringLoader.getString("generic_alert_title_errorData"),
                     body: stringLoader.getString(body),
                     withAcceptComponent: accept, withCancelComponent: nil, showsCloseButton: true, source: view, shouldTriggerHaptic: true)
    }
    
    fileprivate func validate(textField: String?) -> Bool {
        switch textField {
        case (let amount) where amount == nil,
             (let amount) where amount == "":
            displayError(withBody: "generic_alert_text_errorAmount")
            return false
        case (let amount) where amount == "0":
            displayError(withBody: "generic_alert_text_errorData_amount")
            return false
        default:
            break
        }
        return true
    }
    
    private func viewModelForIdentifier(identifier: String) -> String? {
        let sections = view.itemsSectionContent().compactMap({$0 as? InputIdentificable}).filter({$0?.inputIdentifier == identifier}).compactMap({$0})
        return sections.first?.dataEntered
    }
}

extension PayOffPresenter: PayOffPresenterProtocol {    
    func continueButton() {
        guard
            let operativeData = operativeData,
            let enteredAmount = viewModelForIdentifier(identifier: "amount"),
            !enteredAmount.isEmpty else {
                self.showError(keyDesc: "generic_alert_text_errorAmount")
                return
        }
        
        guard validate(textField: enteredAmount) else { return }
        var numericCharacterSet = CharacterSet.decimalDigits
        numericCharacterSet.insert(charactersIn: ",")
        let cleanAmount = enteredAmount.filterValidCharacters(characterSet: numericCharacterSet)
        if let amountValue = cleanAmount.stringToDecimal {
            operativeData.amount = Amount.createWith(value: amountValue)
            container?.saveParameter(parameter: operativeData)
        }
        container?.stepFinished(presenter: self)
    }
    
    var title: LocalizedStylableText {
        return dependencies.stringLoader.getString("toolbar_title_depositCard")
    }
    
    var buttonTitle: LocalizedStylableText {
        return dependencies.stringLoader.getString("generic_button_continue")
    }
}
