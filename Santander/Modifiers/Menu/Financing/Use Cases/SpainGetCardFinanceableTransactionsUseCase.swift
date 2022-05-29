//
//  SpainGetCardFinanceableTransactionsUseCase.swift
//  Santander
//
//  Created by Hernán Villamil on 11/3/22.
//

import CoreFoundationLib
import SANLegacyLibrary
import CoreDomain
import OpenCombine

final class SpainGetCardFinanceableTransactionsUseCase: UseCase<GetCardFinanceableTransactionsUseCaseInput, GetCardFinanceableTransactionsUseCaseOkOutput, StringErrorOutput> {
    let dependenciesResolver: DependenciesResolver
    var subscriptions: Set<AnyCancellable> = []
    private let defaultMinimimAmount = Decimal(60)
    private let days = -60
    private var pfm: PfmHelperProtocol
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.pfm = dependenciesResolver.resolve(for: CoreFoundationLib.PfmHelperProtocol.self)
    }
    
    override public func executeUseCase(requestValues: GetCardFinanceableTransactionsUseCaseInput) throws -> UseCaseResponse<GetCardFinanceableTransactionsUseCaseOkOutput, StringErrorOutput> {
        wait(untilFinished: requestValues.card)
        let globalPosition = self.dependenciesResolver.resolve(for: CoreFoundationLib.GlobalPositionRepresentable.self)
        let userId = globalPosition.userCodeType ?? ""
        let startDate = Date().startOfDay().getUtcDate()?.addDay(days: self.days) ?? Date()
        let endDate = Date().getUtcDate() ?? Date()
        let card = requestValues.card
        guard card.isCreditCard, card.isCardContractHolder else {
            return .error(StringErrorOutput(nil))
        }
        let transactions = pfm.getLastMovementsFor(
            userId: userId,
            card: card,
            startDate: startDate,
            endDate: endDate)
            .filter(allowCardEasyPay)
        return .ok(GetCardFinanceableTransactionsUseCaseOkOutput(
            card: card,
            transations: transactions
        ))
    }
    
    public func allowCardEasyPay(_ transaction: CardTransactionEntity) -> Bool {
        guard let amountValue = transaction.amount?.value else { return false }
        guard amountValue < .zero else { return false }
        return abs(amountValue) >= defaultMinimimAmount
    }
}

extension SpainGetCardFinanceableTransactionsUseCase: GetCardFinanceableTransactionsUseCase, CardPFMWaiter {}
