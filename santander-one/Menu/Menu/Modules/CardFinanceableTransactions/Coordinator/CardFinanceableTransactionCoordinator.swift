//
//  CardFinanceableTransactionCoordinator.swift
//  Menu
//
//  Created by Juan Carlos López Robles on 6/24/20.
//

import UI
import CoreFoundationLib
import Foundation

public protocol FinanceableTransactionCoordinatorDelegate: AnyObject {
    func didSelectMenu()
    func didSelectDismiss()
    func gotoCardTransactionDetail(card: CardEntity,
                                   selectedTransaction: CardTransactionEntity,
                                   in transactionList: [CardTransactionEntity])
    func gotoCardEasyPayOperative(card: CardEntity,
                                  transaction: CardTransactionEntity,
                                  easyPayOperativeData: EasyPayOperativeDataEntity?)
}

final class CardFinanceableTransactionCoordinator: ModuleCoordinator {
    weak var navigationController: UINavigationController?
    private let dependenciesEngine: DependenciesDefault
    
    init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController?) {
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.navigationController = navigationController
        self.seupDependencies()
    }
    
    func start() {
        let controller = self.dependenciesEngine.resolve(for: CardFinanceableTransactionViewController.self)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    private func seupDependencies() {
        self.dependenciesEngine.register(for: GetCreditCardUseCase.self) { resolver in
            return DefaultGetCreditCardUseCase(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: GetCardFinanceableTransactionsUseCase.self) { resolver in
            return DafaultGetCardFinanceableTransactionsUseCase()
        }
        self.dependenciesEngine.register(for: CardFinanceableTransactionPresenterProtocol.self) { resolver in
            return CardFinanceableTransactionPresenter(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: GetCardEasyPayOperativeDataUseCase.self) { resolver in
            return GetCardEasyPayOperativeDataUseCase(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: ValidateEasyPayUseCase.self) { resolver in
            return ValidateEasyPayUseCase(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: GetCardTransactionEasyPaySuperUseCase.self) { resolver in
            return GetCardTransactionEasyPaySuperUseCase(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: FirstFeeInfoEasyPayUseCase.self) { resolver in
            return FirstFeeInfoEasyPayUseCase(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: CardFinanceableTransactionViewController.self) { resolver in
            var presenter = resolver.resolve(for: CardFinanceableTransactionPresenterProtocol.self)
            let controller = CardFinanceableTransactionViewController(nibName: "CardFinanceableTransaction", bundle: .module, presenter: presenter)
            presenter.view = controller
            return controller
        }
    }
}
