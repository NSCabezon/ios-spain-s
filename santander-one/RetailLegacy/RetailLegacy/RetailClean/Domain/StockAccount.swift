import SANLegacyLibrary
import Foundation
import CoreFoundationLib
import CoreDomain

enum StockAccountFromPortfolioProduct {
    case notManaged
    case managed
}

class StockAccount: GenericProduct {
    
    static func create(_ from: PortfolioProduct, type: StockAccountFromPortfolioProduct) -> StockAccount {
        var stockAccountDTO = StockAccountDTO()
        stockAccountDTO.contractDescription = from.portfolio?.portfolioDTO.portfolioId
        stockAccountDTO.contract = from.portfolio?.portfolioDTO.stockAccountData?.contract
        stockAccountDTO.ownershipTypeDesc = from.portfolio?.portfolioDTO.ownershipTypeDesc
        stockAccountDTO.valueAmount = from.portfolio?.portfolioDTO.consolidatedBalance
        stockAccountDTO.alias = from.portfolio?.portfolioDTO.alias
        switch type {
        case .notManaged:
            stockAccountDTO.stockAccountType = .RVNotManaged
        case .managed:
            stockAccountDTO.stockAccountType = .RVManaged
        }
        return StockAccount(dto: stockAccountDTO)
    }
    
    let stockAccountEntity: StockAccountEntity
    var stockAccountDTO: StockAccountDTO {
        return stockAccountEntity.dto
    }
    
    init(_ entity: StockAccountEntity) {
        self.stockAccountEntity = entity
        super.init()
    }
    
    convenience init(dto: StockAccountDTO) {
        self.init(StockAccountEntity(dto))
    }
    
    override var productIdentifier: String {
        return stockAccountDTO.contract?.formattedValue ?? ""
    }
    
    override func getAlias() -> String {
        return stockAccountDTO.alias ?? ""
    }
    
    public var stockAccountType: StockAccountType? {
        return stockAccountDTO.stockAccountType
    }
    
    var contract: ContractDO {
        guard let contract = stockAccountDTO.contract else { return ContractDO() }
        return ContractDO(contractDTO: contract)
    }
    
    public func getOriginFromType() -> StockAccountOrigin {
        
        switch self.stockAccountDTO.stockAccountType {
        case .CCV:
            return StockAccountOrigin.regular
        case .RVNotManaged:
            return StockAccountOrigin.rvNotManaged
        case .RVManaged:
            return StockAccountOrigin.rvManaged
        }
    }
    
    override func getDetailUI() -> String {
        if let contractDescription = stockAccountDTO.contractDescription {
            let descTrim = contractDescription.replace(" ", "")
            if descTrim.count != 20 {
                return descTrim
            }
            return "\(descTrim.substring(0, 4) ?? "") \(descTrim.substring(4, 8) ?? "") \(descTrim.substring(8, 10) ?? "") \(descTrim.substring(10, 20) ?? "")"
        }
        return ""
    }
    
    override func getAmountValue() -> Decimal? {
        return stockAccountDTO.valueAmount?.value
    }
    
    override func getAmountCurrency() -> CurrencyDTO? {
        return stockAccountDTO.valueAmount?.currency
    }
    
    override func getTipoInterv() -> OwnershipTypeDesc? {
        return stockAccountDTO.ownershipTypeDesc
    }
    
    override func getCounterValueAmountValue() -> Decimal? {
        return stockAccountDTO.countervalueAmount?.value
    }
    
    func getContractShort() -> String {
        guard let contract = stockAccountDTO.contractDescription else { return "****" }
        return "***" + (contract.substring(contract.count - 4) ?? "*")
    }
    
    override func getAliasAndInfo(withCustomAlias alias: String? = nil) -> String {
        return transformToAliasAndInfo(alias: alias ?? getAliasCamelCase()) + " | " + getContractShort()
    }
    
    func getContract() -> String {
        if let contractDescription = stockAccountDTO.contractDescription {
            return contractDescription.replace(" ", "")
        }
        return ""
    }
}

extension StockAccount: Equatable, Hashable {

    func hash(into hasher: inout Hasher) {
        hasher.combine(productIdentifier)
    }
}

extension StockAccount: OperativeParameter {}

func == (lhs: StockAccount, rhs: StockAccount) -> Bool {
    if let lhsContract = lhs.stockAccountDTO.contract {
        if let rhsContract = rhs.stockAccountDTO.contract, lhsContract.description == rhsContract.description {
            return true
        } else {
            return false
        }
    } else {
        return lhs.stockAccountDTO.referenceCode ==  rhs.stockAccountDTO.referenceCode
    }
}
