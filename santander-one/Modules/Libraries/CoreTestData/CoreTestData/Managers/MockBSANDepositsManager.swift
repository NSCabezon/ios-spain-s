import SANLegacyLibrary
import CoreDomain

struct MockBSANDepositsManager: BSANDepositsManager {
    func getDepositImpositionsTransactions(depositDTO: DepositDTO, pagination: PaginationDTO?) throws -> BSANResponse<ImpositionsListDTO> {
        fatalError()
    }
    
    func getImpositionTransactions(impositionDTO: ImpositionDTO, pagination: PaginationDTO?, dateFilter: DateFilter?) throws -> BSANResponse<ImpositionTransactionsListDTO> {
        fatalError()
    }
    
    func getImpositionLiquidations(impositionDTO: ImpositionDTO, pagination: PaginationDTO?, dateFilter: DateFilter?) throws -> BSANResponse<LiquidationTransactionListDTO> {
        fatalError()
    }
    
    func getLiquidationDetail(impositionDTO: ImpositionDTO, liquidationDTO: LiquidationDTO) throws -> BSANResponse<LiquidationDetailDTO> {
        fatalError()
    }
    
    func changeDepositAlias(_ deposit: DepositDTO, newAlias: String) throws -> BSANResponse<Void> {
        fatalError()
    }
}
