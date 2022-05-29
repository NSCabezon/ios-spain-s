import SANLegacyLibrary

struct LiquidationDetailList: GenericTransactionProtocol {
    private let dto: LiquidationDetailDTO
    private let liquidationItemDetailDTOList: [LiquidationItemDetail]?
    
    init(_ dto: LiquidationDetailDTO) {
        self.dto = dto
        self.liquidationItemDetailDTOList = dto.liquidationItemDetailDTOList?.map { LiquidationItemDetail(dto: $0) }
    }
    
    var liquidationItemDetailList: [LiquidationItemDetail]? {
        return liquidationItemDetailDTOList
    }
    
    var totalCredit: Amount {
        return Amount.createFromDTO(dto.totalCredit)
    }
    
    var totalDebit: Amount {
        return Amount.createFromDTO(dto.totalDebit)
    }
    
}

extension LiquidationDetailList: Equatable {
    static func == (lhs: LiquidationDetailList, rhs: LiquidationDetailList) -> Bool {
        return lhs.totalCredit == rhs.totalCredit &&
            lhs.totalDebit == rhs.totalDebit
    }    
}
