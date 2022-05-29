import Foundation
import CoreFoundationLib

protocol OperatorInformationProvider: class {
    var minimumAmount: LocalizedStylableText? { get }
    var maximumAmount: LocalizedStylableText? { get }
    var intervalAmount: LocalizedStylableText? { get }
    func operatorName() -> String?
}

class MobileTopUpPresenter: OperativeStepPresenter<MobileTopUpViewController, VoidNavigator, MobileTopUpPresenterProtocol> {
    override var screenId: String? {
        return TrackerPagePrivate.MobilCharge().page
    }
    private var card: Card?
    private var operators: MobileOperatorList?
    private var currentOperatorIndex = 0
    private var currentOperator: MobileOperator? {
        didSet {
            view.reloadOperatorInfo()
        }
    }
    
    private var imageLoader: ImageLoader {
        return dependencies.imageLoader
    }
    
    private var cardImage: String? {
        return card?.buildImageRelativeUrl(true)
    }
    
    private var cardTitle: String? {
        return card?.getAliasCamelCase()
    }
    
    private var cardSubtitle: String? {
        return formattedSubtitle()
    }
    
    private var rightTitle: LocalizedStylableText? {
        return formattedTitle()
    }
    
    private var availableCredit: String? {
        return card?.getAmountUI()
    }
    
    lazy var sections: [TableModelViewSection] = {
        let sectionHeader = TableModelViewSection()
        let sectionContent = TableModelViewSection()
        
        let headerViewModel = GenericHeaderCardViewModel(title: .plain(text: cardTitle),
                                                         subtitle: .plain(text: cardSubtitle),
                                                         rightTitle: rightTitle,
                                                         amount: .plain(text: availableCredit),
                                                         imageURL: cardImage,
                                                         imageLoader: imageLoader)
        
        let headerCell = GenericHeaderViewModel(viewModel: headerViewModel, viewType: GenericOperativeCardHeaderView.self, dependencies: dependencies)
        sectionHeader.add(item: headerCell)
        guard let currentOperator = operators?.list[currentOperatorIndex] else {
            return []
        }
        let pickerSection = TableModelViewSection()
        let title = TitledTableModelViewHeader()
        title.title = stringLoader.getString("mobileRechange_label_operator")
        title.titleIdentifier = AccessibilityMobileRecharge.labelPhoneOperator.rawValue
        pickerSection.setHeader(modelViewHeader: title)
        let picker = OptionsPickerViewModel(items: operators?.list ?? [], selected: currentOperator, dependencies: dependencies, cellIdentifier: AccessibilityMobileRecharge.operatorPickerCell.rawValue
        ) { [weak self] selected in
            self?.currentOperator = selected
        }
        pickerSection.add(item: picker)
        sectionContent.add(item: PhoneInputTextFieldViewModel(inputIdentifier: "phone1",
                                                              titleInfo: dependencies.stringLoader.getString("mobileRechange_label_numberMobile"),
                                                              dependencies: dependencies,
                                                              titleIdentifier: AccessibilityMobileRecharge.mobilePhoheTitle.rawValue,
                                                              inputTextIdentifier: AccessibilityMobileRecharge.mobilePhoheInputText.rawValue))
        sectionContent.add(item: PhoneInputTextFieldViewModel(inputIdentifier: "phone2",
                                                              titleInfo: dependencies.stringLoader.getString("mobileRechange_label_confirmationNumberMobile"),
                                                              dependencies: dependencies,
                                                              titleIdentifier: AccessibilityMobileRecharge.confirmMobilePhoheTitle.rawValue,
                                                              inputTextIdentifier: AccessibilityMobileRecharge.confirmMobilePhoheInputText.rawValue))
        let amountTitle = stringLoader.getString("mobileRechange_label_import")
        sectionContent.add(item: AmountInputViewModel(inputIdentifier: "amount",
                                                      titleText: amountTitle,
                                                      dependencies: dependencies,
                                                      titleIdentifier: AccessibilityMobileRecharge.labelAmountTitle.rawValue,
                                                      textInputIdentifier: AccessibilityMobileRecharge.inputTextAmount.rawValue,
                                                      textInputRightImageIdentifier: AccessibilityMobileRecharge.labelAmountImageEuro.rawValue))
        
        let operatorSection = TableModelViewSection()
        operatorSection.add(item: OperatorInfoViewModel(delegate: self,
                                                        dependencies: dependencies,
                                                        descriptionLeftIdentifier: AccessibilityMobileRecharge.operationMinValue.rawValue,
                                                        descriptionRightIdentifier: AccessibilityMobileRecharge.operationMaxValue.rawValue,
                                                        bottomLabelIdentifier: AccessibilityMobileRecharge.operationMulpValue.rawValue))
        return [sectionHeader, pickerSection, sectionContent, operatorSection]
    }()
    
