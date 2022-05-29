import CoreDomain
import OpenCombine

public struct MockSavingProductTransactionsListDTO: Codable {
    var transactionsDataDTO: MockSavingTransactionDataDTO
    var paginationDTO = MockPaginationDTO()
    
    init(transactionsDataDTO: MockSavingTransactionDataDTO, paginationDTO: MockPaginationDTO) {
        self.transactionsDataDTO = transactionsDataDTO
        self.paginationDTO = paginationDTO
    }
}

extension MockSavingProductTransactionsListDTO: SavingTransactionsResponseRepresentable {
    public var data: SavingTransactionDataRepresentable {
        return transactionsDataDTO
    }
    
    public var pagination: SavingPaginationRepresentable? {
        return paginationDTO
    }
}
