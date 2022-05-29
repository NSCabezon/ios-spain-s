public protocol NoSepaPayeeRepresentable {
    var swiftCode: String? { get }
    var paymentAccountDescription: String? { get }
    var name: String? { get }
    var town: String? { get }
    var address: String? { get }
    var countryName: String? { get }
    var countryCode: String? { get }
    var residentIndicator: String? { get }
    var bankAddress: String? { get }
    var bankTown: String? { get }
    var bankName: String? { get }
    var bankCountryCode: String? { get }
    var bankCountryName: String? { get }
    var residentDescription: String? { get }
}
