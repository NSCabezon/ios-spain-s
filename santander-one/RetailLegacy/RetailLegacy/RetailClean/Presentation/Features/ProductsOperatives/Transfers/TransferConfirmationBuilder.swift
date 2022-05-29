import Foundation
import Operative
import CoreFoundationLib
import Transfer
import TransferOperatives

class TransferConfirmationBuilder {
    private let data: ConfirmationTransferBuilderData
    private let dependencies: PresentationComponent
    private var items: [ConfirmationItemViewModel] = []
    
    init(data: ConfirmationTransferBuilderData, dependencies: PresentationComponent) {
        self.data = data
        self.dependencies = dependencies
    }
    
    func addAmount(action: @escaping () -> Void) {
        guard let amount = self.data.transferAmount else { return }
        let moneyDecorator = MoneyDecorator(amount.entity, font: .santander(family: .text, type: .bold, size: 32))
        var isEditable: Bool = true
        if self.dependencies.navigatorProvider.dependenciesEngine.resolve(forOptionalType: OnePayTransferModifierProtocol.self)?.isModifyAmountEnabled == false {
            isEditable = false
        }
        let item = ConfirmationItemViewModel(
            title: localized("confirmation_item_amount"),
            value: moneyDecorator.getFormatedAbsWith1M() ?? NSAttributedString(string: amount.entity.getStringValue()),
            position: .first,
            action: isEditable ? ConfirmationItemAction(title: localized("generic_edit_link"), action: action) : nil,
            accessibilityIdentifier: "confirmation_item_amount"
        )
        self.items.append(item)
    }
    
    func addConcept(action: @escaping () -> Void, isAvailable: Bool = true) {
        var isEditable = isAvailable
        if self.dependencies.navigatorProvider.dependenciesEngine.resolve(forOptionalType: OnePayTransferModifierProtocol.self)?.isModifyOriginAccountEnabled == false {
            isEditable = false
        }
        guard let time = self.data.time else { return }
        let concept: String
        if let transferConcept = data.concept, !transferConcept.isEmpty {
            concept = transferConcept
        } else {
            switch time {
            case .now:
                concept = localized("onePay_label_notConcept").text
            case .periodic, .day:
                concept = localized("onePay_label_genericProgrammed").text
            }
        }
       
        var title: LocalizedStylableText = localized("confirmation_item_description")
        let item = ConfirmationItemViewModel(
            title: title.camelCased(),
            value: concept,
            action: isEditable ? ConfirmationItemAction(title: localized("generic_edit_link"), action: action) : nil,
            accessibilityIdentifier: "confirmation_item_description"
        )
        self.items.append(item)
    }
    
    func addOriginAccount(action: @escaping () -> Void, isAvailable: Bool = true) {
        var isEditable = isAvailable
        if self.dependencies.navigatorProvider.dependenciesEngine.resolve(forOptionalType: OnePayTransferModifierProtocol.self)?.isModifyOriginAccountEnabled == false {
            isEditable = false
        }
        guard let originAccount = self.data.account?.accountEntity else { return }
        let alias = originAccount.alias ?? ""
        let availableAmount = originAccount.currentBalanceAmount?.getStringValue() ?? ""
        var title: LocalizedStylableText = localized("confirmation_label_originAccount")
        let item = ConfirmationItemViewModel(
            title: title.camelCased(),
            value: self.boldRegularAttributedString(bold: alias, regular: availableAmount),
            action: isEditable ? ConfirmationItemAction(title: localized("generic_edit_link"), action: action) : nil,
            accessibilityIdentifier: "confirmation_label_originAccount"
        )
        self.items.append(item)
    }
    
    func addTransferType(action: @escaping () -> Void, isAvailable: Bool = true) {
        var isEditable = isAvailable
        if self.dependencies.navigatorProvider.dependenciesEngine.resolve(forOptionalType: OnePayTransferModifierProtocol.self)?.isModifyTransferTypeEnabled == false {
            isEditable = false
        }
        let comission = self.getTotalComissionAmount() ?? ""
        let title = self.getTransferTypeTitle() ?? ""
        let item = ConfirmationItemViewModel(
            title: localized("confirmation_label_sendType"),
            value: title + comission,
            action: isEditable ? ConfirmationItemAction(title: localized("generic_edit_link"), action: action) : nil,
            accessibilityIdentifier: "confirmation_label_sendType"
        )
        self.items.append(item)
    }
    