    override func loadViewData() {
        super.loadViewData()
        
        guard let container = container else {
            return
        }
        card = container.provideParameter()
        operators = container.provideParameter()
        currentOperator = operators?.list[currentOperatorIndex]
        view.sections = sections
    }
    
}

// MARK: - MobileTopUpPresenterProtocol

extension MobileTopUpPresenter: MobileTopUpPresenterProtocol {
    
    var title: LocalizedStylableText {
        return dependencies.stringLoader.getString("toolbar_title_mobileRechange")
    }
    
    var titleIdentifier: String {
        return AccessibilityMobileRecharge.navigationTitle.rawValue
    }
    
    var buttonTitle: LocalizedStylableText {
        return dependencies.stringLoader.getString("generic_button_continue")
    }
    
    var operatorsPickerCloseTitle: LocalizedStylableText {
        return dependencies.stringLoader.getString("generic_button_accept")
    }

    var operatorList: [String] {
        return operators?.list.compactMap({$0.name?.capitalized}) ?? []
    }
    
    func didSelectOperator(at position: Int) {
        currentOperatorIndex = position
    }
    
    private func viewModelForIdentifier(identifier: String) -> String? {
        let sections = view.itemsSectionContent().compactMap({$0 as? InputIdentificable}).filter({$0?.inputIdentifier == identifier}).compactMap({$0})
        return sections.first?.dataEntered
    }
    
    fileprivate func isInputValid(_ enteredPhone1: String?, _ enteredPhone2: String?, _ enteredAmount: String?) -> Bool {
        var numericCharacterSet = CharacterSet.decimalDigits
        numericCharacterSet.insert(charactersIn: ",")
        let enteredAmount = enteredAmount?.replace(".", "")
        
        switch (enteredPhone1, enteredPhone2, enteredAmount) {
        case (_, _, let value) where value == nil,
             (_, _, let value) where value == "":
            displayError(text: "mobileRechange_alert_text_enterAmount")
            
            return false
        case (_, _, let value?) where isAmountBelow(value, minimum: currentOperator?.minimumAmount?.value):
            guard let minimum = currentOperator?.minimumAmount?.getFormattedAmountUI(0) else { return false }
            displayError(text: "mobileRechange_alert_text_higherImport", placeholders: [StringPlaceholder(.value, minimum)])
            
            return false
        case (_, _, let value?) where value.rangeOfCharacter(from: numericCharacterSet.inverted) != nil:
            displayError(text: "mobileRechange_alert_text_importNotValid")
            
            return false
        case (_, _, let value?) where isAmountAbove(value, minimum: currentOperator?.maximumAmount?.value):
            guard let maximum = currentOperator?.maximumAmount?.getFormattedAmountUI(0) else { return false }
            displayError(text: "mobileRechange_alerttext_lessImport", placeholders: [StringPlaceholder(.value, maximum)])
            
            return false
        case (_, _, let value?) where !isZeroRemainder(value: value, dividedBy: currentOperator?.sectionAmount?.value):
            guard let maximum = currentOperator?.sectionAmount?.getFormattedAmountUI(0) else { return false }
            displayError(text: "mobileRechange_alert_text_multipleImport", placeholders: [StringPlaceholder(.value, maximum)])
            
            return false
        case (let phone, _, _) where phone == nil,
             (let phone, _, _) where phone == "":
            displayError(text: "mobileRechange_alert_text_enterPhone")
            
            return false
        case (_, let phone, _) where phone == nil,
             (_, let phone, _) where phone == "":
            displayError(text: "mobileRechange_alert_text_enterConfirmPhone")
            
            return false
        case (let phone?, _, _) where !isNationalPhoneNumber(phone: phone):
            displayError(text: "mobileRechange_alert_text_numberNational")
            
            return false
        case (let phone?, let phoneConfirmation?, _) where phone != phoneConfirmation:
            displayError(text: "mobileRechange_alert_text_notMatch")
            
            return false
        default:
            break
        }
        return true
    }
    
