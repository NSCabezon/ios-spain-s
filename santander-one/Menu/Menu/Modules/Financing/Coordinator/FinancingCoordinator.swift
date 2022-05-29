//
//  FinancingCoordinator.swift
//  Menu
//
//  Created by Cristobal Ramos Laina on 23/06/2020.
//

import CoreFoundationLib
import UI
import SANLegacyLibrary
import CoreDomain

public protocol FinancingCoordinatorDelegate: AnyObject {
    func didSelectMenu()
    func didSelectDismiss()
    func didSelectSearch()
    func didSelectOffer(_ offer: OfferRepresentable?)
    func didSelectAdobeTargetOffer(_ viewModel: AdobeTargetOfferViewModel)
    func didSelectCardFinanciableTransaction(_ card: CardEntity, transactionList: [CardTransactionEntity], transaction: CardTransactionEntity)
    func didSelectHireCard(_ location: PullOfferLocation?)
    func didSelectPurchase(_ card: CardEntity, movementId: String, movements: [FinanceableMovementEntity])
    func didSelectShowFractionablePayments(_ paymentType: PaymentBoxType)
}

extension FinancingCoordinatorDelegate {
    func didSelectAdobeTargetOffer(_ viewModel: AdobeTargetOfferViewModel) {}
    func didSelectShowFractionablePayments(_ paymentType: PaymentBoxType) {}
}

protocol FinancingCoordinatorProtocol {
    func didSelectSeeAllFinanceableTransactions(_ card: CardEntity?)
    func didSelectSeeAllAccountFinanceableTransactions(_ account: AccountEntity?)
    func didSelectGoToNextSettlementFor(_ cardEntity: CardEntity, cardSettlementDetailEntity: CardSettlementDetailEntity, isEnabledMap: Bool)
}

final class FinancingCoordinator: ModuleCoordinator {
    
    public weak var navigationController: UINavigationController?
    private let dependenciesEngine: DependenciesDefault
    private let cardFinanceableTransactionCoordinator: CardFinanceableTransactionCoordinator
    private let accountFinanceableTransactionCoordinator: AccountFinanceableTransactionCoordinator
    private let fractionedPaymentsCoordinator: FractionedPaymentsCoordinator
    
