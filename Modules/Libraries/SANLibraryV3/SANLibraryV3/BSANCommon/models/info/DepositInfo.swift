import Foundation

public struct DepositInfo: Codable {
    public var depositImpositionsTransactionsDictionary: [String: ImpositionsListDTO] = [:]
    public var impositionsTransactionsDictionary: [String: ImpositionTransactionsListDTO] = [:]
    public var impositionsLiquidationsDictionary: [String: LiquidationTransactionListDTO] = [:]
    public var liquidationDetailsDictionary: [String: LiquidationDetailDTO] = [:]

    public mutating func add(impositionsListDTO: ImpositionsListDTO, contract: String) {
        var newStoredTransactions = [ImpositionDTO]()
        if let storedTransactions = depositImpositionsTransactionsDictionary[contract] {
            newStoredTransactions = storedTransactions.impositionsDTOs
        }
        newStoredTransactions += impositionsListDTO.impositionsDTOs
        depositImpositionsTransactionsDictionary[contract] = ImpositionsListDTO(impositionsDTOs: newStoredTransactions, pagination: impositionsListDTO.pagination)
    }

    public mutating func add(impositionsLiquidationsListDTO: LiquidationTransactionListDTO, contract: String) {
        var newStoredTransactions = [LiquidationDTO]()
        if let storedTransactions = impositionsLiquidationsDictionary[contract],
           let liquidations = storedTransactions.liquidationDTOS {
            newStoredTransactions = liquidations
        }

        if let newLiquidations = impositionsLiquidationsListDTO.liquidationDTOS {
            newStoredTransactions += newLiquidations
            impositionsLiquidationsDictionary[contract] = LiquidationTransactionListDTO(liquidationDTOS: newStoredTransactions, pagination: impositionsLiquidationsListDTO.pagination)
        }
    }

    public mutating func add(impositionTransactionsListDTO: ImpositionTransactionsListDTO, contract: String) {
        impositionsTransactionsDictionary[contract] = impositionTransactionsListDTO
    }
}