    func next() {
        let enteredPhone1 = viewModelForIdentifier(identifier: "phone1")
        let enteredPhone2 = viewModelForIdentifier(identifier: "phone2")
        let enteredAmount = viewModelForIdentifier(identifier: "amount")
        
        guard isInputValid(enteredPhone1, enteredPhone2, enteredAmount) else {
            return
        }
        
        var numericCharacterSet = CharacterSet.decimalDigits
        numericCharacterSet.insert(charactersIn: ",")
        
        if let cleanAmount = enteredAmount?.filterValidCharacters(characterSet: numericCharacterSet),
            let amountValue = Decimal(string: cleanAmount) {
            let amount = Amount.createWith(value: amountValue)
            container?.saveParameter(parameter: amount)
        }
        
        if let phoneNumber = enteredPhone1 {
            container?.saveParameter(parameter: MobilePhoneNumber(number: phoneNumber))
        }
        if let currentOperator = currentOperator {
            container?.saveParameter(parameter: currentOperator)
        }
        
        container?.stepFinished(presenter: self)
    }
    
    // MARK: - Helpers
    
    private func isAmountBelow(_ amount: String, minimum: Decimal?) -> Bool {
        guard let value = Decimal(string: amount), let minimum = minimum else {
            return false
        }
        
        return value < minimum
    }
    
    private func isAmountAbove(_ amount: String, minimum: Decimal?) -> Bool {
        guard let value = Decimal(string: amount), let minimum = minimum else {
            return false
        }
        
        return value > minimum
    }
    
    private func isNationalPhoneNumber(phone: String) -> Bool {
        let parser = PhoneFormatter()
        return parser.checkNationalPhone(phone: phone) == .ok
    }
    
    private func isZeroRemainder(value: String, dividedBy divisor: Decimal?) -> Bool {
        guard let divisor = divisor, let originalValue = Decimal(string: value) else {
            return true
        }
        
        return Double(truncating: originalValue as NSNumber).remainder(dividingBy: Double(truncating: divisor as NSNumber)) == 0
    }
    
    private func formattedTitle() -> LocalizedStylableText? {
        guard let card = card else {
            return nil
        }
        if card.isPrepaidCard {
            return dependencies.stringLoader.getString("pg_label_balanceDots")
        } else if card.isCreditCard {
            return dependencies.stringLoader.getString("pg_label_outstandingBalanceDots")
        } else {
            return LocalizedStylableText(text: "", styles: nil)
        }
    }
    
    private func formattedSubtitle() -> String? {
        guard let card = card, let pan = card.getDetailUI().substring(card.getDetailUI().count - 4) else {
            return nil
        }
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
    
    private func displayError(text: String, placeholders: [StringPlaceholder] = []) {
        showError(keyTitle: "generic_alert_title_errorData", keyDesc: text, placeholders: placeholders, completion: nil)
    }
}

extension MobileTopUpPresenter: OperatorInformationProvider {
    var minimumAmount: LocalizedStylableText? {
        guard let minimum = currentOperator?.minimumAmount?.getFormattedAmountUI(0) else {
            return nil
        }
        let placeholderMinimum = StringPlaceholder(.value, minimum)
        
        return stringLoader.getString("mobileRechange_text_miniValue", [placeholderMinimum])
    }
    
    var maximumAmount: LocalizedStylableText? {
        guard let maximum = currentOperator?.maximumAmount?.getFormattedAmountUI(0) else {
            return nil
        }
        let placeholderMaximum = StringPlaceholder(.value, maximum)
        
        return stringLoader.getString("mobileRechange_text_maxValue", [placeholderMaximum])
    }
    
    var intervalAmount: LocalizedStylableText? {
        guard let increment = currentOperator?.sectionAmount?.getFormattedAmountUI(0) else {
            return nil
        }
        let placeholderIncrement = StringPlaceholder(.value, increment)
        
        return stringLoader.getString("mobileRechange_text_multipleValue", [placeholderIncrement])
    }
    
    func operatorName() -> String? {
        return operators?.list[currentOperatorIndex].name
    }
    
}
