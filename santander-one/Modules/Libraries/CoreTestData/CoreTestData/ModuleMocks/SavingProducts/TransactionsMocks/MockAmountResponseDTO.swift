import CoreDomain
import OpenCombine
import SANLegacyLibrary

struct MockAmountResponseDTO: Codable {
    let amount: String
    let currency: String
    
    enum CodingKeys: String, CodingKey {
        case amount = "Amount"
        case currency = "Currency"
    }
}

extension MockAmountResponseDTO: SavingAmountRepresentable {}
extension MockAmountResponseDTO: AmountRepresentable {
    var value: Decimal? {
        return Decimal(string: amount)
    }
    
    var currencyRepresentable: CurrencyRepresentable? {
        return CurrencyDTO(currencyName: currency, currencyType: CurrencyType.parse(currency))
    }
}
