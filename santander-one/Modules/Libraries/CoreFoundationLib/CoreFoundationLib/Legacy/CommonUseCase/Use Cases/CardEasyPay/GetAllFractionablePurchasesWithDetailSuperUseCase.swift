//
//  GetAllFractionablePurchasesWithDetailSuperUseCase.swift
//  CommonUseCase
//
//  Created by Ignacio González Miró on 13/7/21.
//

import Foundation
import SANLegacyLibrary

public protocol GetAllFractionablePurchasesWithDetailSuperUseCaseDelegate: AnyObject {
    func didFinishGetAllPurchasesSuccessfully(with fractionablePurchases: [GetFractionablePurchaseWithDetailOutput])
    func didFinishWithError(_ error: String?)
}

public struct GetFractionablePurchaseWithDetailOutput {
    public var cardEntity: CardEntity
    public var financiableMovement: FinanceableMovementEntity
    public var financiableMovementDetail: FinanceableMovementDetailEntity
}

public final class GetAllFractionablePurchasesWithDetailSuperUseCaseHandler: SuperUseCaseDelegate {
    var fractionablePurchases: [GetFractionablePurchaseWithDetailOutput] = []
    var cardEntities: [CardEntity] = []
    public weak var delegate: GetAllFractionablePurchasesWithDetailSuperUseCaseDelegate?
    
    public func onSuccess() {
        let sortedFractionablePurchases = self.getSortedFractionablePurchases()
        self.delegate?.didFinishGetAllPurchasesSuccessfully(with: sortedFractionablePurchases)
    }
    
    public func onError(error: String?) {
        self.delegate?.didFinishWithError(error)
    }
}

private extension GetAllFractionablePurchasesWithDetailSuperUseCaseHandler {
    func getSortedFractionablePurchases() -> [GetFractionablePurchaseWithDetailOutput] {
        var result: [GetFractionablePurchaseWithDetailOutput] = []
        _ = self.fractionablePurchases.filteredPurchases().compactMap { result.append($0) }
        
        return result
    }
}

public final class GetAllFractionablePurchasesWithDetailSuperUseCase: SuperUseCase<GetAllFractionablePurchasesWithDetailSuperUseCaseHandler> {
    private let dependenciesResolver: DependenciesResolver
    private let handler: GetAllFractionablePurchasesWithDetailSuperUseCaseHandler
    
    public weak var delegate: GetAllFractionablePurchasesWithDetailSuperUseCaseDelegate? {
        get { return self.handler.delegate }
        set { self.handler.delegate = newValue }
    }
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.handler = GetAllFractionablePurchasesWithDetailSuperUseCaseHandler()
        let useCaseHandler = self.dependenciesResolver.resolve(for: UseCaseHandler.self)
        super.init(useCaseHandler: useCaseHandler, delegate: self.handler)
    }
    
    public override func setupUseCases() {
        self.clearEntitiesIfNeeded()
        let visibleCardsUseCase = self.dependenciesResolver.resolve(for: GetVisibleCardsUseCase.self)
        self.add(visibleCardsUseCase) { result in
            let filteredCards = result.cards.filter {
                return $0.isCreditCard && $0.isCardContractHolder && !$0.isDisabled
            }
            filteredCards.forEach(self.loadFractionablePurchasesForCard)
        }
    }
}

private extension GetAllFractionablePurchasesWithDetailSuperUseCase {
    
    func loadFractionablePurchasesForCard(_ card: CardEntity) {
        self.handler.cardEntities.append(card)
        let useCase = self.dependenciesResolver.resolve(for: GetFractionablePurchasesUseCase.self)
        let input = FractionablePurchasesUseCaseInput(
            isEasyPay: true,
            pan: card.formattedPAN ?? ""
        )
        self.add(useCase.setRequestValues(requestValues: input), isMandatory: false) { result in
            guard !result.movements.isEmpty else { return }
            let pendingMovements = result.movements.pendingMovements()
            for movement in pendingMovements {
                self.loadNextPendingFeeForFractionablePurchases(card, movement: movement)
            }
        }
    }
    
