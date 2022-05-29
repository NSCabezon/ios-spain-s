import Foundation
import SANLegacyLibrary
import CoreFoundationLib
import CoreDomain

class Deposit: GenericProduct {
    
    static func create(_ from: DepositDTO?) -> Deposit? {
        if let dto = from {
            return Deposit(dto: dto)
        }
        return nil
    }
    
    private(set) var depositDTO: DepositDTO
    
    init(_ depositEntity: DepositEntity) {
        depositDTO = depositEntity.dto
        super.init()
    }
    
    private init(dto: DepositDTO) {
        depositDTO = dto
        super.init()
    }
    
    override var productIdentifier: String {
        return depositDTO.contract?.formattedValue ?? ""
    }
        
    override func getAlias() -> String? {
        return depositDTO.alias
    }
    
    override func getDetailUI() -> String? {
        return depositDTO.contractDescription?.trim()
    }
    
    override func getAmountValue() -> Decimal? {
        return depositDTO.balance?.value
    }
    
    override func getAmountCurrency() -> CurrencyDTO? {
        return depositDTO.balance?.currency
    }
    
    override func getAliasAndInfo(withCustomAlias alias: String? = nil) -> String {
        return transformToAliasAndInfo(alias: alias ?? getAliasCamelCase()) + " | " + getContractShort()
    }
    
    override func getTipoInterv() -> OwnershipTypeDesc? {
        return depositDTO.ownershipTypeDesc
    }
    
    override func getCounterValueAmountValue() -> Decimal? {
        return depositDTO.countervalueCurrentBalance?.value
    }
    
    func getContractShort() -> String {
        guard let contract = depositDTO.contractDescription else { return "****" }
        return "***" + (contract.substring(contract.count - 4) ?? "*")
    }
    
}

extension Deposit: Equatable {}

func == (lhs: Deposit, rhs: Deposit) -> Bool {
    return lhs.getAlias() == rhs.getAlias() &&
        lhs.getDetailUI() == rhs.getDetailUI() &&
        lhs.getAmountValue() == rhs.getAmountValue() &&
        lhs.getTipoInterv() == rhs.getTipoInterv()
}
