//

import Foundation
public struct FavouriteTransferListDTO: Codable {
    public var favouriteTransfers: [FavouriteTransferDTO] = []
}

public struct FavouriteTransferDTO: Codable {
    public let alias: String?
    public let beneficiaryCountry: String?
    public let destinationAccount: String?
    public let currency: String?
    public let activationDate: String?
    public let bicBeneficiary: String?
    public let transferType: String?
    public let beneficiaryReference: String?
    public let beneficiaryCode: String?
    public let actingCompany: String?
    public let actingType: String?
    public let actingCode: String?
    public let beneficiaryName: String?
    public let beneficiaryAddress: String?
    public let beneficiaryCity: String?
    public let accountType: String?
    public let destinationType: String?
    public let amount: Double?
}

