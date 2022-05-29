import Foundation

protocol BaseNoSepaPayeeDetailProtocol {
    var transferAmount: Amount { get }
    var payee: NoSepaPayee? { get }
    var concept1: String? { get }
    var bicSwift: String? { get }
    var destinationCountryCode: String? { get }
    var countryCode: String? { get }
    var countryName: String? { get }
}
