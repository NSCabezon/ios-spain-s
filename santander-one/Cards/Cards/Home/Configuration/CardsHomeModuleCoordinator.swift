//
//  CardsHomeCoordinator.swift
//  Cards
//
//  Created by Juan Carlos López Robles on 10/22/19.
//

import CoreFoundationLib
import UI
import SANLegacyLibrary
import CoreDomain
import OpenCombine

public protocol CardsHomeModuleCoordinatorDelegate: AnyObject {
    func didSelectDownloadTransactions(for entity: CardEntity, withFilters: TransactionFiltersEntity?)
    func didSelectDismiss()
    func didSelectMenu()
    func didSelectAction(_ action: OldCardActionType, _ entity: CardEntity)
    func easyPay(entity: CardEntity, transactionEntity: CardTransactionEntity, easyPayOperativeDataEntity: EasyPayOperativeDataEntity?)
    func didSelectSearch(for entity: CardEntity)
    func didSelectAddToApplePay(card: CardEntity?, delegate: ApplePayEnrollmentDelegate)
    func showDialog(acceptTitle: LocalizedStylableText?, cancelTitle: LocalizedStylableText?, title: LocalizedStylableText?, body: LocalizedStylableText?, showsCloseButton: Bool, source: UIViewController, acceptAction: (() -> Void)?, cancelAction: (() -> Void)?)
    func didSelectOffer(offer: OfferRepresentable)
    func didSelectSettlementAction(_ action: NextSettlementActionType, entity: CardEntity)
    func handleOpinator(_ opinator: OpinatorInfoRepresentable)
    func didSelectInExtractPdf(_ cardEntity: CardEntity, selectedMonth: String)
    func goToWebView(configuration: WebViewConfiguration)
    func didGenerateTransactionsPDF(for card: CardEntity, holder: String?, fromDate: Date?, toDate: Date?, transactions: [CardTransactionEntityProtocol], showDisclaimer: Bool)
}

public class CardsHomeModuleCoordinator: ModuleCoordinator {
    private let cardsDependenciesEngine: DependenciesDefault
    public weak var navigationController: UINavigationController?
    private let cardTransactionsSearchCoordinator: CardTransactionsSearchCoordinator
    private let pendingTransactionDetailCoordinator: PendingTransactionDetailCoordinator
    private let otherOperativesCoordinator: OtherOperativesCoordinator
    
    // MARK: - Child coordinators
    private var applePayWelcomeCoordinator: ApplePayWelcomeCoordinator
    private let nextSettlementCoordinator: NextSettlementCoordinator
    private let fractionablePurchasesCoordinator: FractionablePurchasesCoordinator
    private let cardSubscriptionsCoordinator: CardSubscriptionCoordinator
    private let externalDependencies: CardExternalDependenciesResolver
    private var cardHomeCoordinator: CardsHomeModuleCoordinatorDelegate {
        return self.cardsDependenciesEngine.resolve(firstTypeOf: CardsHomeModuleCoordinatorDelegate.self)
    }
    private var childCoordinators: [BindableCoordinator] = []
    private var subscriptions: Set<AnyCancellable> = []
    
