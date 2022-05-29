class UpdateNoSepaUsualTransferOperativeData {
    let favourite: Favourite
    let noSepaDetail: NoSepaPayeeDetail
    var sepaList: SepaInfoList?
    var allCountries = [SepaCountryInfo]()
    var newEntryMode: NoSepaBankSelectorType?
    var newName: String?
    var newDestinationAccount: String?
    var newPayeeAddress: String?
    var newPayeeLocation: String?
    var newPayeeCountry: String?
    var newBicSwift: String?
    var newBankName: String?
    var newBankAddress: String?
    var newBankLocation: String?
    var newBankCountry: String?

    var payeeName: String? {
        return favourite.baoName
    }
    
    var accountNumber: String? {
        return favourite.destinationAccount
    }
    
    var isIbanType: Bool {
        return noSepaDetail.accountType == .A
    }

    var isBicType: Bool {
        return noSepaDetail.accountType == .C
    }

    var isBankType: Bool {
        return noSepaDetail.accountType == .D
    }
    
    var payeeAddress: String? {
        return noSepaDetail.payeeAddress
    }
    
    var payeeLocation: String? {
        return noSepaDetail.payeeLocation
    }
    
    var payeeCountry: String? {
        return noSepaDetail.payeeCountry
    }
    
    var bicSwift: String? {
        return noSepaDetail.bicSwift
    }
    
    var bankName: String? {
        return noSepaDetail.bankName
    }

    var bankAddress: String? {
        return noSepaDetail.bankAddress
    }
    
    var bankLocation: String? {
        return noSepaDetail.bankLocation
    }
    
    var bankCountry: String? {
        return noSepaDetail.bankCountry
    }
    
    var payeeAlias: String? {
        return noSepaDetail.alias
    }
    
    var transferCountry: String? {
        guard let countryCode = noSepaDetail.destinationCountryCode else {
            return nil
        }
        return countryFor(countryCode)
    }
    
    var transferCountryCode: String? {
        return noSepaDetail.destinationCountryCode
    }
        
    var payeeCurrency: String? {
        let currencyCode = favourite.amount?.currency?.currencyName ?? ""
        let currencyName = sepaList?.currencyFor(currencyCode)
        return currencyName
    }
    
    var transferCurrency: Currency? {
        return favourite.amount?.currencyDO
    }
    
    private var isSepaNoEur: Bool {
        guard let currencyCode = favourite.amount?.currency?.currencyName else {
            return false
        }
        let sepaCountries = sepaList?.allCountries
        let isSepaCountry = sepaCountries?.map { $0.code.uppercased() }.contains(transferCountryCode?.uppercased()) ?? false
        return isSepaCountry && currencyCode != SepaCurrencyInfo.createEuro().code
    }
    
    init(favourite: Favourite, noSepaDetail: NoSepaPayeeDetail) {
        self.favourite = favourite
        self.noSepaDetail = noSepaDetail
    }
    
    private func countryFor(_ countryCode: String) -> String? {
        return allCountries.first(where: { $0.code.uppercased() == countryCode.uppercased() })?.name
    }
    
}

extension UpdateNoSepaUsualTransferOperativeData: OperativeParameter {}
