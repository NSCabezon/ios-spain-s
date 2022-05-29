import CoreDomain

public protocol BaseProductDTO: Codable {
    var alias: String? { get }
    var contract: ContractDTO? { get }
    var ownershipTypeDesc: OwnershipTypeDesc? { get }
	var currency: CurrencyDTO? { get }
}

