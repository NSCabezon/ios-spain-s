import CoreDomain
public struct EasyPayContractTransactionListDTO: Codable {
    public var easyPayContractTransactionDTOS: [EasyPayContractTransactionDTO]?
    public var pagination: PaginationDTO?
    
    public init() {}
    
    public init(easyPayContractTransactionDTOS: [EasyPayContractTransactionDTO]?, pagination: PaginationDTO?){
        self.easyPayContractTransactionDTOS = easyPayContractTransactionDTOS
        self.pagination = pagination
    }
}

extension EasyPayContractTransactionListDTO: EasyPayContractTransactionListRepresentable {
    public var transactions: [EasyPayContractTransactionRepresentable]? {
        easyPayContractTransactionDTOS
    }
    
    public var paginationRepresentable: PaginationRepresentable? {
        pagination
    }
}
