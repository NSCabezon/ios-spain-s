import SANLegacyLibrary
import Foundation
import CoreFoundationLib
import CoreDomain

class InsuranceSaving: GenericProduct {
    let insuranceSavingEntity: InsuranceSavingEntity
    var insuranceDTO: InsuranceDTO {
        return insuranceSavingEntity.dto
    }
    var contractId: String? {
        return insuranceDTO.contract?.contratoPKWithNoSpaces
    }
    
    init(_ entity: InsuranceSavingEntity) {
        self.insuranceSavingEntity = entity
        super.init()
    }
    
    convenience init(dto: InsuranceDTO) {
        self.init(InsuranceSavingEntity(dto))
    }
    
    override var productIdentifier: String {
        return insuranceDTO.contract?.formattedValue ?? ""
    }
    
    override func getAlias() -> String {
        return insuranceDTO.contractDescription?.trim() ?? ""
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
    
    override func getAmountCurrency() -> CurrencyDTO? {
        return insuranceDTO.importeSaldoActual?.currency
    }
    
    override func getTipoInterv() -> OwnershipTypeDesc? {
        return insuranceDTO.ownershipTypeDesc
    }
    
    func getContract() -> String? {
        return insuranceDTO.contract?.description.replacingOccurrences(of: " ", with: "")
    }
    
    func getPolicyNumber() -> String? {
        if let reference = insuranceDTO.referenciaExterna?.trim(), !reference.isEmpty {
            return reference
        } else {
            return insuranceDTO.idPoliza?.description ?? ""
        }
    }
    
    func getContractShort() -> String {
        guard let contract = getContract() else { return "****" }
        return "***" + (contract.substring(contract.count - 4) ?? "*")
    }
    
    override func getAliasAndInfo(withCustomAlias alias: String? = nil) -> String {
        return transformToAliasAndInfo(alias: alias ?? getAliasCamelCase()) + " | " + getContractShort()
    }
}

extension InsuranceSaving: Equatable {}

func == (lhs: InsuranceSaving, rhs: InsuranceSaving) -> Bool {
    return lhs.getDetailUI() == rhs.getDetailUI()
}