    func addPeriodicity(position: ConfirmationItemViewModel.Position = .unknown, action: @escaping () -> Void, isAvailable: Bool = true) {
        guard let time = self.data.time else { return }
        var isEditable = isAvailable
        if self.dependencies.navigatorProvider.dependenciesEngine.resolve(forOptionalType: OnePayTransferModifierProtocol.self)?.isModifyPeriodicityEnabled == false {
            isEditable = false
        }
        switch time {
        case .periodic(let startDate, let endDate, let periodicity, _):
            let periodicityValue: String
            switch periodicity {
            case .monthly: periodicityValue = "confirmation_label_monthly"
            case .quarterly: periodicityValue = "confirmation_label_quarterly"
            case .biannual: periodicityValue = "confirmation_label_biannual"
            case .weekly: periodicityValue = "confirmation_label_weekly"
            case .bimonthly: periodicityValue = "confirmation_label_bimonthly"
            case .annual: periodicityValue = "confirmation_label_annual"
            }
            let item = ConfirmationItemViewModel(
                title: localized("confirmation_item_periodicity"),
                value: localized(periodicityValue),
                position: position,
                info: self.getPeriodicityDates(startDate: startDate, endDate: endDate),
                action: isEditable ? ConfirmationItemAction(title: localized("generic_edit_link"), action: action) : nil )
            self.items.append(item)
        default: break
        }
    }
    
    func addPeriodicity(_ periodicity: String, action: @escaping () -> Void) {
        let item = ConfirmationItemViewModel(
            title: localized("confirmation_item_periodicity"),
            value: NSAttributedString(string: periodicity),
            action: ConfirmationItemAction(title: localized("generic_edit_link"), action: action))
        self.items.append(item)
    }
    
    func addDestinationAccount(action: @escaping () -> Void, isAvailable: Bool = true) {
        guard let destinationAccountIBAN = data.iban else { return }
        var attrib = NSMutableAttributedString(string: destinationAccountIBAN.formatted)
        var isEditable = isAvailable
        if self.dependencies.navigatorProvider.dependenciesEngine.resolve(forOptionalType: OnePayTransferModifierProtocol.self)?.isModifyDestinationAccountEnabled == false {
            isEditable = false
            attrib = NSMutableAttributedString(string: destinationAccountIBAN.description)
        }
        attrib.addAttribute(.font(.santander(family: .text, type: .regular, size: 12.0)))
        attrib.addAttribute(.color(.mediumSanGray))
        let baseUrl = self.dependencies.navigatorProvider.dependenciesEngine.resolve(for: BaseURLProvider.self).baseURL
        let item = ConfirmationItemViewModel(
            title: localized("confirmation_label_destination"),
            value: self.data.name ?? "",
            info: attrib,
            action: isEditable ? ConfirmationItemAction(title: localized("generic_edit_link"), action: action) : nil,
            accessibilityIdentifier: "confirmation_label_destination",
            baseUrl: baseUrl
        )
        self.items.append(item)
    }
    
    func addCountry(action: @escaping () -> Void, isAvailable: Bool = true) {
        var isEditable = isAvailable
        if self.dependencies.navigatorProvider.dependenciesEngine.resolve(forOptionalType: OnePayTransferModifierProtocol.self)?.isModifyCountryEnabled == false {
            isEditable = false
        }
        guard let country = data.country, let currency = data.currency else { return }
        let item = ConfirmationItemViewModel(
            title: localized("confirmation_item_destinationCountry"),
            value: country.name + " - " + currency.name,
            action: isEditable ? ConfirmationItemAction(title: localized("generic_edit_link"), action: action) : nil,
            accessibilityIdentifier: "confirmation_item_destinationCountry"
        )
        self.items.append(item)
    }
    
    func addDate() {
        let issueDate = dependencies.timeManager.toString(date: data.issueDate, outputFormat: .dd_MMM_yyyy)
        var title: LocalizedStylableText = localized("confirmation_item_date")
        if self.dependencies.navigatorProvider.dependenciesEngine.resolve(forOptionalType: OnePayTransferModifierProtocol.self)?.showExecutionDateTitle == true {
            title = localized("confirmation_item_executionDate")
        }
        let item = ConfirmationItemViewModel(
            title: title,
            value: issueDate ?? "",
            position: .last,
            accessibilityIdentifier: "confirmation_item_executionDate"
        )
        self.items.append(item)
    }
    
    func addIssueDate(position: ConfirmationItemViewModel.Position = .unknown, action: @escaping () -> Void) {
        let issueDate = dependencies.timeManager.toString(date: data.issueDate, outputFormat: .dd_MMM_yyyy)
        var isEditable: Bool = true
        if self.dependencies.navigatorProvider.dependenciesEngine.resolve(forOptionalType: OnePayTransferModifierProtocol.self)?.isModifyIssueDataEnabled == false {
            isEditable = false
        }
        let item = ConfirmationItemViewModel(
            title: localized("confirmation_item_issuanceDate"),
            value: issueDate ?? "",
            position: position,
            action: isEditable ? ConfirmationItemAction(title: localized("generic_edit_link"), action: action) : nil,
            accessibilityIdentifier: "confirmation_item_issuanceDate"
        )
        self.items.append(item)
    }
    
    func addMailAmount() {
        let expensesAmount = data.expensesAmount?.getAbsFormattedAmountUI() ?? ""
        let item = ConfirmationItemViewModel(
            title: localized("confirmation_item_mailExpenses"),
            value: expensesAmount,
            accessibilityIdentifier: "confirmation_item_mailExpenses"
        )
        self.items.append(item)
    }
    
    func build() -> [ConfirmationItemViewModel] {
        return self.items
    }
}

