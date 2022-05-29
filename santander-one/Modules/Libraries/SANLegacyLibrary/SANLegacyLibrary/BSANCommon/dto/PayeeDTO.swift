import CoreDomain

public struct PayeeDTO: Codable {
    public var actingTypeCode: String?
    public var actingNumber: String?
    public var beneficiaryBAOName: String
    public var concept: String?
    public var beneficiary: String?
    public var codPayee: String?
    public var iban: IBANDTO? {
        didSet {
            countryCode = iban?.countryCode
        }
    }
    public var accountType: String?
    public var transferAmount: AmountDTO?
    public var recipientType: String?
    public var destinationAccount: String?
    public var payeeId: String?
    public var addressPayee: String?
    public var countryCode: String?
    
    public init() {
        self.beneficiaryBAOName = ""
    }
}

extension PayeeDTO: PayeeRepresentable {
    public var shortAccountNumber: String? {
        guard let last4Numbers = destinationAccount?.suffix(4) else {
            return nil
        }
        return "*" + last4Numbers
    }
    
    public var payeeAlias: String? {
        return beneficiary
    }
    
    public var payeeName: String? {
        return beneficiaryBAOName
    }
    
    public var payeeCode: String? {
        return codPayee
    }
    
    public var currencyName: String? {
        return self.transferAmount?.currency?.currencyName
    }
    
    public var currencySymbol: String? {
        return self.transferAmount?.currency?.currencyType.symbol
    }
    
    public var ibanRepresentable: IBANRepresentable? {
        return self.iban
    }
    
    public var payeeAddress: String? {
        return self.addressPayee
    }
    
    public var baoName: String? {
        return beneficiaryBAOName
    }
    
    /// Returns the account formatted according to the account type (Sepa, No Sepa)
    /// Sepa Spain: ESXX XXXX XXXX XXXX
    /// Other Sepa countries: FRXX XXXXXXXXXXXX
    /// No Sepa: XXXXXXXXXXXXXXXXXX
    public var formattedAccount: String? {
        // C and D values means No Sepa Account
        if ["c", "d"].contains(accountType?.lowercased()) {
            return destinationAccount?.replacingOccurrences(of: " ", with: "")
        }
        return iban?.formatted
    }
    
    public var isNoSepa: Bool {
        return accountType?.lowercased() == "c" ||
        accountType?.lowercased() == "d" ||
        iban?.countryCode == nil
    }
}
