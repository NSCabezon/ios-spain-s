import SANLegacyLibrary
import Foundation
import CoreFoundationLib

class FundDetail: Fund {
    
    private let fundDetailDTO: FundDetailDTO
    
    static func create(_ dto: FundDTO, detailDTO: FundDetailDTO) -> FundDetail {
        return FundDetail(dto: dto, fundDetailDTO: detailDTO)
    }
    
    private init(dto: FundDTO, fundDetailDTO: FundDetailDTO) {
        self.fundDetailDTO = fundDetailDTO
        
        super.init(FundEntity(dto))
    }
    
    var contract: ContractDO {
        guard let dto = fundDetailDTO.linkedAccount else { return ContractDO() }
        return ContractDO(contractDTO: dto)
    }

    func getHolder() -> String? { return fundDetailDTO.holder }
    func getLinkedAccountDesc() -> String? { return fundDetailDTO.linkedAccountDesc }
    func getDescription() -> String? { return fundDetailDTO.fundDesc }
    func getValueDate() -> Date? { return fundDetailDTO.valueDate }
    
    func getValueAmount() -> String? {
        let  amount = Amount.createFromDTO(fundDetailDTO.settlementValueAmount)
        return amount.getFormattedAmountUI(5)
    }
    
    func getNumberShares() -> String? {
        guard  let sharesNumber = fundDetailDTO.sharesNumber else { return nil}
            let decimal = NSDecimalNumber(decimal: sharesNumber)
        return formatterForRepresentation(.decimal(decimals: 5)).string(from: decimal)
    }
    
    func getTotalStock() -> String? {
        guard let valueAmount = fundDetailDTO.valueAmount else { return nil }
        let amount = Amount.createFromDTO(valueAmount)
        
        return amount.getFormattedAmountUIWith1M()
    }
    
}
