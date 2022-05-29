import SANLegacyLibrary
import Foundation
import CoreFoundationLib
import CoreDomain

class Portfolio: GenericProduct {
    
    let portfolioEntity: PortfolioEntity
    var portfolioDTO: PortfolioDTO {
        return portfolioEntity.dto
    }
    
    init(_ entity: PortfolioEntity) {
        self.portfolioEntity = entity
        super.init()
    }
    
    convenience init(dto: PortfolioDTO) {
        self.init(PortfolioEntity(dto))
    }
    
    override var productIdentifier: String {
        return portfolioDTO.contract?.formattedValue ?? ""
    }
    
    override func getAlias() -> String {
        return portfolioDTO.alias ?? ""
    }
    
    override func getDetailUI() -> String {
        return portfolioDTO.portfolioId?.trim() ?? ""
    }
    
    override func getAmountValue() -> Decimal? {
        return portfolioDTO.consolidatedBalance?.value
    }
    
    override func getAmountCurrency() -> CurrencyDTO? {
        return portfolioDTO.consolidatedBalance?.currency
    }
    
    override func getTipoInterv() -> OwnershipTypeDesc? {
        return portfolioDTO.ownershipTypeDesc
    }
    
    override func getAliasAndInfo(withCustomAlias alias: String? = nil) -> String {
        return ""
    }
    
    func getHolderName() -> String? {
        return portfolioDTO.holderName
    }
}

extension Portfolio: Equatable {}

func == (lhs: Portfolio, rhs: Portfolio) -> Bool {
    return lhs.getAlias() == rhs.getAlias() &&
        lhs.getDetailUI() == rhs.getDetailUI() &&
        lhs.getAmountValue() == rhs.getAmountValue() &&
        lhs.getAmountCurrency() == rhs.getAmountCurrency() &&
        lhs.getTipoInterv() == rhs.getTipoInterv() &&
        lhs.getHolderName() == rhs.getHolderName()
}

extension CurrencyDTO: Equatable {
}

public func == (lhs: CurrencyDTO, rhs: CurrencyDTO) -> Bool {
    return lhs.currencyName == rhs.currencyName &&
    lhs.currencyType == rhs.currencyType
}
