//

import SANLegacyLibrary

struct LiquidationList: GenericTransactionProtocol {
    
    let transactions: [Liquidation]?
    let pagination: PaginationDO?
    
    init?(_ dto: LiquidationTransactionListDTO? = nil) {
        guard dto != nil, let liquidationDTOS = dto?.liquidationDTOS else { return nil }
        self.transactions = liquidationDTOS.map { Liquidation($0) }
        self.pagination = PaginationDO(dto: dto?.pagination)
    }
}
