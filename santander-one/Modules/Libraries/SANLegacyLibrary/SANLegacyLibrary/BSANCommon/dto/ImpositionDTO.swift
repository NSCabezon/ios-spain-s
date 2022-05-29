import Foundation

public struct ImpositionDTO: Codable {
    public var openingDate: Date?
    public var dueDate: Date?
    public var settlementAmount: AmountDTO?
    public var TAE: String?
    public var interestCapitalizationIndDesc: String?
    public var renovationIndDesc: String?
    public var impositionSubContract: SubContractDTO?
    public var linkedAccount: ContractDTO?
    public var linkedAccountDesc: String?

    public init() {}
    
    public func getLocalIdentifier() -> String {
        guard let impositionSubcontract = impositionSubContract else {
            return ""
        }
        guard let contract = impositionSubcontract.contract, let subcontractString = impositionSubcontract.subcontractString else {
            return ""
        }
        return contract.formattedValue + subcontractString
    }
}
