//
//  GetAllFractionablePurchasesSuperUseCase.swift
//  Cards
//
//  Created by Johnatan Zavaleta Milla on 07/07/2021.
//

import Foundation
import SANLegacyLibrary

public protocol GetAllFractionablePurchasesSuperUseCaseDelegate: AnyObject {
    func didFinishGetAllPurchasesSuccessfully(with fractionablePurchases: [GetAllFractionablePurchasesOutput])
    func didFinishWithError(error: String?)
}

public struct GetAllFractionablePurchasesOutput {
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

public final class GetAllFractionablePurchasesSuperUseCaseDelegateHandler: SuperUseCaseDelegate {
    var fractionablePurchases: [GetAllFractionablePurchasesOutput] = []
    var cardEntities: [CardEntity] = []
    weak var delegate: GetAllFractionablePurchasesSuperUseCaseDelegate?
    
    public func onSuccess() {
        let sortedFractionablePurchases = self.getSortedFractionablePurchases()
        let filteredFractionablePurchases = sortedFractionablePurchases.filter {!$0.getFinanceableMovements().isEmpty}
        self.delegate?.didFinishGetAllPurchasesSuccessfully(with: filteredFractionablePurchases)
    }
    
    public func onError(error: String?) {
        self.delegate?.didFinishWithError(error: error)
    }
    
    func getSortedFractionablePurchases() -> [GetAllFractionablePurchasesOutput] {
        var result: [GetAllFractionablePurchasesOutput] = []
        self.cardEntities.forEach({ cardEntity in
            if let fractionablePurchase = self.fractionablePurchases.first(where: { $0.getCardEntity() == cardEntity }) {
                result.append(fractionablePurchase)
            }
        })
        return result
    }
}

public final class GetAllFractionablePurchasesSuperUseCase: SuperUseCase<GetAllFractionablePurchasesSuperUseCaseDelegateHandler> {
    let dependenciesResolver: DependenciesResolver
    let handlerDelegate: GetAllFractionablePurchasesSuperUseCaseDelegateHandler
    var timeManager: TimeManager {
        return dependenciesResolver.resolve(for: TimeManager.self)
    }

    public weak var delegate: GetAllFractionablePurchasesSuperUseCaseDelegate? {
        get { return self.handlerDelegate.delegate }
        set { self.handlerDelegate.delegate = newValue }
    }

    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.handlerDelegate = GetAllFractionablePurchasesSuperUseCaseDelegateHandler()
        let useCaseHandler = self.dependenciesResolver.resolve(for: UseCaseHandler.self)
        super.init(useCaseHandler: useCaseHandler, delegate: self.handlerDelegate)
    }

    public override func setupUseCases() {
        let visibleCardsUseCase = self.dependenciesResolver.resolve(for: GetVisibleCardsUseCase.self)
        self.add(visibleCardsUseCase) { result in
            let filteredCards = result.cards.filter {
                return $0.isCreditCard && $0.isCardContractHolder && !$0.isDisabled
            }
            filteredCards.forEach(self.loadFractionablePurchasesForCard)
        }
    }
}

private extension GetAllFractionablePurchasesSuperUseCase {
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
                let fractionablePurchase = GetAllFractionablePurchasesOutput(
                    cardEntity: card,
                    financeableMovements: result.movements
                )
                self.handlerDelegate.fractionablePurchases.append(fractionablePurchase)
            }
        }
    }
}
