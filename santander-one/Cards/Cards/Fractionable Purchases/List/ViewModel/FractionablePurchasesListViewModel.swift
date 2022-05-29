import UI
import CoreFoundationLib
import SANLegacyLibrary

public class FractionablePurchasesListViewModel {

    var timeManager: TimeManager

    public init(dependenciesResolver: DependenciesResolver) {
        self.timeManager = dependenciesResolver.resolve(for: TimeManager.self)
    }

    public func cardTransaction(from financeableMovementEntity: FinanceableMovementEntity) -> CardTransactionEntity {
        var tempDTO = CardTransactionDTO()
        tempDTO.operationDate = timeManager.fromString(input: financeableMovementEntity.dto.operationDate, inputFormat: .yyyyMMdd)
        tempDTO.amount = financeableMovementEntity.dto.amount
        tempDTO.description = financeableMovementEntity.dto.description
        tempDTO.balanceCode = financeableMovementEntity.dto.balanceCode
        tempDTO.annotationDate = timeManager.fromString(input: financeableMovementEntity.dto.accountingDate, inputFormat: .yyyyMMdd)
        tempDTO.transactionDay = financeableMovementEntity.dto.transactionDay
        tempDTO.originalCurrency = financeableMovementEntity.dto.originalCurrency
        tempDTO.identifier = self.getId(for: financeableMovementEntity)
        return CardTransactionEntity(tempDTO)
    }

    private func getId(for financiableMovementEntity: FinanceableMovementEntity) -> String? {
        guard let date = financiableMovementEntity.dto.operationDate, let movDay = financiableMovementEntity.dto.transactionDay else { return nil }
        return "\(date)_\(movDay)"
    }
}