    public init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController, externalDependencies: CardExternalDependenciesResolver) {
        self.externalDependencies = externalDependencies
        self.cardsDependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.navigationController = navigationController
        self.otherOperativesCoordinator = OtherOperativesCoordinator(resolver: self.cardsDependenciesEngine, coordinatingViewController: navigationController)
        self.applePayWelcomeCoordinator = ApplePayWelcomeCoordinator(dependenciesResolver: cardsDependenciesEngine, navigationController: navigationController)
        self.cardTransactionsSearchCoordinator = CardTransactionsSearchCoordinator(resolver: self.cardsDependenciesEngine, coordinatingViewController: navigationController)
        self.pendingTransactionDetailCoordinator = PendingTransactionDetailCoordinator(dependenciesResolver: cardsDependenciesEngine, navigationController: navigationController)
        self.nextSettlementCoordinator = NextSettlementCoordinator(dependenciesResolver: self.cardsDependenciesEngine, navigationController: navigationController, externalDependencies: self.externalDependencies)
        self.fractionablePurchasesCoordinator = FractionablePurchasesCoordinator(dependenciesResolver: self.cardsDependenciesEngine, navigationController: navigationController, externalDependencies: externalDependencies)
        self.cardSubscriptionsCoordinator = CardSubscriptionCoordinator(dependenciesResolver: self.cardsDependenciesEngine, navigationController: navigationController, externalDependencies: externalDependencies)
        self.setupDependencies()
    }
    
    public func start() {
        self.navigationController?.blockingPushViewController(self.cardsDependenciesEngine.resolve(for: CardsHomeViewController.self), animated: true)
    }
    
    public func startInTransaction() {
        let cardTransactionDetailCoordinator = self.cardsDependenciesEngine.resolve(for: OldCardTransactionDetailCoordinator.self)
        cardTransactionDetailCoordinator.start()
    }
    
    // MARK: - Internal & Private methods
    
    func start(animated: Bool) {
        self.navigationController?.blockingPushViewController(self.cardsDependenciesEngine.resolve(for: CardsHomeViewController.self), animated: animated)
    }
    
    func goToTransaction(_ transaction: CardTransactionEntity, in transactions: [CardTransactionEntity], for entity: CardEntity) {
        let booleanFeatureFlag: BooleanFeatureFlag = cardsDependenciesEngine.resolve()
        booleanFeatureFlag.fetch(CoreFeatureFlag.cardTransactionDetail)
            .filter { $0 == true }
            .sink { [unowned self] _ in
                externalDependencies
                    .cardTransactionDetailCoordinator()
                    .set(entity.representable)
                    .set(transaction.representable)
                    .start()
            }.store(in: &subscriptions)
        
        booleanFeatureFlag.fetch(CoreFeatureFlag.cardTransactionDetail)
            .filter { $0 == false }
            .sink { [unowned self] _ in
                self.cardsDependenciesEngine.register(for: CardTransactionDetailConfiguration.self) { _ in
                    return CardTransactionDetailConfiguration(selectedCard: entity, selectedTransaction: transaction, allTransactions: transactions)
                }
                let cardTransactionDetailCoordinator = self.cardsDependenciesEngine.resolve(for: OldCardTransactionDetailCoordinator.self)
                cardTransactionDetailCoordinator.start()
            }.store(in: &subscriptions)
    }
    
    func gotoPendingTransaction(_ transaction: CardPendingTransactionEntity, in transactions: [CardPendingTransactionEntity], for entity: CardEntity) {
        self.cardsDependenciesEngine.register(for: PendingTransactionDetailConfiguration.self) { _ in
            return PendingTransactionDetailConfiguration(selectedCard: entity, selectedTransaction: transaction, transactions: transactions)
        }
        self.pendingTransactionDetailCoordinator.start()
    }
    
    func gotToMoreOptions(for card: CardEntity) {
        self.cardsDependenciesEngine.register(for: OtherOperativesConfiguration.self) { _ in
            return OtherOperativesConfiguration(card: card)
        }
        self.otherOperativesCoordinator.start()
    }
    
    func goAddToApplePay(card: CardEntity, delegate: ApplePayEnrollmentDelegate) {
        self.cardsDependenciesEngine.register(for: ApplePayWelcomeConfiguration.self) { _ in
            return ApplePayWelcomeConfiguration(card: card, applePayEnrollmentDelegate: delegate)
        }
        self.cardsDependenciesEngine.register(for: ApplePayWelcomeCoordinatorDelegate.self) { _ in
            return self
        }
        self.applePayWelcomeCoordinator.start()
    }
    
    func goToNextSettlement(_ cardEntity: CardEntity, cardSettlementDetailEntity: CardSettlementDetailEntity, isEnabledMap: Bool) {
        self.cardsDependenciesEngine.register(for: NextSettlementConfiguration.self) { _ in
            return NextSettlementConfiguration(card: cardEntity, cardSettlementDetailEntity: cardSettlementDetailEntity, isMultipleMapEnabled: isEnabledMap)
        }
        self.nextSettlementCoordinator.start()
    }
    
    func goToFractionablePurchases(_ cardEntity: CardEntity) {
        self.cardsDependenciesEngine.register(for: FractionablePurchasesConfiguration.self) { _ in
            return FractionablePurchasesConfiguration(card: cardEntity)
        }
        self.fractionablePurchasesCoordinator.start()
    }
    
    func goToSubscriptionsForCard(_ card: CardEntity) {
        self.cardsDependenciesEngine.register(for: CardControlDistributionConfiguration.self) { _ in
            return CardControlDistributionConfiguration(card: card)
        }
        let coordinator = CardControlDistributionCoordinator(
            dependenciesResolver: cardsDependenciesEngine,
            navigationController: navigationController ?? UINavigationController(),
            externalDependencies: externalDependencies
        )
        coordinator.start()
    }
    
    func didSelectShare(for shareable: Shareable) {
        self.doShare(for: shareable)
    }
    
    func didSelectCVV(_ viewModel: CardViewModel) {
        self.didSelectAction(.cvv, viewModel.entity)
    }
    
    func didSelectActivateCard(_ entity: CardEntity) {
        self.didSelectAction(.enable, entity)
    }
    
    func didSelectShowFilters(_ presenter: CardsHomePresenterProtocol, outsider: CardTransactionFilterOutsider, filter: TransactionFiltersEntity?, card: CardRepresentable) {
        let featureFlag: BooleanFeatureFlag = externalDependencies.resolve()
        featureFlag.fetch(CoreFeatureFlag.cardTransactionFilters)
            .filter { $0 == false }
            .sink { _ in
                self.cardsDependenciesEngine.register(for: CardTransactionsSearchDelegate.self) { _ in
                    return presenter
                }
                self.cardTransactionsSearchCoordinator.start()
            }
            .store(in: &subscriptions)
        featureFlag.fetch(CoreFeatureFlag.cardTransactionFilters)
            .filter { $0 == true }
            .sink { _ in
                let coordinator = self.externalDependencies.cardTransactionFiltersCoordinator()
                coordinator
                    .set(filter?.cardFilters)
                    .set(outsider)
                    .set(card)
                    .start()
            }
            .store(in: &subscriptions)
    }
    
    func goToMapView(_ selectedCard: CardEntity, type: CardMapTypeConfiguration) {
        let coordinator = externalDependencies.shoppingMapCoordinator()
        let configuration = CardMapConfiguration(type: type,
                                                 card: selectedCard.representable)
        coordinator.set(configuration)
        coordinator.start()
    }
    
    func didSelectDownloadTransactions(for entity: CardEntity, withFilters: TransactionFiltersEntity?) {
        self.cardHomeCoordinator.didSelectDownloadTransactions(for: entity, withFilters: withFilters)
    }
    
    func didSelectSearch(for entity: CardEntity) {
        self.cardHomeCoordinator.didSelectSearch(for: entity)
    }
    
    private func doShare(for shareable: Shareable) {
        guard let controller = self.navigationController?.topViewController else { return }
        let sharedHandle = self.cardsDependenciesEngine.resolve(for: SharedHandler.self)
        sharedHandle.doShare(for: shareable, in: controller)
    }
    
    private func setupDependencies() {
        self.cardsDependenciesEngine.register(for: GetCardsHomeUseCase.self) { dependenciesResolver in
            return GetCardsHomeUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.cardsDependenciesEngine.register(for: GetCardTransactionsUseCase.self) { dependenciesResolver in
            return GetCardTransactionsUseCase(dependenciesResolver: dependenciesResolver)
        }
        
        self.cardsDependenciesEngine.register(for: GetCardApplePaySupportUseCase.self) { dependenciesResolver in
            return GetCardApplePaySupportUseCase(dependenciesResolver: dependenciesResolver)
        }
        
        self.cardsDependenciesEngine.register(for: CardsHomePresenterProtocol.self) { dependenciesResolver in
            return CardsHomePresenter(dependenciesResolver: dependenciesResolver)
        }
        
        self.cardsDependenciesEngine.register(for: CardsHomeViewProtocol.self) { dependenciesResolver in
            return dependenciesResolver.resolve(for: CardsHomeViewController.self)
        }
        
        self.cardsDependenciesEngine.register(for: CardsTransactionsManagerProtocol.self) { dependenciesResolver in
            return CardsTransactionsManager(dependenciesResolver: dependenciesResolver)
        }
        
        self.cardsDependenciesEngine.register(for: GetCardPendingTransactionsUseCase.self) { resolver in
            return GetCardPendingTransactionsUseCase(dependenciesResolver: resolver)
        }
        
        self.cardsDependenciesEngine.register(for: GetCardExpensesCalculationUseCase.self) { dependenciesResolver in
            return GetCardExpensesCalculationUseCase(dependenciesResolver: dependenciesResolver)
        }
        
        self.cardsDependenciesEngine.register(for: SetReadCardTransactionsUseCase.self) { dependenciesResolver in
            return SetReadCardTransactionsUseCase(dependenciesResolver: dependenciesResolver)
        }
        
        self.cardsDependenciesEngine.register(for: AddToApplePayConfirmationUseCase.self) { dependenciesResolver in
            return AddToApplePayConfirmationUseCase(dependenciesResolver: dependenciesResolver)
        }
        
        self.cardsDependenciesEngine.register(for: ApplePayEnrollmentManager.self) { dependenciesResolver in
            return ApplePayEnrollmentManager(dependenciesResolver: dependenciesResolver)
        }
        
        self.cardsDependenciesEngine.register(for: GetCardPaymentMethodUseCase.self) { dependenciesResolver in
            return GetCardPaymentMethodUseCase(dependenciesResolver: dependenciesResolver)
        }
        
        self.cardsDependenciesEngine.register(for: GetPullOffersUseCase.self) { dependenciesResolver in
            return GetPullOffersUseCase(dependenciesResolver: dependenciesResolver)
        }
        
        self.cardsDependenciesEngine.register(for: GetCardFinanceableTransactionsUseCase.self) { _ in
            return DafaultGetCardFinanceableTransactionsUseCase()
        }
        
        self.cardsDependenciesEngine.register(for: CardsHomeViewController.self) { dependenciesResolver in
            let presenter: CardsHomePresenterProtocol = dependenciesResolver.resolve(for: CardsHomePresenterProtocol.self)
            let viewController = CardsHomeViewController(nibName: "CardsHome",
                                                         bundle: Bundle.module,
                                                         presenter: presenter,
                                                         dependenciesResolver: dependenciesResolver)
            presenter.view = viewController
            return viewController
        }
        
        self.cardsDependenciesEngine.register(for: CardsHomeModuleCoordinator.self) { _ in
            return self
        }
        
        self.cardsDependenciesEngine.register(for: OldCardTransactionDetailCoordinator.self) { dependenciesResolver in
            return OldCardTransactionDetailCoordinator(dependenciesResolver: self.cardsDependenciesEngine, navigationController: self.navigationController, externalDependencies: self.externalDependencies)
        }
        
        self.cardsDependenciesEngine.register(for: SharedHandler.self) { _ in
            return SharedHandler()
        }
        
        self.cardsDependenciesEngine.register(for: CardsTransactionDetailModuleCoordinatorDelegate.self) { _ in
            return self
        }
        
        self.cardsDependenciesEngine.register(for: CardActionFactoryProtocol.self) { dependenciesResolver in
            return CardActionFactory(dependenciesResolver: dependenciesResolver)
        }
        
        self.cardsDependenciesEngine.register(for: OldGetMinEasyPayAmountUseCase.self) { _ in
            return OldGetMinEasyPayAmountUseCase()
        }
        
        self.cardsDependenciesEngine.register(for: PendingTransactionDetailCoordinatorDelegate.self) { _ in
            return self
        }
        
        self.cardsDependenciesEngine.register(for: GetCardSettlementDetailUseCase.self) { dependenciesResolver in
            return GetCardSettlementDetailUseCase(dependenciesResolver: dependenciesResolver)
        }
        
        self.cardsDependenciesEngine.register(for: FractionablePurchasesCoordinatorProtocol.self) { _ in
            return self.fractionablePurchasesCoordinator
        }
        
        self.cardsDependenciesEngine.resolve(for: CardHomeActionModifier.self)
            .reset()
            .add(CardHomeActionDefaultModifier(dependenciesResolver: self.cardsDependenciesEngine))
            .addExtraModifier()
        
        self.cardsDependenciesEngine.register(for: CardTransactionPullOfferConfigurationUseCase.self) { dependenciesResolver in
            return CardTransactionPullOfferConfigurationUseCase(dependenciesResolver: dependenciesResolver)
        }
        
        self.cardsDependenciesEngine.register(for: GetCheckScaDateUseCase.self) { dependenciesResolver in
            return GetCheckScaDateUseCase(dependenciesResolver: dependenciesResolver)
        }
    }
}

