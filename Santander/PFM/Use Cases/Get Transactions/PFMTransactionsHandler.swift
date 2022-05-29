//
//  PFMTransactionsUseCase.swift
//  Santander
//
//  Created by José Carlos Estela Anguita on 1/2/22.
//

import Foundation
import CoreFoundationLib
import CoreDomain
import OpenCombine
import SANLegacyLibrary

protocol PFMTransactionsHandler {
    var finishedAccountsPublisher: AnyPublisher<[AccountRepresentable], Never> { get }
    var finishedCardsPublisher: AnyPublisher<[CardRepresentable], Never> { get }
    var finishedMonthsPublisher: AnyPublisher<[MonthlyBalanceRepresentable], Never> { get }
    func reset()
}

final class DefaultPFMTransactionsHandler: PFMTransactionsHandler {
    
    private let dependenciesResolver: DependenciesResolver
    private var pfmController: PfmControllerProtocol {
        return dependenciesResolver.resolve()
    }
    private var finishedAccountsSubject = CurrentValueSubject<[AccountRepresentable], Never>([])
    private var finishedCardsSubject = CurrentValueSubject<[CardRepresentable], Never>([])
    private var finishedMonthsSubject = CurrentValueSubject<[MonthlyBalanceRepresentable], Never>([])
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.pfmController.registerPFMSubscriber(with: self)
    }
    
    deinit {
        self.pfmController.removePFMSubscriber(self)
    }
    
    var finishedAccountsPublisher: AnyPublisher<[AccountRepresentable], Never> {
        return finishedAccountsSubject.eraseToAnyPublisher()
    }
    
    var finishedCardsPublisher: AnyPublisher<[CardRepresentable], Never> {
        return finishedCardsSubject.eraseToAnyPublisher()
    }
    
    var finishedMonthsPublisher: AnyPublisher<[MonthlyBalanceRepresentable], Never> {
        return finishedMonthsSubject.eraseToAnyPublisher()
    }
    
    func reset() {
        finishedAccountsSubject.send([])
        finishedCardsSubject.send([])
        finishedMonthsSubject.send([])
    }
}

extension DefaultPFMTransactionsHandler: PfmControllerSubscriber {
    func finishedPFMAccount(account: AccountEntity) {
        var accounts = finishedAccountsSubject.value
        accounts.append(account.representable)
        finishedAccountsSubject.send(accounts)
    }
    
    func finishedPFMCard(card: CardEntity) {
        var cards = finishedCardsSubject.value
        cards.append(card.representable)
        finishedCardsSubject.send(cards)
    }
    
    func finishedPFM(months: [MonthlyBalanceRepresentable]) {
        finishedMonthsSubject.send(months)
    }
}

protocol CardPFMWaiter: AnyObject {
    var dependenciesResolver: DependenciesResolver { get }
    var subscriptions: Set<AnyCancellable> { get set }
    func wait(untilFinished card: CardEntity)
}

extension CardPFMWaiter {
    
    var handler: PFMTransactionsHandler {
        return dependenciesResolver.resolve()
    }
    
    var pfmController: PfmControllerProtocol {
        return dependenciesResolver.resolve()
    }
    
    func wait(untilFinished card: CardEntity) {
        guard !pfmController.isPFMCardReady(card: card) else { return }
        handler.finishedCardsPublisher
            .wait(
                until: { $0.contains(where: { $0.uniqueIdentifier == card.representable.uniqueIdentifier }) },
                storeIn: &subscriptions
            )
    }
}

protocol AccountPFMWaiter: AnyObject {
    var dependenciesResolver: DependenciesResolver { get }
    var subscriptions: Set<AnyCancellable> { get set }
    func wait(untilFinished account: AccountEntity)
}

extension AccountPFMWaiter {
    
    var handler: PFMTransactionsHandler {
        return dependenciesResolver.resolve()
    }
    
    var pfmController: PfmControllerProtocol {
        return dependenciesResolver.resolve(for: PfmControllerProtocol.self)
    }
    
    func wait(untilFinished account: AccountEntity) {
        guard !pfmController.isPFMAccountReady(account: account) else { return }
        handler.finishedAccountsPublisher
            .wait(
                until: { $0.contains(where: { $0.equalsTo(other: account.representable) }) },
                storeIn: &subscriptions
            )
    }
}

protocol MonthsPFMWaiter: AnyObject {
    var dependenciesResolver: DependenciesResolver { get }
    var subscriptions: Set<AnyCancellable> { get set }
    func waitUntilMonthsFinished()
}

extension MonthsPFMWaiter {
    
    var handler: PFMTransactionsHandler {
        return dependenciesResolver.resolve()
    }
    
    var pfmController: PfmControllerProtocol {
        return dependenciesResolver.resolve(for: PfmControllerProtocol.self)
    }
    
    func waitUntilMonthsFinished() {
        guard pfmController.monthsHistory == nil else { return }
        handler.finishedMonthsPublisher
            .wait(
                until: { $0.isNotEmpty },
                storeIn: &subscriptions
            )
    }
}

private extension OpenCombine.Publisher where Failure == Never {
    
    func wait(until condition: @escaping (Output) -> Bool, storeIn subscriptions: inout Set<AnyCancellable>) {
        let semaphore = DispatchSemaphore(value: 0)
        filter(condition)
            .sink { _ in
                semaphore.signal()
            }
            .store(in: &subscriptions)
        semaphore.wait()
    }
}
