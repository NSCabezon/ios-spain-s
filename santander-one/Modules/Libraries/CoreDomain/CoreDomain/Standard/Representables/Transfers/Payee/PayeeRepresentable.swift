//
//  PayeeRepresentable.swift
//  Pods
//
//  Created by Angel Abad Perez on 6/10/21.
//

public protocol PayeeRepresentable {
    var payeeId: String? { get }
    var payeeAlias: String? { get }
    var payeeDisplayName: String? { get }
    var payeeName: String? { get }
    var payeeCode: String? { get }
    var payeeAddress: String? { get }
    var destinationAccountDescription: String { get }
    var currencyName: String? { get }
    var currencySymbol: String? { get }
    var accountType: String? { get }
    var destinationAccount: String? { get }
    var formattedAccount: String? { get }
    var ibanRepresentable: IBANRepresentable? { get }
    var recipientType: String? { get }
    var ibanPapel: String { get }
    var shortIBAN: String { get }
    var shortAccountNumber: String? { get }
    var entityCode: String? { get }
    var countryCode: String? { get set }
    var isNoSepa: Bool { get }
    
    func equalsTo(other: PayeeRepresentable) -> Bool
}

public extension PayeeRepresentable {
    var payeeDisplayName: String? {
        return payeeAlias ?? payeeName
    }
    
    var destinationAccountDescription: String {
        if let countryCode = ibanRepresentable?.countryCode, let checkDigits = ibanRepresentable?.checkDigits, let codBban = ibanRepresentable?.codBban {
            return "\(countryCode)\(checkDigits)\(codBban)"
        }
        return ""
    }
    
    var shortAccountNumber: String? {
        guard let last4Numbers = destinationAccount?.suffix(4) else {
            return nil
        }
        return "*" + last4Numbers
    }
    
    var ibanPapel: String {
        guard let ibanPapel = ibanRepresentable?.ibanPapel else { return "****" }
        return ibanPapel
    }
    
    var shortIBAN: String {
        guard let ibanShort = ibanRepresentable?.ibanShort(showCountryCode: false, asterisksCount: 1, lastDigitsCount: 4) else { return "****" }
        return ibanShort
    }
    
    var entityCode: String? {
        guard let entityCode = self.ibanRepresentable?.getEntityCode(offset: 4) else { return nil }
        return entityCode
    }
    
    func equalsTo(other: PayeeRepresentable) -> Bool {
        return self.payeeDisplayName == other.payeeDisplayName &&
        self.ibanRepresentable?.checkDigits == other.ibanRepresentable?.checkDigits &&
        self.ibanRepresentable?.codBban == other.ibanRepresentable?.codBban &&
        self.ibanRepresentable?.countryCode == other.ibanRepresentable?.countryCode
    }
}
