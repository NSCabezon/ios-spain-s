import Foundation
import CoreFoundationLib
import CoreDomain

public final class AccountNumberFormatterMock: AccountNumberFormatterProtocol {
    
    public init() {}
    
    public func accountNumberFormat(_ account: AccountRepresentable?) -> String {
        ""
    }
    
    public func accountNumberFormat(_ account: AccountEntity?) -> String {
        ""
    }
    
    public func accountNumberFormat(_ account: AccountDetailEntity?) -> String {
        ""
    }
    
    public func accountNumberFormat(_ accountNumber: String?) -> String {
        ""
    }
    
    public func getIBANFormatted(_ iban: IBANEntity?) -> String {
        ""
    }
    
    public func accountNumberShortFormat(_ account: AccountEntity?) -> String {
        ""
    }
}
