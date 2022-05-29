//
//  AccountTransactionDetailCoordinator.swift
//  Accounts
//
//  Created by Jose Carlos Estela Anguita on 20/11/2019.
//

import UI
import CoreFoundationLib
import SANLegacyLibrary

public protocol AccountTransactionDetailCoordinatorDelegate: AnyObject {
    func didSelectAction(_ action: AccountTransactionDetailAction, _ transaction: AccountTransactionEntity, detail: AccountTransactionDetailEntity?, account: AccountEntity)
    func didSelectMenu()
    func didSelectOffer(offer: OfferEntity)
}

final class AccountTransactionDetailCoordinator: ModuleSectionedCoordinator {
    
    private let accountsDependenciesEngine: DependenciesDefault
    public weak var navigationController: UINavigationController?
    
    public init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController?) {
        self.accountsDependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.navigationController = navigationController
        self.setupDependencies()
    }
    
    func start(_ section: AccountsModuleCoordinator.AccountsSection = .detail) {
        self.accountsDependenciesEngine.register(for: AccountDetailSectionConfiguration.self) { _ in
            return AccountDetailSectionConfiguration(section: section)
        }
        self.navigationController?.blockingPushViewController(accountsDependenciesEngine.resolve(for: AccountTransactionDetailViewController.self), animated: true)
    }
    
    // MARK: - Navigation actions
    
    func didSelectAssociatedTransaction(_ transaction: AccountTransactionEntity, in transactions: [AccountTransactionEntity], for entity: AccountEntity, section: AccountsModuleCoordinator.AccountsSection = .detail) {
        accountsDependenciesEngine.resolve(for: AccountsHomeCoordinator.self).didSelectTransaction(transaction, in: transactions, for: entity, section: section)
    }
    
    func goToAction(type action: AccountTransactionDetailAction, transaction: AccountTransactionEntity, detail: AccountTransactionDetailEntity?, account: AccountEntity) {
        switch action {
        case .share(let shareable):
            if let shareable = shareable {
                self.doShare(for: shareable)
            }
        case .transfers, .payBill:
            accountsDependenciesEngine.resolve(for: AccountTransactionDetailCoordinatorDelegate.self).didSelectAction(action, transaction, detail: detail, account: account)
        default:
            let transactionDetailAction = self.accountsDependenciesEngine.resolve(forOptionalType: AccountTransactionDetailActionProtocol.self)
            if transactionDetailAction?.showComingSoonToast() ?? false {
                Toast.show(localized("generic_alert_notAvailableOperation"))
            } else if !(transactionDetailAction?.didSelectAction(action, for: transaction) ?? false) {
                accountsDependenciesEngine.resolve(for: AccountTransactionDetailCoordinatorDelegate.self)
                    .didSelectAction(action, transaction, detail: detail, account: account)
            }
        }
    }
    
    private func doShare(for shareable: Shareable) {
        guard let controller = self.navigationController?.topViewController else { return }
        let sharedHandler = self.accountsDependenciesEngine.resolve(for: SharedHandler.self)
        sharedHandler.doShare(for: shareable, in: controller)
    }
    
    func dismiss() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func didSelectMenu() {
        accountsDependenciesEngine.resolve(for: AccountTransactionDetailCoordinatorDelegate.self).didSelectMenu()
    }
    
    func didSelectOffer(offer: OfferEntity) {
        accountsDependenciesEngine.resolve(for: AccountTransactionDetailCoordinatorDelegate.self).didSelectOffer(offer: offer)
    }
    
    private func setupDependencies() {
        
        self.accountsDependenciesEngine.register(for: AccountTransactionDetailPresenterProtocol.self) { dependenciesResolver in
            return AccountTransactionDetailPresenter(dependenciesResolver: dependenciesResolver)
        }
        
        self.accountsDependenciesEngine.register(for: AccountTransactionDetailViewProtocol.self) { dependenciesResolver in
            return dependenciesResolver.resolve(for: AccountTransactionDetailViewController.self)
        }
        
        self.accountsDependenciesEngine.register(for: AccountTransactionDetailUseCase.self) { dependenciesResolver in
            return AccountTransactionDetailUseCase(dependenciesResolver: dependenciesResolver)
        }
        
        self.accountsDependenciesEngine.register(for: GetAccountEasyPayUseCase.self) { dependenciesResolver in
            return GetAccountEasyPayUseCase(dependenciesResolver: dependenciesResolver)
        }
        
        self.accountsDependenciesEngine.register(for: AccountTransactionPullOfferConfigurationUseCase.self) { dependenciesResolver in
            return AccountTransactionPullOfferConfigurationUseCase(dependenciesResolver: dependenciesResolver)
        }
        
        self.accountsDependenciesEngine.register(for: GetAssociatedAccountTransactionsUseCase.self) { _ in
            return DefaultGetAssociatedAccountTransactionsUseCase()
        }
        
        self.accountsDependenciesEngine.register(for: AccountsHomeCoordinator.self) { dependenciesResolver in
            return AccountsHomeCoordinator(dependenciesResolver: dependenciesResolver, navigationController: self.navigationController)
        }
        
        self.accountsDependenciesEngine.register(for: AccountTransactionDetailViewController.self) { dependenciesResolver in
            let presenter: AccountTransactionDetailPresenterProtocol = dependenciesResolver.resolve(for: AccountTransactionDetailPresenterProtocol.self)
            let viewController = AccountTransactionDetailViewController(nibName: "AccountTransactionDetail", bundle: Bundle.module, presenter: presenter)
            presenter.view = viewController
            return viewController
        }
        
        self.accountsDependenciesEngine.register(for: AccountTransactionDetailCoordinator.self) { _ in
            return self
        }
        
        self.accountsDependenciesEngine.register(for: SharedHandler.self) { _ in
            return SharedHandler()
        }
        
        self.accountsDependenciesEngine.register(for: GetTransactionCategoryUseCase.self) { resolver in
            return GetTransactionCategoryUseCase(dependenciesResolver: resolver)
        }
        
        self.accountsDependenciesEngine.register(for: GetUserCampaignsUseCase.self) { resolver in
            return GetUserCampaignsUseCase(dependenciesResolver: resolver)
        }
        
        self.accountsDependenciesEngine.register(for: GetAccountMovementsCategoryUseCase.self) { resolver in
            return GetAccountMovementsCategoryUseCase(dependenciesResolver: resolver)
        }
        
        self.accountsDependenciesEngine.register(for: GetBizumSplitExpensesStatusUseCase.self) { resolver in
            return GetBizumSplitExpensesStatusUseCase(dependenciesResolver: resolver)
        }
    }
}
