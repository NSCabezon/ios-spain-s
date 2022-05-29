import SANLegacyLibrary
import Foundation
import CoreFoundationLib
import CoreDomain

class Fund: GenericProduct {
    
    let fundEntity: FundEntity
    var fundDTO: FundDTO {
        return fundEntity.dto
    }
    
    init(_ entity: FundEntity) {
        self.fundEntity = entity
        super.init()
    }
    
    convenience init(dto: FundDTO) {
        self.init(FundEntity(dto))
    }
    
    var isAllianz: Bool {
        let productSubtypeDTO = fundDTO.productSubtypeDTO
        return productSubtypeDTO?.productType == "831" && productSubtypeDTO?.productSubtype == "002"
    }
    
    override var productIdentifier: String {
        return fundDTO.contract?.formattedValue ?? ""
    }
    
    override func getAlias() -> String? {
        return fundDTO.alias
    }
    
    override func getDetailUI() -> String? {
        return fundDTO.contractDescription?.trim()
    }
    
    override func getAmountValue() -> Decimal? {
        return fundDTO.valueAmount?.value
    }
    
    override func getAmountCurrency() -> CurrencyDTO? {
        return fundDTO.valueAmount?.currency
    }
    
    override func getTipoInterv() -> OwnershipTypeDesc? {
        return fundDTO.ownershipTypeDesc
    }
    
    override func getCounterValueAmountValue() -> Decimal? {
        return fundDTO.countervalueAmount?.value
    }
    
    override func getAliasAndInfo(withCustomAlias alias: String? = nil) -> String {
        return transformToAliasAndInfo(alias: alias ?? getAliasCamelCase()) + " | " + getContractShort()
    }
    
    func getContractPK() -> String {
        guard let contract = fundDTO.contract else { return ""}
        return contract.contratoPK ?? ""
    }
    
    func getContractShort() -> String {
        guard let contract = fundDTO.contractDescription else { return "****" }
        return "***" + (contract.substring(contract.count - 4) ?? "*")
    }
    
}

extension Fund: Equatable {}
extension Fund: OperativeParameter {}

func == (lhs: Fund, rhs: Fund) -> Bool {
    return lhs.getAlias() == rhs.getAlias() &&
    lhs.getDetailUI() == rhs.getDetailUI() &&
    lhs.getAmountValue() == rhs.getAmountValue() &&
    lhs.getTipoInterv() == rhs.getTipoInterv()
}

extension Fund: ProductWebviewParameters {
    var stockCode: String? {
        return nil
    }
    
    var identificationNumber: String? {
        return nil
    }
    
    var family: String? {
        return nil
    }
    
    var fundName: String? {
        return nil
    }
    var portfolioId: String? {
        return nil
    }
    var contractId: String? {
        return fundDTO.contract?.contratoPKWithNoSpaces
    }
}
