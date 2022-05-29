import SANLegacyLibrary
import CoreFoundationLib
import CoreDomain

final class Favourite {
    static func create(_ dto: PayeeDTO) -> Favourite {
        return Favourite(dto: dto)
    }
    
    private(set) var representable: PayeeRepresentable
    var countryCode: String?
    
    init(dto: PayeeDTO) {
        self.representable = dto
    }
    
    init(favorite: PayeeRepresentable) {
        self.representable = favorite
    }
    
    var alias: String? {
        return representable.payeeDisplayName
    }
    
    var baoName: String? {
        return representable.payeeName
    }
    
    var destinationAccountDescription: String? {
        return representable.destinationAccountDescription
    }
    
    var accountType: String? {
        return representable.accountType
    }
    
    var destinationAccount: String? {
        return representable.destinationAccount
    }
    
    var accountDescription: String? {
        return (accountType?.lowercased() == "c" || accountType?.lowercased() == "d") == true ? destinationAccount?.notWhitespaces() : formatAccount(destinationAccountDescription)
    }
    
    var isNoSepa: Bool {
        return accountType?.lowercased() == "c" ||
            accountType?.lowercased() == "d" ||
            amount?.currency?.currencyType != .eur
    }
    
    var iban: IBAN? {
        guard let iban = representable.ibanRepresentable?.formatted else {
            return nil
        }
        return IBAN.create(fromText: iban)
    }
    
    private func formatAccount(_ number: String?) -> String? {
        guard let ibanString = number else {
            return nil
        }
        let iban = IBAN.create(fromText: ibanString.notWhitespaces())
        return iban.description
    }
    
    var amount: Amount? {
        guard let currencyName = representable.currencyName else {
            return nil
        }
        return Amount.create(value: 0, currency: Currency.create(withName: currencyName))
    }
    
    var payeeCode: String? {
        return representable.payeeCode
    }
    
    var recipientType: String? {
        return representable.recipientType
    }
    
    var favouriteCountryCode: String? {
        return representable.countryCode
    }
    
    /// Returns the account formatted according to the account type (Sepa, No Sepa)
    /// Sepa Spain: ESXX XXXX XXXX XXXX
    /// Other Sepa countries: FRXX XXXXXXXXXXXX
    /// No Sepa: XXXXXXXXXXXXXXXXXX
    var formattedAccount: String? {
        // C and D values means No Sepa Account
        if ["c", "d"].contains(accountType?.lowercased()) {
            return destinationAccount?.notWhitespaces()
        }
        
        return iban?.formatted
    }
    
    func setCountryCode(countryCode: String) {
        self.countryCode = countryCode
    }
}