    init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.cardFinanceableTransactionCoordinator = CardFinanceableTransactionCoordinator(
            dependenciesResolver: self.dependenciesEngine,
            navigationController: self.navigationController
        )
        self.accountFinanceableTransactionCoordinator = AccountFinanceableTransactionCoordinator(
            dependenciesResolver: self.dependenciesEngine,
            navigationController: self.navigationController
        )
        self.fractionedPaymentsCoordinator = FractionedPaymentsCoordinator(
            dependenciesResolver: self.dependenciesEngine,
            navigationController: self.navigationController
        )
        self.setupDependencies()
    }
    
    func start() {
        let controller = self.dependenciesEngine.resolve(for: FinancingViewController.self)
        self.navigationController?.blockingPushViewController(controller, animated: true)
    }
    
    private func setupDependencies() {
        self.dependenciesEngine.register(for: FinancingPresenterProtocol.self) { dependenciesResolver in
            return FinancingPresenter(dependenciesResolver: dependenciesResolver)
        }

        self.dependenciesEngine.register(for: FinancingDistributionPresenterProtocol.self) { dependenciesResolver in
            return FinancingDistributionPresenter(dependenciesResolver: dependenciesResolver)
        }
        
        self.dependenciesEngine.register(for: GetOffersCandidatesUseCase.self) { dependenciesResolver in
            return GetOffersCandidatesUseCase(dependenciesResolver: dependenciesResolver)
        }
        
        self.dependenciesEngine.register(for: GetAccountsUseCase.self) { resolver in
            return GetAccountsUseCase(dependenciesResolver: resolver)
        }
        
        self.dependenciesEngine.register(for: GetAccountFinanceableTransactionsUseCase.self) { resolver in
            return GetAccountFinanceableTransactionsUseCase(dependenciesResolver: resolver)
        }
        
        self.dependenciesEngine.register(for: GetCardFinanceableTransactionsUseCase.self) { resolver in
            return DafaultGetCardFinanceableTransactionsUseCase()
        }
        
        self.dependenciesEngine.register(for: GetFinancingTricksUseCase.self) { resolver in
            return GetFinancingTricksUseCase(dependenciesResolver: resolver)
        }
        
        self.dependenciesEngine.register(for: LastContributionsUseCase.self) { resolver in
            return LastContributionsUseCase(dependenciesResolver: resolver)
        }
        
        self.dependenciesEngine.register(for: GetAllCardSettlementsSuperUseCase.self) { resolver in
            return GetAllCardSettlementsSuperUseCase(dependenciesResolver: resolver)
        }

        self.dependenciesEngine.register(for: GetCardSettlementDetailUseCase.self) { resolver in
            return GetCardSettlementDetailUseCase(dependenciesResolver: resolver)
        }
        
        self.dependenciesEngine.register(for: FinancingViewController.self) { dependenciesResolver in
            let presenter: FinancingPresenterProtocol = dependenciesResolver.resolve(for: FinancingPresenterProtocol.self)
            let viewController = FinancingViewController(nibName: "FinancingViewController", bundle: Bundle.module, presenter: presenter, dependenciesResolver: self.dependenciesEngine)
            presenter.view = viewController
            return viewController
        }
        
        self.dependenciesEngine.register(for: FinancingDistributionViewController.self) { dependenciesResolver in
            let presenter: FinancingDistributionPresenterProtocol = dependenciesResolver.resolve(for: FinancingDistributionPresenterProtocol.self)
            let viewController = FinancingDistributionViewController(nibName: "FinancingDistributionViewController", bundle: Bundle.module, presenter: presenter)
            presenter.view = viewController
            return viewController
        }
        
        self.dependenciesEngine.register(for: FinanceablePresenterProtocol.self) { dependenciesResolver in
            return FinanceablePresenter(dependenciesResolver: dependenciesResolver)
        }
 
        self.dependenciesEngine.register(for: FinanceableViewController.self) { dependenciesResolver in
            let presenter = dependenciesResolver.resolve(for: FinanceablePresenterProtocol.self)
            let viewController = FinanceableViewController(nibName: "FinanceableViewController", bundle: Bundle.module, presenter: presenter)
            presenter.view = viewController
            return viewController
        }
    
        self.dependenciesEngine.register(for: GetPregrantedLimitsUseCase.self) { dependenciesResolver in
            return GetPregrantedLimitsUseCase(resolver: dependenciesResolver)
        }
        
        self.dependenciesEngine.register(for: GetLoanSimulationLimitsUseCase.self) { dependenciesResolver in
            return GetLoanSimulationLimitsUseCase(managersProvider: dependenciesResolver.resolve())
        }
        
        self.dependenciesEngine.register(for: GetOffersCandidatesUseCase.self) { dependenciesResolver in
            return GetOffersCandidatesUseCase(dependenciesResolver: dependenciesResolver)
        }
        
        self.dependenciesEngine.register(for: GetCreditCardUseCase.self) { dependenciesResolver in
            return DefaultGetCreditCardUseCase(dependenciesResolver: dependenciesResolver)
        }
        
        self.dependenciesEngine.register(for: GetFinanceableConfigurationUseCase.self) { dependenciesResolver in
            return GetFinanceableConfigurationUseCase(dependenciesResolver: dependenciesResolver)
        }
        
        self.dependenciesEngine.register(for: GetAccountEasyPayUseCase.self) { dependenciesResolver in
            return GetAccountEasyPayUseCase(dependenciesResolver: dependenciesResolver)
        }
        
        self.dependenciesEngine.register(for: FinancingCoordinatorProtocol.self) { _ in
            return self
        }
        
        self.dependenciesEngine.register(for: GetPullOffersUseCase.self) { dependenciesResolver in
            return GetPullOffersUseCase(dependenciesResolver: dependenciesResolver)
        }
        
        self.dependenciesEngine.register(for: FinancingDistributionUseCase.self) { dependenciesResolver in
            return FinancingDistributionUseCase(dependenciesResolver: dependenciesResolver)
        }
        
        self.dependenciesEngine.register(for: FinanceableManagerProtocol.self) { dependenciesResolver in
            return FinanceableManager(dependenciesResolver: dependenciesResolver)
        }
        
        // FractionatedPurchasesCarousel
        self.setupFractionatedPurchaseCarousel()
        
        self.dependenciesEngine.register(for: GetFinanceableCommercialOffersUseCase.self) { dependenciesResolver in
            return GetFinanceableCommercialOffersUseCase(dependenciesResolver: dependenciesResolver)
        }
    }
    
    func setupFractionatedPurchaseCarousel() {
        self.dependenciesEngine.register(for: GetFractionablePurchasesUseCase.self) { dependenciesResolver in
            return GetFractionablePurchasesUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: GetFractionablePurchaseDetailUseCase.self) { dependenciesResolver in
            return GetFractionablePurchaseDetailUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: GetVisibleCardsUseCase.self) { dependenciesResolver in
            return GetVisibleCardsUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: GetAllFractionablePurchasesWithDetailSuperUseCase.self) { dependenciesResolver in
            return GetAllFractionablePurchasesWithDetailSuperUseCase(dependenciesResolver: dependenciesResolver)
        }
        
        self.dependenciesEngine.register(for: GetUserCampaignsUseCase.self) { resolver in
            return GetUserCampaignsUseCase(dependenciesResolver: resolver)
        }
    }
}

extension FinancingCoordinator: FinancingCoordinatorProtocol {
    func didSelectSeeAllFinanceableTransactions(_ card: CardEntity?) {
        self.dependenciesEngine.register(for: CardFinanceableTransactionConfiguration.self) { _ in
            return CardFinanceableTransactionConfiguration(selectedCard: card)
        }
        self.fractionedPaymentsCoordinator.start()
    }
    
    func didSelectSeeAllAccountFinanceableTransactions(_ account: AccountEntity?) {
        self.dependenciesEngine.register(for: AccountFinanceableTransactionConfigurationProtocol.self) { _ in
            return AccountFinanceableTransactionConfiguration(selectedAccount: account)
        }
        self.accountFinanceableTransactionCoordinator.start()
    }
    
    func didSelectGoToNextSettlementFor(_ cardEntity: CardEntity, cardSettlementDetailEntity: CardSettlementDetailEntity, isEnabledMap: Bool) {
        let nextSettlementLauncher = self.dependenciesEngine.resolve(for: NextSettlementLauncher.self)
        nextSettlementLauncher.gotoNextSettlement(cardEntity,
                                                  cardSettlementDetailEntity: cardSettlementDetailEntity,
                                                  isEnabledMap: isEnabledMap)
    }
}
