import SANLibraryV3
import Foundation
import CoreFoundationLib

struct Amount {
    let amountDTO: AmountDTO
    
    init(amountDTO: AmountDTO) {
        self.amountDTO = amountDTO
    }

    private init(dto: AmountDTO) {
        amountDTO = dto
    }

    static func zero() -> Amount {
        return Amount.createWith(value: 0)
    }
    
    static func createFromDTO(_ dto: AmountDTO?) -> Amount {
        guard let dto = dto, dto.value != nil, dto.currency != nil else {
            return .zero()
            
        }
        return Amount(dto: dto)
    }
    
    static func createWith(value: Decimal) -> Amount {
        return Amount.createFromDTO(AmountDTO(value: value, currency: CurrencyDTO.create(CoreCurrencyDefault.default)))
    }
    
    func getAbsFormattedAmountUI() -> String {
        return "\(getAbsFormattedValue())\(getCurrencyFormmatted())"
    }
    
    var currencySymbol: String {
        return amountDTO.currency?.getSymbol() ?? ""
    }

    func getAbsFormattedValue() -> String {
        let decimal = NSDecimalNumber(decimal: abs(amountDTO.value!))
        return formatterForRepresentation(.decimal()).string(from: decimal) ?? "0"
    }

    func getFormattedAmountUIWith1M() -> String {
        guard let value = amountDTO.value else {
            return ""
        }
        if value.magnitude >= 1000000 {
            let decimal = NSDecimalNumber(decimal: value/1000000)
            let value = formatterForRepresentation(.with1M).string(from: decimal) ?? ""
            return "\(value)M \(currencySymbol)"
        }
        return getFormattedAmountUI()
    }
    
    func getFormattedAmountUI(_ numberOfDecimals: Int? = 2) -> String {
        return "\(getFormattedValue(numberOfDecimals))\(getCurrencyFormmatted())"
    }
    
    func getFormattedValue(_ numberOfDecimals: Int? = 2) -> String {
        let decimal = NSDecimalNumber(decimal: amountDTO.value!)
        return formatterForRepresentation(.decimal(decimals: numberOfDecimals ?? 2)).string(from: decimal) ?? "0"
    }

    private func getCurrencyFormmatted() -> String {
        guard let currencyDTO: CurrencyDTO = amountDTO.currency else {
            return ""
        }
        if let symbol: String = currencyDTO.currencyType.symbol {
            return symbol
        } else {
            return " \(currencyDTO.currencyName)"
        }
    }
}