    func loadNextPendingFeeForFractionablePurchases(_ card: CardEntity, movement: FinanceableMovementEntity) {
        let input = FractionablePurchaseDetailUseCaseInput(
            movID: movement.identifier ?? "",
            pan: card.formattedPAN ?? ""
        )
        let useCase = dependenciesResolver
            .resolve(for: GetFractionablePurchaseDetailUseCase.self)
            .setRequestValues(requestValues: input)
        self.add(useCase, isMandatory: false) { [weak self] result in
            let output = GetFractionablePurchaseWithDetailOutput(
                cardEntity: card,
                financiableMovement: movement,
                financiableMovementDetail: result.movementDetail
            )
            self?.handler.fractionablePurchases.append(output)
        }
    }
    
    func clearEntitiesIfNeeded() {
        self.removeCardsEntitiesIfNeeded()
        self.removeFractionablePurchasesOutputIfNeeded()
    }
    
    func removeCardsEntitiesIfNeeded() {
        if !self.handler.cardEntities.isEmpty {
            self.handler.cardEntities.removeAll()
        }
    }
    
    func removeFractionablePurchasesOutputIfNeeded() {
        if !self.handler.fractionablePurchases.isEmpty {
            self.handler.fractionablePurchases.removeAll()
        }
    }
}

private extension Array where Element == FinanceableMovementEntity {
    func pendingMovements() -> [FinanceableMovementEntity] {
        let sortedMovements: [FinanceableMovementEntity] = self
            .sorted(by: {
                guard let date1 = $0.date,
                      let date2 = $1.date else {
                          return false
                      }
                return date1.compare(date2) == .orderedDescending
            })
        let pendingMovements = sortedMovements.filter { $0.status == .pending }
        
        return pendingMovements
    }
}

private extension Array where Element == GetFractionablePurchaseWithDetailOutput {
    
    func filteredPurchases() -> [GetFractionablePurchaseWithDetailOutput] {
        let filteredPurchases = self
            .sorted(by: {
                guard let movementDate1 = $0.financiableMovement.date,
                      let movementDate2 = $1.financiableMovement.date,
                      let amortizations1 = $0.financiableMovementDetail.amortizations?.sorted(by: {
                          guard let paymentDate1 = $0.paymentDate,
                                let paymentDate2 = $1.paymentDate else {
                                    return false
                                }
                          return paymentDate1.compare(paymentDate2, options: .numeric) == .orderedDescending
                      }),
                      let amortizations2 = $1.financiableMovementDetail.amortizations?.sorted(by: {
                          guard let paymentDate1 = $0.paymentDate,
                                let paymentDate2 = $1.paymentDate else {
                                    return false
                                }
                          return paymentDate1.compare(paymentDate2, options: .numeric) == .orderedDescending
                      }),
                      let pendingAmortizations1 = amortizations1.last(where: {
                          $0.descriptionPaymentState == .pending
                      }),
                      let pendingAmortizations2 = amortizations2.last(where: {
                          $0.descriptionPaymentState == .pending
                      }),
                      let nextFeeDate1 = pendingAmortizations1.paymentDate,
                      let nextFeeDate2 = pendingAmortizations2.paymentDate,
                      let feeAmount1 = $0.financiableMovementDetail.feeAmount.value?.getDecimalFormattedValue(),
                      let feeAmount2 = $1.financiableMovementDetail.feeAmount.value?.getDecimalFormattedValue()
                else {  return false }
                
                guard nextFeeDate1 == nextFeeDate2 else {
                    // sort by paymentDate
                    return nextFeeDate1.compare(nextFeeDate2, options: .numeric) == .orderedAscending
                }
                guard movementDate1 == movementDate2 else {
                    // sort by movementDate
                    return movementDate1.compare(movementDate2) == .orderedAscending
                }
                // sort by amount
                return feeAmount1.compare(feeAmount2, options: .numeric) == .orderedAscending
            })
            .filter {
                if let amortizations = $0.financiableMovementDetail.amortizations,
                   !amortizations.isEmpty {
                    return true
                }
                return false
            }
        
        return filteredPurchases
    }
}
