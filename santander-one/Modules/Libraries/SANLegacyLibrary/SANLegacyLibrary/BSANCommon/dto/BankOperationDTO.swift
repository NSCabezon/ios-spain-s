import CoreDomain

public struct BankOperationDTO: Codable {
    public var basicOperation: String?
    public var bankOperation: String?
    
    public init(basicOperation: String?, bankOperation: String?) {
        self.basicOperation = basicOperation
        self.bankOperation = bankOperation
    }
}

extension BankOperationDTO: BankOperationRepresentable {}
