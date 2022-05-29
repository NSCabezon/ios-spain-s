import SANLegacyLibrary
import Foundation
import CoreFoundationLib
import CoreDomain

class Loan: GenericProduct {
    
    let loanEntity: LoanEntity
    var loanDTO: LoanDTO {
        return loanEntity.dto
    }
    
    init(_ entity: LoanEntity) {
        self.loanEntity = entity
        super.init()
    }
    
    override var productIdentifier: String {
        return loanEntity.productIdentifier
    }
    
    override func getAlias() -> String? {
        return loanEntity.alias
    }
    
    override func getDetailUI() -> String? {
        return loanEntity.contractDescription
    }

    override func getAmountValue() -> Decimal? {
        return loanEntity.currentBalance
    }

    override func getAmountCurrency() -> CurrencyDTO? {
        return loanEntity.currentBalanceCurrency
    }
    
    override func getAliasAndInfo(withCustomAlias alias: String? = nil) -> String {
        return transformToAliasAndInfo(alias: alias ?? getAliasCamelCase()) + " | " + loanEntity.shortContract
    }

    override func getTipoInterv() -> OwnershipTypeDesc? {
        return loanEntity.ownershipTypeDesc
    }
    
    override public func getCounterValueAmountValue() -> Decimal? {
        return loanEntity.counterValueCurrentBalanceAmount
    }
    
    func getContract() -> ContractDO {
        guard let contract = loanEntity.contract else { return ContractDO() }
        return ContractDO(contractDTO: contract.dto)
    }
    
    func getContractShort() -> String {
        return loanEntity.shortContract
    }
}

extension Loan: OperativeParameter {}

extension Loan: Equatable {}

func == (lhs: Loan, rhs: Loan) -> Bool {
    return lhs.loanEntity == rhs.loanEntity
}
