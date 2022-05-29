import Foundation
import CoreFoundationLib
import SANLegacyLibrary

public final class GetConfigurationCardsUseCase: UseCase<Void, GetConfigurationCardsUseCaseOkOutput, StringErrorOutput> {
    override public func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetConfigurationCardsUseCaseOkOutput, StringErrorOutput> {
        return .ok(GetConfigurationCardsUseCaseOkOutput(cardList: getFakeCards()))
    }
    
    func getFakeCards() -> [ExpenseAnalysisCardInfo] {
        return [
            ExpenseAnalysisCardInfo(
                alias: "Mi tarjeta Advance",
                pan: "*3922",
                isSantanderCard: true,
                imageUrl: nil,
                cardType: .credit,
                balance: AmountEntity(value: -3450, currency: .eur)
            ),
            ExpenseAnalysisCardInfo(
                alias: "Santander débito",
                pan: "*3922",
                isSantanderCard: true,
                imageUrl: nil,
                cardType: .debit,
                balance: .empty
            ),
            ExpenseAnalysisCardInfo(
                alias: "Tarjeta ING",
                pan: "*3922",
                isSantanderCard: false,
                imageUrl: nil,
                cardType: .debit,
                balance: .empty
            )
        ]
    }
}

public struct GetConfigurationCardsUseCaseOkOutput {
    let cardList: [ExpenseAnalysisCardInfo]
}
