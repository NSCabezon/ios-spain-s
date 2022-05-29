import CoreFoundationLib
import SANLegacyLibrary
import CoreDomain
import Foundation

struct Amount {
    enum CurrencyFormat {
        case symbol, name, none
    }
    
    private(set) var amountDTO: AmountDTO
    
    var entity: AmountEntity {
        return AmountEntity(amountDTO)
    }

    static func zero() -> Amount {
        var amount = AmountDTO()
        amount.value = 0
        return Amount(dto: amount)
    }
    
    static func createZeroEur() -> Amount {
        var amount = AmountDTO()
        amount.value = 0
        amount.currency = CurrencyDTO.create(.eur)
        return Amount(dto: amount)
    }

    static func createFromDTO(_ dto: AmountDTO?) -> Amount {
        guard let dto = dto, dto.value != nil, dto.currency != nil else {
            return .zero()
        }
        return Amount(dto: dto)
    }
    
    static func create(_ representable: AmountRepresentable) -> Amount {
        guard let value = representable.value,
              let currencyType = representable.currencyRepresentable?.currencyType
        else { return .zero() }
        return Amount.createFromDTO(AmountDTO(value: value, currency: CurrencyDTO.create(currencyType)))
    }
    
    static func createWith(value: Decimal) -> Amount {
        return Amount.createFromDTO(AmountDTO(value: value, currency: CurrencyDTO.create(CoreCurrencyDefault.default)))
    }
    
    static func createWith(value: Decimal, amount: Amount) -> Amount? {
        if let currency = amount.amountDTO.currency {
            let dto = AmountDTO(value: value, currency: currency)
            return createFromDTO(dto)
        }
        return nil
    }
    
    static func create(value: Decimal, currency: Currency) -> Amount {
        return Amount.createFromDTO(AmountDTO(value: value, currency: currency.currencyDTO))
    }
    
    private init(dto: AmountDTO) {
        amountDTO = dto
    }
    
    func getFormattedAmountUI(currencyFormat: CurrencyFormat = .symbol, customCurrency: Currency? = nil, _ numberOfDecimals: Int = 2) -> String {
        let currencyToUse: Currency = customCurrency != nil ? customCurrency!: currencyDO ?? Currency.create(withType: CoreCurrencyDefault.default)
        switch currencyFormat {
        case .name:
            return currencyRepresentationFor(.decimal(decimals: numberOfDecimals), value: NSDecimalNumber(decimal: amountDTO.value!), currencySymbol: currencyToUse.currencyName)
        case .symbol:
            if let symbol: String = currencyToUse.symbol {
                return currencyRepresentationFor(.decimal(decimals: numberOfDecimals), value: NSDecimalNumber(decimal: amountDTO.value!), currencySymbol: symbol)
            } else {
                return currencyRepresentationFor(.decimal(decimals: numberOfDecimals), value: NSDecimalNumber(decimal: amountDTO.value!), currencySymbol: currencyToUse.currencyName)
            }
        case .none:
            return currencyRepresentationFor(.decimal(decimals: numberOfDecimals), value: NSDecimalNumber(decimal: amountDTO.value!), currencySymbol: "")
        }
    }

    func getAbsFormattedAmountUI() -> String {
        return currencyRepresentationFor(.decimal(), value: NSDecimalNumber(decimal: abs(amountDTO.value!)), currencySymbol: currencySymbolUI)
    }
    
    func getFormattedDescriptionAmount(_ numberOfDecimals: Int = 2) -> String {
        return currencyRepresentationFor(.description(decimals: numberOfDecimals), value: NSDecimalNumber(decimal: amountDTO.value!), currencySymbol: currencySymbolUI)
    }
    
    func getFormattedPFMAmount(_ numberOfDecimals: Int = 2) -> String {
        return currencyRepresentationFor(.descriptionPFM(decimals: numberOfDecimals), value: NSDecimalNumber(decimal: amountDTO.value!), currencySymbol: currencySymbolUI)
    }
    
    func getFormattedPFMDescriptionValue(_ numberOfDecimals: Int = 2) -> String {
        let decimal = NSDecimalNumber(decimal: amountDTO.value!)
        return formatterForRepresentation(.descriptionPFM(decimals: numberOfDecimals)).string(from: decimal) ?? "0"
    }
    
    var wholePart: String {
        let decimal = NSDecimalNumber(decimal: amountDTO.value!)
        let valueFormatted = formatterForRepresentation(.wholePart).string(from: decimal)!
        return valueFormatted.split(".")[0]
    }
    
    func getAbsFormattedValue() -> String {
        let decimal = NSDecimalNumber(decimal: abs(amountDTO.value!))
        return formatterForRepresentation(.decimal()).string(from: decimal) ?? "0"
    }
    
    func getFormattedDescriptionValue(_ numberOfDecimals: Int = 2) -> String {
        let decimal = NSDecimalNumber(decimal: amountDTO.value!)
        return formatterForRepresentation(.description(decimals: numberOfDecimals)).string(from: decimal) ?? "0"
    }
    
    func getFormattedValue(_ numberOfDecimals: Int = 2) -> String {
       let decimal = NSDecimalNumber(decimal: amountDTO.value!)
        return formatterForRepresentation(.decimal(decimals: numberOfDecimals)).string(from: decimal) ?? "0"
    }
    
    func getTrackerFormattedValue(_ numberOfDecimals: Int = 2) -> String {
        let decimal = NSDecimalNumber(decimal: amountDTO.value!)
        return formatterForRepresentation(.decimalTracker(decimals: numberOfDecimals)).string(from: decimal) ?? "0"
    }
    
    func getFormattedAmountUIWith1M() -> String {
        guard let value = amountDTO.value else {
            return ""
        }
        let millions = NumberFormattingHandler.shared.millionsThreshold
        if value.magnitude >= millions {
            let decimal = NSDecimalNumber(decimal: value/millions)
            return currencyRepresentationFor(.with1M, value: decimal, currencySymbol: currencySymbol)
        }
        return getFormattedAmountUI()
    }
    
    func getAbsFormattedAmountUIWith1M() -> String {
        guard let amount = amountDTO.value else { return "" }
        let millions = NumberFormattingHandler.shared.millionsThreshold
        if abs(amount) >= millions {
            let decimal = NSDecimalNumber(decimal: abs(amount/millions))
            return currencyRepresentationFor(.with1M, value: decimal, currencySymbol: currencySymbol)
        }
        return getAbsFormattedAmountUI()
    }
  
    var value: Decimal? {
        return amountDTO.value
    }
    
    private var currencySymbolUI: String {
        let currency = CurrencyType.parse(currencyName)
        return currency.symbol ?? "" + currencySymbol
    }
    
    var currencySymbol: String {
        return amountDTO.currency?.getSymbol() ?? ""
    }
    
    var currencyName: String {
        return amountDTO.currency?.currencyName ?? ""
    }
    
    var currency: CurrencyDTO? {
        return amountDTO.currency
    }

    var currencyDO: Currency? {
        guard let currency = amountDTO.currency else { return nil }
        return Currency.create(withDTO: currency)
    }
}

extension Amount: Equatable {
    static func == (lhs: Amount, rhs: Amount) -> Bool {
        return lhs.value == rhs.value && lhs.currency?.currencyName == rhs.currency?.currencyName
    }
}

extension Amount: OperativeParameter {}
