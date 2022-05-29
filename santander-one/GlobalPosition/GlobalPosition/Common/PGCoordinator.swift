import UI
import CoreFoundationLib
import CoreDomain
import OfferCarousel

protocol GlobalPositionModuleCoordinatorProtocol {
    func didSelectDeposit(deposit: DepositEntity)
    func didSelectFund(fund: FundEntity)
    func didSelectInsuranceProtection(insurance: InsuranceProtectionEntity)
}

public protocol GlobalPositionModuleCoordinatorDelegate: AnyObject, OtherOperativesActionDelegate {
    func didSelectAccount(account: AccountEntity)
    func didSelectAccountMovement(movement: AccountTransactionEntity, in account: AccountEntity)
    func didSelectCard(card: CardEntity)
    func didSelectFund(fund: FundEntity)
    func didSelectInsuranceSaving(insurance: InsuranceSavingEntity)
    func didSelectInsuranceProtection(insurance: InsuranceProtectionEntity)
    func didSelectLoan(loan: LoanEntity)
    func didSelectPension(pension: PensionEntity)
    func didSelectPortfolio(portfolio: PortfolioEntity)
    func didSelectManagedPortfolio(portfolio: PortfolioEntity)
    func didSelectNotManagedPortfolio(portfolio: PortfolioEntity)
    func didSelectStockAccount(stockAccount: StockAccountEntity)
    func didSelectDeposit(deposit: DepositEntity)
    func didSelectSavingProduct(savingProduct: SavingProductEntity)
    func addFavourite()
    func didSelectBalance()
    func didSelectMenu()
    func goToNewShipment()
    func globalPositionDidLoad()
    func globalPositionDidReload()
    func globalPositionDidAppear()
    func globalPositionDidDisappear()
    func didSelectSearch()
    func didSelectMail()
    func didSelectBox(isCollapsed: Bool, id: String)
    func didActivateCard(_ card: Any?)
    func didTurnOnCard(_ card: Any?)
    func didSelectConfigureGP()
    func didSelectConfigureGPProducts()
    func didSelectAction(_ action: Any, _ entity: AllOperatives, _ offers: [PullOfferLocation: OfferEntity]?)
    func openAppStore()
    func didSelectFutureBill(_ bill: AccountFutureBillRepresentable, in bills: [AccountFutureBillRepresentable], for entity: AccountEntity)
    func gotoCardTransactionDetail(transactionEntity: CardTransactionEntity, in transactionList: [CardTransactionWithCardEntity], cardEntity: CardEntity)
    func gotoAccountTransactionDetail(transactionEntity: AccountTransactionEntity, in transactionList: [AccountTransactionWithAccountEntity], accountEntity: AccountEntity)
    func didSelectFavouriteContact(_ contact: PayeeRepresentable, launcher: ModuleLauncher, delegate: ModuleLauncherDelegate)
    func didTapInHistoricSendMoney()
    func goToWebView(configuration: WebViewConfiguration)
}

extension GlobalPositionModuleCoordinatorDelegate {
    func didSelectConfigureGPProducts() { }
}

public class GlobalPositionModuleCoordinator {
    
    private let resolver: DependenciesResolver
    private var pgClassicCoordinator: PGClassicCoordinator?
    private var pgSimpleCoordinator: PGSimpleCoordinator?
    private var pgSmartCoordinator: PGSmartCoordinator?

    public weak var navigationController: UINavigationController?
    private let pgDataManager: PGDataManagerProtocol
    
