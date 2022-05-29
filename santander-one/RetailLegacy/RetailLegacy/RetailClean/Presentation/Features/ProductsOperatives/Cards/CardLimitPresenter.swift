import Foundation

protocol CardLimitNavigatorProtocol {}

class CardLimitPresenter: OperativeStepPresenter<FormViewController, CardLimitNavigatorProtocol, FormPresenterProtocol> {
    private var dailyATMMaximumLimit: Decimal?
    private var dailyMaximumLimit: Decimal?
    
    override var screenId: String? {
        return TrackerPagePrivate.ModiftCardLimits().page
    }

    struct Constants {
        static let sliderDailyMinimumLimit: Decimal = 20
        static let sliderDailyATMMinimumLimit: Decimal = 20
        static let step = Decimal(10)
        static let fieldDailyMinimumLimit: Decimal = 0.01
        static let fieldDailyATMMinimumLimit: Decimal = 0.01
    }
    
    private enum InputIdentifier: String {
        case atmLimit
        case dailyLimit
    }
    
    override func loadViewData() {
        super.loadViewData()
        view.titleIdentifier = "toolbar_title_limitsModifyCard"
        view.styledTitle = stringLoader.getString("toolbar_title_limitsModifyCard")
        view.continueButton.set(localizedStylableText: stringLoader.getString("generic_button_continue"), state: .normal)
        setupSections()
    }
    
