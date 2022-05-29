import SANLegacyLibrary
import Foundation
import CoreFoundationLib

class PensionDetail: Pension {
    
    private let pensionDetailDTO: PensionDetailDTO
    
    init(_ dto: PensionDTO, detailDTO: PensionDetailDTO) {
        self.pensionDetailDTO = detailDTO
        super.init(PensionEntity(dto))
    }
    
    public var getLinkedAccountDesc: String? { return pensionDetailDTO.linkedAccountDesc }
    public var getHolder: String? { return pensionDetailDTO.holder }
    public var getDescription: String? { return pensionDetailDTO.pensionDesc }
    public var getValueDate: Date? { return pensionDetailDTO.valueDate }
    public var getValueAmount: String? {
        guard let settlementValueAmount = pensionDetailDTO.settlementValueAmount else { return nil }
        return Amount.createFromDTO(settlementValueAmount).getFormattedAmountUI(5)
    }
    public var getNumberShares: Decimal? { return pensionDetailDTO.sharesNumber }
    public var getTotalStock: String? {
        guard let vestedRightsAmount = pensionDetailDTO.vestedRightsAmount else { return nil }
        return Amount.createFromDTO(vestedRightsAmount).getFormattedAmountUIWith1M()
    }
}