    public init(resolver: DependenciesResolver?) {
        let injector: DependenciesInjector & DependenciesResolver = DependenciesDefault(father: resolver)
        self.resolver = injector
        
        self.pgDataManager = PGDataManager(resolver: injector)
        
        injector.register(for: PGSimpleCoordinator.self) { resolver in
            return PGSimpleCoordinator(resolver: resolver, navigationController: self.navigationController)
        }
        injector.register(for: PGSmartCoordinator.self) { resolver in
            return PGSmartCoordinator(resolver: resolver, navigationController: self.navigationController)
        }
        injector.register(for: PGClassicCoordinator.self) { resolver in
            return PGClassicCoordinator(resolver: resolver, navigationController: self.navigationController)
        }
        injector.register(for: WhatsNewCoordinator.self) { resolver in
            return WhatsNewCoordinator(resolver: resolver, navigationController: self.navigationController)
        }
        injector.register(for: GetPGUseCase.self) { resolver in
            return GetPGUseCase(dependenciesResolver: resolver)
        }
        injector.register(for: GetAccountMovementsUseCase.self) { _ in
            return GetAccountMovementsUseCase()
        }
        injector.register(for: GetAccountUnreadMovementsUseCase.self) { _ in
            return DefaultGetAccountUnreadMovementsUseCase()
        }
        injector.register(for: GetCardUnreadMovementsUseCase.self) { _ in
            return DefaultGetCardUnreadMovementsUseCase()
        }
        injector.register(for: GetUserPreferencesUseCase.self) { _ in
            return GetUserPreferencesUseCase()
        }
        injector.register(for: UpdateUserPreferencesUseCase.self) { _ in
            return UpdateUserPreferencesUseCase()
        }
        injector.register(for: PGDataManagerProtocol.self) { [weak self] resolver in
            return (self?.pgDataManager ?? PGDataManager(resolver: resolver))
        }
        injector.register(for: GetOtherOperativesChecksUseCase.self) { _ in
            return GetOtherOperativesChecksUseCase()
        }
        injector.register(for: GetPregrantedLimitsUseCase.self) { _ in
            GetPregrantedLimitsUseCase(resolver: injector)
        }
        injector.register(for: LoadLoanSimulatorUseCase.self) { _ in
            LoadLoanSimulatorUseCase(resolver: injector)
        }
        injector.register(for: GetPullOffersUseCase.self) { resolver in
            return GetPullOffersUseCase(dependenciesResolver: resolver)
        }
        injector.register(for: GetCheckAnalysisUseCase.self) { resolver in
            return GetCheckAnalysisUseCase(dependenciesResolver: resolver)
        }
        injector.register(for: GetSSantanderExperiencesUseCase.self) { resolver in
            return GetSSantanderExperiencesUseCase(dependenciesResolver: resolver)
        }
        injector.register(for: GetLastLoginDateUseCase.self) { resolver in
            return GetLastLoginDateUseCase(dependenciesResolver: resolver)
        }
        injector.register(for: GetAppVersionUseCase.self) { resolver in
            return GetAppVersionUseCase(dependenciesResolver: resolver)
        }
        injector.register(for: GetPreconceivedBannerUseCase.self) { resolver in
            return GetPreconceivedBannerUseCase(resolver: resolver)
        }
        injector.register(for: CheckRobinsonListUseCase.self) { resolver in
            return CheckRobinsonListUseCase(resolver: resolver)
        }
        injector.register(for: FavouriteContactsUseCase.self) { resolver in
            FavouriteContactsUseCase(dependenciesResolver: resolver)
        }
        injector.register(for: GetLocalFavouriteContactsUseCase.self) { resolver in
            GetLocalFavouriteContactsUseCase(dependenciesResolver: resolver)
        }        
        injector.register(for: ExpirePullOfferUseCase.self) { resolver in
            ExpirePullOfferUseCase(dependenciesResolver: resolver)
        }
        injector.register(for: DisableOnSessionPullOfferUseCase.self) { resolver in
            DisableOnSessionPullOfferUseCase(dependenciesResolver: resolver)
        }
        injector.register(for: GlobalPositionModuleCoordinatorProtocol.self) { _ in
            return self
        }
        injector.register(for: ContactsSortedHandlerProtocol.self) { _ in
            return ContactsSortedHandler()
        }
        injector.register(for: OfferCarouselBuilderProtocol.self) { _ in
            return OfferCarouselBuilder()
        }
        injector.register(for: GetPortfolioWebViewConfigurationUseCase.self) { resolver in
            return GetPortfolioWebViewConfigurationUseCase(dependenciesResolver: resolver)
        }
        injector.register(for: GetMonthlyBalanceUseCase.self) { _ in
            return DefaultGetMonthlyBalanceUseCase()
        }
        self.registerCarbonFootprintDependencies(in: injector)
        self.registerPendingSolicitudeDependencies(in: injector)
        self.addPGModifiers(dependenciesResolver: injector)
    }
    