private extension TransferConfirmationBuilder {
    func getPeriodicityDates(startDate: Date?, endDate: OnePayTransferTimeEndDate?) -> NSAttributedString? {
        guard let startDateFormatted = dependencies.timeManager.toString(date: startDate, outputFormat: .dd_MMM_yyyy),
            let end = endDate else { return nil }
        let endDateFormatted: String
        switch end {
        case .date(let date):
            endDateFormatted = dependencies.timeManager.toString(date: date, outputFormat: .dd_MMM_yyyy) ?? ""
        case .never:
            endDateFormatted = localized("confirmation_label_indefinite").text
        }
        let attrib = NSMutableAttributedString(string: startDateFormatted + " - " + endDateFormatted)
        attrib.addAttribute(.font(.santander(family: .text, type: .regular, size: 14.0)))
        attrib.addAttribute(.color(.grafite))
        return attrib
    }
    
    /// Returns a string with the following format: `bold (regular)`
    /// - Parameters:
    ///   - bold: The bold part of the string
    ///   - regular: The regular part of the string
    func boldRegularAttributedString(bold: String, regular: String) -> NSAttributedString {
        var regularWithParenthesis = "(" + regular + ")"
        if self.dependencies.navigatorProvider.dependenciesEngine.resolve(forOptionalType: OnePayTransferModifierProtocol.self)?.hideAvailableAmount == true {
            regularWithParenthesis = ""
        }
        let builder = TextStylizer.Builder(fullText: bold + " " + regularWithParenthesis)
        let boldStyle = TextStylizer.Builder.TextStyle(word: bold)
        let regularStyle = TextStylizer.Builder.TextStyle(word: regularWithParenthesis)
        return builder.addPartStyle(part: boldStyle
            .setColor(.lisboaGrayNew)
            .setStyle(.santander(family: .text, type: .bold, size: 14))
        ).addPartStyle(part: regularStyle
            .setColor(.lisboaGrayNew)
            .setStyle(.santander(family: .text, size: 14))
        ).build()
    }
    
    func getTotalComissionAmount() -> String? {
        var totalAmount: Decimal = 0.0
        var currencyTotal = Currency.create(withType: CoreCurrencyDefault.default)
        if let amount = data.bankChargeAmount?.value,
           let currency = data.bankChargeAmount?.currency {
            totalAmount = amount
            currencyTotal = Currency.create(withDTO: currency)
        }
        if totalAmount == 0.0 {
            if self.dependencies.navigatorProvider.dependenciesEngine.resolve(forOptionalType: OnePayTransferModifierProtocol.self)?.isEnabledComissionLabel == false {
                return nil
            } else {
                return " - " + localized("confirmation_label_noCommission")
            }
        } else {
            return " - " + Amount.create(value: totalAmount, currency: currencyTotal).getAbsFormattedAmountUI()
        }
    }
    
    func getTransferTypeTitle() -> String? {
        guard let type = self.data.type else { return nil }
        switch type {
        case .national:
            switch self.data.subType {
            case .urgent?: return localized("confirmation_label_express")
            case .immediate?: return localized("sendMoney_label_immediateSend")
            case .standard?:
                guard let time = self.data.time else { return nil }
                switch time {
                case .now:
                    return localized("confirmation_label_standard")
                case .day:
                    return localized("confirmation_label_programmed")
                case .periodic:
                    return localized("confirmation_label_periodic")
                }
            case .none: return localized("transfer_label_transferAccount")
            }
        case .sepa:
            guard let time = self.data.time else { return nil }
            switch time {
            case .now:
                return localized("confirmation_label_standardSent")
            case .day, .periodic:
                return localized("confirmation_label_standardProgrammedSend")
            }
        case .noSepa:
            return localized("transfer_label_transferAccount")
        }
    }
}

struct ConfirmationTransferBuilderData {
    let account: Account?
    let type: OnePayTransferType?
    let subType: OnePayTransferSubType?
    let time: OnePayTransferTime?
    let currency: SepaCurrencyInfo?
    let country: SepaCountryInfo?
    let iban: IBAN?
    let concept: String?
    let issueDate: Date?
    let bankChargeAmount: Amount?
    let expensesAmount: Amount?
    let transferAmount: Amount?
    let name: String?
    
    init(account: Account?,
         type: OnePayTransferType?,
         subType: OnePayTransferSubType?,
         time: OnePayTransferTime?,
         currency: SepaCurrencyInfo?,
         country: SepaCountryInfo?,
         iban: IBAN?,
         concept: String?,
         issueDate: Date?,
         bankChargeAmount: Amount?,
         expensesAmount: Amount?,
         transferAmount: Amount?,
         name: String?) {
        self.account = account
        self.type = type
        self.subType = subType
        self.time = time
        self.currency = currency
        self.country = country
        self.iban = iban
        self.concept = concept
        self.issueDate = issueDate
        self.bankChargeAmount = bankChargeAmount
        self.expensesAmount = expensesAmount
        self.transferAmount = transferAmount
        self.name = name
    }
}
