import Foundation

class CreateNoSepaUsualTransferOperativeData {
    var country: SepaCountryInfo?
    var currency: SepaCurrencyInfo?
    var alias: String?
    var beneficiaryName: String?
    var account: String?
    var noSepaPayee: NoSepaPayee?
    
    var favouriteList: [Favourite]?
    var sepaList: SepaInfoList?
    
    var isSepaNoEur: Bool {
        guard let isSepa = country?.sepa, isSepa, currency != SepaCurrencyInfo.createEuro() else {
            return false
        }
        return true
    }
    
    init(country: SepaCountryInfo, currency: SepaCurrencyInfo, favouriteList: [Favourite]) {
        self.country = country
        self.currency = currency
        self.favouriteList = favouriteList
    }
}

extension CreateNoSepaUsualTransferOperativeData: OperativeParameter {}
