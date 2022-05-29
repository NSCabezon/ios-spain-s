class UpdateUsualTransferOperativeData {
    var favourite: Favourite?
    var currentCountry: SepaCountryInfo?
    var currentCurrency: SepaCurrencyInfo?
    var newCountry: SepaCountryInfo?
    var newCurrency: SepaCurrencyInfo?
    var newBeneficiaryName: String?
    var newDestinationAccount: IBAN?
    
    var sepaList: SepaInfoList? {
        didSet {
            currentCountry = sepaList?.getSepaCountryInfo(favourite?.iban?.countryCode)
            currentCurrency = sepaList?.getSepaCurrencyInfo(favourite?.amount?.currency?.currencyName)
        }
    }
    
    init(favourite: Favourite) {
        self.favourite = favourite
    }
    
    func updatePre(sepaList: SepaInfoList) {
        self.sepaList = sepaList
    }
    
    var typeTransfer: OnePayTransferType? {
        let currentCountry = sepaList?.allCountries.first(where: { $0.code == favourite?.iban?.countryCode })
        
        if currentCountry?.code == "ES" {
            return OnePayTransferType.from(.NATIONAL_SEPA)
        }
        return OnePayTransferType.from(.INTERNATIONAL_SEPA)
    }
}

extension UpdateUsualTransferOperativeData: OperativeParameter {}
