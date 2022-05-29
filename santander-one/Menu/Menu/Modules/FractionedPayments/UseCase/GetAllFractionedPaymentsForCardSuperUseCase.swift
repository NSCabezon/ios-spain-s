import Foundation
import CoreFoundationLib
import SANLegacyLibrary

public protocol GetAllFractionedPaymentsForCardSuperUseCaseDelegate: AnyObject {
    func didFinishGetAllPurchasesSuccessfully(with fractionablePurchases: [GetAllFractionedPaymentsForCardOutput])
    func didFinishWithError(error: String?)
}

public struct GetAllFractionedPaymentsForCardOutput {
    var cardEntity: CardEntity
    var financiableMovements: [FinanceableMovementEntity]
    
    public init(cardEntity: CardEntity, financeableMovements: [FinanceableMovementEntity]) {
        self.cardEntity = cardEntity
        self.financiableMovements = financeableMovements
    }
    
    public func getCardEntity() -> CardEntity {
        cardEntity
    }
    
    public func getFinanceableMovements() -> [FinanceableMovementEntity] {
        financiableMovements
    }
}

public final class GetAllFractionedPaymentsForCardSuperUseCaseDelegateHandler: SuperUseCaseDelegate {
    var fractionablePurchases: [GetAllFractionedPaymentsForCardOutput] = []
    var cardEntities: [CardEntity] = []
    weak var delegate: GetAllFractionedPaymentsForCardSuperUseCaseDelegate?
    
    public func onSuccess() {
        let sortedFractionablePurchases = self.getSortedFractionablePurchases()
        let filteredFractionablePurchases = sortedFractionablePurchases.filter {!$0.getFinanceableMovements().isEmpty}
        self.delegate?.didFinishGetAllPurchasesSuccessfully(with: filteredFractionablePurchases)
    }
    
    public func onError(error: String?) {
        self.delegate?.didFinishWithError(error: error)
    }
    
    func getSortedFractionablePurchases() -> [GetAllFractionedPaymentsForCardOutput] {
        var result: [GetAllFractionedPaymentsForCardOutput] = []
        self.cardEntities.forEach({ cardEntity in
            if let fractionablePurchase = self.fractionablePurchases.first(where: { $0.getCardEntity() == cardEntity }) {
                result.append(fractionablePurchase)
            }
        })
        return result
    }
}

public class GetAllFractionedPaymentsForCardSuperUseCase: SuperUseCase<GetAllFractionedPaymentsForCardSuperUseCaseDelegateHandler> {
    let dependenciesResolver: DependenciesResolver
    let handlerDelegate: GetAllFractionedPaymentsForCardSuperUseCaseDelegateHandler
    var cardEntities: [CardEntity] = []
    
    var timeManager: TimeManager {
        return dependenciesResolver.resolve(for: TimeManager.self)
    }

    public weak var delegate: GetAllFractionedPaymentsForCardSuperUseCaseDelegate? {
        get { return self.handlerDelegate.delegate }
        set { self.handlerDelegate.delegate = newValue }
    }

    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.handlerDelegate = GetAllFractionedPaymentsForCardSuperUseCaseDelegateHandler()
        let useCaseHandler = self.dependenciesResolver.resolve(for: UseCaseHandler.self)
        super.init(useCaseHandler: useCaseHandler, delegate: self.handlerDelegate)
    }

    public override func setupUseCases() {
        self.cardEntities.forEach(self.loadFractionablePurchasesForCard)
    }
        
    public func loadFractionablePurchasesForCard(_ cards: [CardEntity]) {
        self.cardEntities = cards
        self.handlerDelegate.cardEntities = []
        self.execute()
    }
}

private extension GetAllFractionedPaymentsForCardSuperUseCase {
    func loadFractionablePurchasesForCard(_ card: CardEntity) {
        self.handlerDelegate.cardEntities.append(card)
        let sixtyDaysAgoDate = Date().startOfDay().getUtcDate()?.addDay(days: -60) ?? Date()
        let endDate = Date().startOfDay().getUtcDate() ?? Date()
        let dateTo = timeManager.toString(
            date: endDate,
            outputFormat: .yyyyMMdd,
            timeZone: .local
        )
        let dateFrom = timeManager.toString(
            date: sixtyDaysAgoDate,
            outputFormat: .yyyyMMdd
        )
        let input = FractionablePurchasesUseCaseInput(
            isEasyPay: false,
            pan: card.formattedPAN ?? "",
            dateFrom: dateFrom,
            dateTo: dateTo
        )
        let getFractionablePurchasesUseCase = self.dependenciesResolver.resolve(for: GetFractionablePurchasesUseCase.self)
        let useCase = getFractionablePurchasesUseCase.setRequestValues(requestValues: input)
        self.add(useCase, isMandatory: false) { result in
            if result.movements.count > 0 {
                let fractionablePurchase = GetAllFractionedPaymentsForCardOutput(
                    cardEntity: card,
                    financeableMovements: result.movements
                )
                self.handlerDelegate.fractionablePurchases.append(fractionablePurchase)
            }
        }
    }
}
