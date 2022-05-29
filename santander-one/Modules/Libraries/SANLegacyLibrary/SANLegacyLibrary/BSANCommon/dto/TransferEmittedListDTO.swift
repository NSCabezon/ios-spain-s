import CoreDomain
import Foundation

public struct TransferEmittedListDTO: Codable {
    public var transactionDTOs: [TransferEmittedDTO] = []
    public var paginationDTO = PaginationDTO()
    
    public init() {}
    
    public init(transactionDTOs: [TransferEmittedDTO], paginationDTO: PaginationDTO) {
        self.transactionDTOs = transactionDTOs
        self.paginationDTO = paginationDTO
    }
}