extension CardsHomeModuleCoordinator: ApplePayWelcomeCoordinatorDelegate {
    public func didSelectApplePay(card: CardEntity?, delegate: ApplePayEnrollmentDelegate) {
        let cardHomeCoordinator = self.cardsDependenciesEngine.resolve(for: CardsHomeModuleCoordinatorDelegate.self)
        cardHomeCoordinator.didSelectAddToApplePay(card: card, delegate: delegate)
    }
}

extension CardsHomeModuleCoordinator: CardsTransactionDetailModuleCoordinatorDelegate {
    public func didSelectMenu() {
        self.cardHomeCoordinator.didSelectMenu()
    }
    
    public func didSelectAction(_ action: OldCardActionType, _ entity: CardEntity) {
        switch action {
        case .detail:
            self.goToCardDetail(card: entity)
        case .fractionablePurchases:
            self.goToFractionablePurchases(entity)
        case .subscriptions:
            self.goToSubscriptionsForCard(entity)
        case .share(let shareable):
            guard let shareable = shareable else { return }
            self.doShare(for: shareable)
        default:
            let cardHomeActionModifier = self.cardsDependenciesEngine.resolve(firstTypeOf: CardHomeActionModifier.self)
            cardHomeActionModifier.didSelectAction(action, entity)
        }
    }
    
    public func didSelectDismiss() {
        self.navigationController?.popViewController(animated: true)
    }
    
    public func didSelectOffer(offer: OfferEntity) {
        self.cardHomeCoordinator.didSelectOffer(offer: offer)
    }
    
    public func easyPay(entity: CardEntity, transactionEntity: CardTransactionEntity, easyPayOperativeDataEntity: EasyPayOperativeDataEntity?) {
        cardHomeCoordinator.easyPay(entity: entity, transactionEntity: transactionEntity, easyPayOperativeDataEntity: easyPayOperativeDataEntity)
    }
    
    func goToCardDetail(card: CardEntity) {
        externalDependencies
            .cardDetailCoordinator()
            .set(card.representable)
            .start()
    }
}

extension CardsHomeModuleCoordinator: CardSubscriptionCoordinatorCoordinatorDelegate {}
extension CardsHomeModuleCoordinator: PendingTransactionDetailCoordinatorDelegate {}