    private func registerCarbonFootprintDependencies(in injector: DependenciesInjector) {
        injector.register(for: GetCarbonFootprintIdUseCase.self) { resolver in
            return GetCarbonFootprintIdUseCase(dependenciesResolver: resolver)
        }
        injector.register(for: GetCarbonFootprintDataUseCase.self) { resolver in
            return GetCarbonFootprintDataUseCase(dependenciesResolver: resolver)
        }
        injector.register(for: GetCarbonFootprintWebViewConfigurationUseCase.self) { resolver in
            return GetCarbonFootprintWebViewConfigurationUseCase(dependenciesResolver: resolver)
        }
    }
    
    private func registerPendingSolicitudeDependencies(in injector: DependenciesInjector) {
        injector.register(for: PendingSolicitudesView.self) { resolver in
            let presenter: PendingSolicitudesPresenterProtocol = resolver.resolve()
            let view = PendingSolicitudesView(presenter: presenter)
            presenter.view = view
            return view
        }
        injector.register(for: PendingSolicitudesPresenterProtocol.self) { resolver in
            return PendingSolicitudesPresenter(dependenciesResolver: resolver)
        }
        injector.register(for: UpdatePendingSolicitudeUseCase.self) { resolver in
            return UpdatePendingSolicitudeUseCase(dependenciesResolver: resolver)
        }
        injector.register(for: GetPendingSolicitudesUseCase.self) { resolver in
            return GetPendingSolicitudesUseCase(dependenciesResolver: resolver)
        }
        injector.register(for: GetRecoveryLevelUseCase.self) { resolver in
            return GetRecoveryLevelUseCase(dependenciesResolver: resolver)
        }
        injector.register(for: RemoveSavedPendingSolicitudesUseCase.self) { resolver in
            return RemoveSavedPendingSolicitudesUseCase(dependenciesResolver: resolver)
        }
        injector.register(for: RecoveryPopupPresenterProtocol.self) { resolver in
            return RecoveryPopupPresenter(dependenciesResolver: resolver)
        }
        injector.register(for: RecoveryPopup.self) { resolver in
            var presenter = resolver.resolve(for: RecoveryPopupPresenterProtocol.self)
            let view = RecoveryPopup(presenter: presenter)
            presenter.view = view
            return view
        }
    }
    
    func addPGModifiers(dependenciesResolver: DependenciesResolver) {
        dependenciesResolver.resolve(for: DepositModifier.self)
            .reset()
            .add(DepositDefaultModifier(dependenciesResolver: self.resolver))
            .addExtraModifier()
        
        dependenciesResolver.resolve(for: FundModifier.self)
            .reset()
            .add(FundDefaultModifier(dependenciesResolver: self.resolver))
            .addExtraModifier()
        dependenciesResolver.resolve(for: InsuranceProtectionModifier.self)
            .reset()
            .add(InsuranceProtectionDefaultModifier(dependenciesResolver: self.resolver))
            .addExtraModifier()
    }
}

extension GlobalPositionModuleCoordinator: GlobalPositionModuleCoordinatorProtocol {
    func didSelectDeposit(deposit: DepositEntity) {
        self.resolver.resolve(for: DepositModifier.self).didSelectDeposit(deposit: deposit)
    }
    
    func didSelectFund(fund: FundEntity) {
        self.resolver.resolve(for: FundModifier.self).didSelectFund(fund: fund)
    }

    func didSelectInsuranceProtection(insurance: InsuranceProtectionEntity) {
        self.resolver.resolve(for: InsuranceProtectionModifier.self).didSelectInsuranceProtection(insurance: insurance)
    }
}

// MARK: - Commons.ModuleSectionedCoordinator

extension GlobalPositionModuleCoordinator: ModuleSectionedCoordinator {
    
    public enum GlobalPositionSection: CaseIterable {
        case simple
        case classic
        case smart
    }
    
    public func start(_ section: GlobalPositionSection) {
        switch section {
        case .simple:
            self.pgSimpleCoordinator = resolver.resolve(for: PGSimpleCoordinator.self)
            self.pgSimpleCoordinator?.start()
        case .classic:
            self.pgClassicCoordinator = resolver.resolve(for: PGClassicCoordinator.self)
            self.pgClassicCoordinator?.start()
        case .smart:
            self.pgSmartCoordinator = resolver.resolve(for: PGSmartCoordinator.self)
            self.pgSmartCoordinator?.start()
        }
    }
}
