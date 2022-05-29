class CreateUsualTransferOperativeData {
    var country: SepaCountryInfo? = SepaCountryInfo.createSpain()
    var currency: SepaCurrencyInfo? = SepaCurrencyInfo.createEuro()
    var sepaList: SepaInfoList?
    var alias: String?
    var beneficiaryName: String?
    var favouriteList: [Favourite]?
    var iban: IBAN?
    
    var isNoSepa: Bool {
        guard let isCountrySepa = country?.sepa else {
            return false
        }
        return !isCountrySepa || isCountrySepa && currency != SepaCurrencyInfo.createEuro()
    }
}

extension CreateUsualTransferOperativeData: OperativeParameter {}
