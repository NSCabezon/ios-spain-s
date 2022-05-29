import CoreDomain

public protocol BSANDepositsManager {
    func getDepositImpositionsTransactions(depositDTO: DepositDTO, pagination: PaginationDTO?) throws -> BSANResponse<ImpositionsListDTO>
    func getImpositionTransactions(impositionDTO: ImpositionDTO, pagination: PaginationDTO?, dateFilter: DateFilter?) throws -> BSANResponse<ImpositionTransactionsListDTO>
    func getImpositionLiquidations(impositionDTO: ImpositionDTO, pagination: PaginationDTO?, dateFilter: DateFilter?) throws -> BSANResponse<LiquidationTransactionListDTO>
    func getLiquidationDetail(impositionDTO: ImpositionDTO, liquidationDTO: LiquidationDTO) throws -> BSANResponse<LiquidationDetailDTO>
    func changeDepositAlias(_ deposit: DepositDTO, newAlias: String) throws -> BSANResponse<Void>
}
