//

import Foundation
import Fuzi

public struct BillCollectionListDTO: Codable {
    public let billCollections: [BillCollectionDTO]
    public let pagination: PaginationDTO?
    
    public init(billCollections: [BillCollectionDTO], pagination: PaginationDTO?) {
        self.billCollections = billCollections
        self.pagination = pagination
    }
}
