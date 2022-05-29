import Foundation

public struct TransferScheduledListDTO: Codable {
    public var transactionDTOs: [TransferScheduledDTO] = []
    public var paginationDTO = PaginationDTO()
    
    public init() {}
    
    public init(transactionDTOs: [TransferScheduledDTO], paginationDTO: PaginationDTO) {
        self.transactionDTOs = transactionDTOs
        self.paginationDTO = paginationDTO
    }
}
