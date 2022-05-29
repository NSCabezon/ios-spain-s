//
//  AccountNumberFormatterProtocol.swift
//  Commons
//
//  Created by Jose Javier Montes Romero on 7/4/21.
//

import Foundation
import CoreDomain

public protocol AccountNumberFormatterProtocol {
    func accountNumberFormat(_ account: AccountRepresentable?) -> String
    func accountNumberFormat(_ account: AccountEntity?) -> String
    func accountNumberFormat(_ account: AccountDetailEntity?) -> String
    func accountNumberFormat(_ accountNumber: String?) -> String
    func getIBANFormatted(_ iban: IBANEntity?) -> String
    func accountNumberShortFormat(_ account: AccountEntity?) -> String
}

public struct DefaultAccountNumberFormatter: AccountNumberFormatterProtocol {
    public init() {}
    
    public func accountNumberFormat(_ account: AccountRepresentable?) -> String {
        return account?.getIBANString ?? ""
    }
    
    public func accountNumberFormat(_ account: AccountEntity?) -> String {
        return account?.getIBANFormatted ?? ""
    }
    
    public func accountNumberFormat(_ account: AccountDetailEntity?) -> String {
        return account?.description ?? ""
    }
    
    public func accountNumberFormat(_ accountNumber: String?) -> String {
        return accountNumber ?? ""
    }
    
    public func getIBANFormatted(_ iban: IBANEntity?) -> String {
        return iban?.ibanString ?? ""
    }
    
    public func accountNumberShortFormat(_ account: AccountEntity?) -> String {
        return account?.getIBANShort ?? ""
    }
}
