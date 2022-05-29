import SANLegacyLibrary
import Foundation
import CoreFoundationLib
import CoreDomain

class InsuranceProtection: GenericProduct {
    let insuranceProtectionEntity: InsuranceProtectionEntity
    var insuranceDTO: InsuranceDTO {
        return insuranceProtectionEntity.dto
    }
    var contractId: String? {
        return insuranceDTO.contract?.contratoPKWithNoSpaces
    }
    
    var client: ClientDO? {
        return ClientDO(dto: insuranceDTO.cliente)
    }
    
    init(_ entity: InsuranceProtectionEntity) {
        insuranceProtectionEntity = entity
        super.init()
    }
    
    convenience init(dto: InsuranceDTO) {
        self.init(InsuranceProtectionEntity(dto))
    }
    
    override var productIdentifier: String {
        return insuranceDTO.contract?.formattedValue ?? ""
    }
    
    override func getAlias() -> String {
        return insuranceDTO.contractDescription?.trim() ?? ""
    }
    
    func getContract() -> String? {
        return insuranceDTO.contract?.description.replacingOccurrences(of: " ", with: "")
    }
    
    func getContractShort() -> String {
        guard let contract = getContract() else { return "****" }
        return "***" + (contract.substring(contract.count - 4) ?? "*")
    }
    
    override func getDetailUI() -> String {
        if let reference = insuranceDTO.referenciaExterna?.trim(), !reference.isEmpty {
            return reference
        } else {
            return insuranceDTO.idPoliza?.description ?? ""
        }
    }
    
    override func getAmountValue() -> Decimal? {
        return insuranceDTO.importeSaldoActual?.value
    }
    
    override func getAliasAndInfo(withCustomAlias alias: String? = nil) -> String {
        return transformToAliasAndInfo(alias: alias ?? getAliasCamelCase()) + " | " + getContractShort()
    }
    
    override func getAmountCurrency() -> CurrencyDTO? {
        return insuranceDTO.importeSaldoActual?.currency
    }
    
    override func getTipoInterv() -> OwnershipTypeDesc? {
        return insuranceDTO.ownershipTypeDesc
    }
    
}

extension InsuranceProtection: Equatable {}

func == (lhs: InsuranceProtection, rhs: InsuranceProtection) -> Bool {
    return lhs.getDetailUI() == rhs.getDetailUI()
}