    private func buildCardDescriptionFor(_ card: Card) -> String {
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
    
    private func setupSections() {
        var sections = [StackSection]()

        let parameter: CardLimitManagementOperativeData = containerParameter()
        guard let card = parameter.productSelected else {
            return
        }
        
        let sectionHeader = StackSection()
        let cardDescription = buildCardDescriptionFor(card)
        let header = CardHeaderStackModel(cardTitle: card.getAlias(), cardDescription: cardDescription, titleAmount: stringLoader.getString("credit_balance_availableBalance"), amount: card.getAmountUI(), imageURL: card.buildImageRelativeUrl(true), imageLoader: dependencies.imageLoader, identifier: "cardLimit_cardHeader")
        sectionHeader.add(item: header)
        sections.append(sectionHeader)
        
        let currentDailyATMLimit = card.dailyATMLimit?.value
        dailyATMMaximumLimit = card.dailyATMMaximumLimit?.value

        if card.isCreditCard || card.isDebitCard, let currentDailyATMLimit = currentDailyATMLimit, let dailyATMMaximumLimit = dailyATMMaximumLimit, let atmSection = buildLimitSection(withTitleKey: "limitsModifyCard_label_dailyLimitAtm", identifier: .atmLimit, currentLimit: currentDailyATMLimit, highestLimit: dailyATMMaximumLimit) {
            sections.append(atmSection)
        }

        if card.isDebitCard {
            let separatorSection = StackSection()
            let separator = SeparatorStackModel(size: 2)
            separatorSection.add(item: separator)
            sections.append(separatorSection)
        }

        let currentDailyLimit = card.dailyLimit?.value
        dailyMaximumLimit = card.dailyMaximumLimit?.value

        if card.isDebitCard, let currentDailyLimit = currentDailyLimit, let dailyMaximumLimit = dailyMaximumLimit, let limitSection = buildLimitSection(withTitleKey: "limitsModifyCard_label_dailyLimitShopping", identifier: .dailyLimit, currentLimit: currentDailyLimit, highestLimit: dailyMaximumLimit) {
            sections.append(limitSection)
        }

        view.dataSource.reloadSections(sections: sections)
    }
    
    private func buildLimitSection(withTitleKey titleKey: String, identifier: InputIdentifier, currentLimit: Decimal, highestLimit: Decimal) -> StackSection? {
        let limitSection = StackSection()
        let sliderTitle = TitleLabelStackModel(title: dependencies.stringLoader.getString(titleKey), identifier: "cardLimit_\(identifier)_title", insets: Insets(left: 10, right: 10, top: 30, bottom: 0))
        limitSection.add(item: sliderTitle)
        let amount = NumericStackModel(inputIdentifier: identifier.rawValue, placeholder: nil, currentValue: currentLimit.getFormattedValue(), insets: Insets(left: 10, right: 10, top: 8, bottom: 8))
        limitSection.add(item: amount)
        let sliderLowerLimit = identifier == .atmLimit ? Constants.sliderDailyATMMinimumLimit : Constants.sliderDailyMinimumLimit
        let fieldLowerLimit = identifier == .atmLimit ? Constants.fieldDailyATMMinimumLimit : Constants.fieldDailyMinimumLimit
        
        let minimumText = stringLoader.getString("limitsModifyCard_label_minValue", [StringPlaceholder(.value, fieldLowerLimit.getSmartFormattedValue())])
        let maximumText = stringLoader.getString("limitsModifyCard_label_maxValue", [StringPlaceholder(.value, highestLimit.getSmartFormattedValue())])
        let currentPercentage = percentage(forValue: currentLimit, betweenMinimumValue: fieldLowerLimit, maximumValue: highestLimit)
        let slider = SliderStackModel(inputIdentifier: identifier.rawValue, placeholder: .empty, currentValue: currentPercentage, minimumText: minimumText, maximumText: maximumText)
        slider.didChangeSliderValue = { [weak self] value in
            guard let value = value, let newAmount = self?.amount(forPercentage: value, betweenMinimumValue: sliderLowerLimit, maximumValue: highestLimit) else {
                return
            }
            amount.setCurrentValue(newAmount.getFormattedValue())
        }
        limitSection.add(item: slider)
        
        amount.valueDidChange = { [weak self] newValue in
            guard let newNumber =  newValue?.stringToDecimal, let currentPercentage = self?.percentage(forValue: newNumber, betweenMinimumValue: fieldLowerLimit, maximumValue: highestLimit) else { return }

            slider.setSliderValue?(currentPercentage)
        }
        
        return limitSection
    }
    
    private func percentage(forValue value: Decimal, betweenMinimumValue minimumValue: Decimal, maximumValue: Decimal) -> Float {
        let range = maximumValue - minimumValue
        let enteredValue = value - minimumValue
        
        return ((enteredValue / range) as NSNumber).floatValue
    }
    
    private func amount(forPercentage percentage: Float, betweenMinimumValue minimumValue: Decimal, maximumValue: Decimal) -> Decimal {
        let range = maximumValue - minimumValue
        let amount = (percentage as NSNumber).decimalValue * range
        
        return Decimal(((amount as NSNumber).intValue/(Constants.step as NSNumber).intValue)) * Constants.step + minimumValue
    }
    
    private func dataEnteredForIdentifier(_ identifier: InputIdentifier) -> String? {
        return view.dataSource.findData(identifier: identifier.rawValue)
    }
    
    private func buildSlider(inputIdentifier: String, keyTitle: String, placeholderKey: String?) -> [StackItemProtocol] {
        var items: [StackItemProtocol] = []
        let titleHeader = TitleLabelStackModel(title: dependencies.stringLoader.getString(keyTitle))
        items.append(titleHeader)
        let placeholder: LocalizedStylableText?
        if let placeholderKey = placeholderKey {
            placeholder = dependencies.stringLoader.getString(placeholderKey)
        } else {
            placeholder = nil
        }
        let textFieldModel = TextFieldStackModel(inputIdentifier: inputIdentifier, placeholder: placeholder, maxLength: 50)
        items.append(textFieldModel)
        
        return items
    }
    
}
// MARK: - FormPresenterProtocol

extension CardLimitPresenter: FormPresenterProtocol {
    func onContinueButtonClicked() {
        let parameter: CardLimitManagementOperativeData = containerParameter()
        guard let card = parameter.productSelected else {
            //TODO: Mostrar error (a definir todavia)
            showError(keyDesc: "generic_error_txt")
            return
        }
        
        let currentDailyATMLimit = dataEnteredForIdentifier(.atmLimit)?.stringToDecimal
        let currentDailyLimit = dataEnteredForIdentifier(.dailyLimit)?.stringToDecimal
        
        let input = ValidateCardLimitManagementUseCaseInput(card: card, currentATMLimit: currentDailyATMLimit, minimumATMLimit: Constants.fieldDailyATMMinimumLimit, maximumATMLimit: dailyATMMaximumLimit, currentLimit: currentDailyLimit, minimumLimit: Constants.fieldDailyMinimumLimit, maximumLimit: dailyMaximumLimit)
        showOperativeLoading(titleToUse: nil, subtitleToUse: nil, source: nil)
        UseCaseWrapper(with: useCaseProvider.getValidateCardLimitsUseCase(input: input), useCaseHandler: useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { [weak self] _ in
            self?.hideAllLoadings { [weak self] in
                guard let strongSelf = self, let  currency = card.dailyATMLimit?.currencyDO, let limitValues = self?.makeCardLimitValuesFor(card, newATMValue: currentDailyATMLimit, newLimit: currentDailyLimit, currencies: currency)  else { return }
                
                parameter.cardLimit = limitValues
                strongSelf.container?.stepFinished(presenter: strongSelf)
            }
            }, onError: { [weak self] error in
                self?.hideAllLoadings { [weak self] in
                    let description = error?.errorType.buildString().0
                    let placeholders = error?.errorType.buildString().1 ?? []
                    self?.showError(keyTitle: "generic_alert_title_errorData", keyDesc: description, placeholders: placeholders)
                }
        })
        
    }
    
    private func makeCardLimitValuesFor(_ card: Card, newATMValue: Decimal?, newLimit: Decimal?, currencies: Currency) -> CardLimit? {
        guard let newATMValue = newATMValue else {
            return nil
        }
        let atmLimitAmount = Amount.create(value: newATMValue, currency: currencies)
        if card.isCreditCard {
            
            return .credit(atm: atmLimitAmount)
        }
        
        guard let newLimit = newLimit else {
            return nil
        }
        let limitAmount = Amount.create(value: newLimit, currency: currencies)
        
        return .debit(shopping: limitAmount, atm: atmLimitAmount)
    }
}
