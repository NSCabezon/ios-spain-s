import UI
import CoreFoundationLib
import SANLegacyLibrary
import OfferCarousel

public enum ScaState {
    case notApply
    case temporaryLock(date: Date)
    case requestOtp(date: Date)
    case error(date: Date)
}

public protocol AccountsHomeCoordinatorDelegate: AnyObject {
    func didSelectAction(action: AccountActionType, entity: AccountEntity?)
    func didSelectDetail(for account: AccountEntity)
    func didSelectSearch()
    func didSelectDownloadTransactions(for account: AccountEntity, withFilters: TransactionFiltersEntity?, withScaSate scaState: ScaState?)
    func didGenerateTransactionsPDF(for account: AccountEntity, holder: String?, fromDate: Date?, toDate: Date?, transactions: [AccountTransactionEntity], showDisclaimer: Bool)
    func didSelectDismiss()
    func didSelectMenu()
    func didSelectTransaction(_ transaction: AccountTransactionEntity, in transactions: [AccountTransactionEntity], for account: AccountEntity)
    func didSelectShare(for account: AccountEntity)
    func showDialog(acceptTitle: LocalizedStylableText?, cancelTitle: LocalizedStylableText?, title: LocalizedStylableText?, body: LocalizedStylableText?, showsCloseButton: Bool, source: UIViewController, acceptAction: (() -> Void)?, cancelAction: (() -> Void)?)
    func goToAccountsOTP(delegate: OtpScaAccountPresenterDelegate, scaTransactionParams: SCATransactionParams)
    func didSelectOffer(offer: OfferEntity)
    func goToWebView(configuration: WebViewConfiguration)
    func showLoading()
}

public class AccountsHomeCoordinator: ModuleCoordinator {
    
    private let dependenciesEngine: DependenciesDefault
    private let accountTransactionDetailCoordinator: AccountTransactionDetailCoordinator
    private let accountDetailCoordinator: AccountDetailCoordinator
    private let withHoldingCoordinator: WithholdingCoordinator
    private let accountTransactionsSearchCoordinator: AccountTransactionsSearchCoordinator
    private let otherOperativesCoordinator: OtherOperativesCoordinator
    private var delegate: AccountsHomeCoordinatorDelegate {
        return self.dependenciesEngine.resolve(for: AccountsHomeCoordinatorDelegate.self)
    }
    private lazy var accountTransactionsPDFGenerator: AccountTransactionsPDFGeneratorProtocol? = {
        self.dependenciesEngine.resolve(forOptionalType: AccountTransactionsPDFGeneratorProtocol.self)
    }()
    private lazy var actionModifier: AccountHomeActionModifierProtocol = {
        self.dependenciesEngine.resolve(firstTypeOf: AccountHomeActionModifierProtocol.self)
    }()
    public weak var navigationController: UINavigationController?
    
    init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController?) {
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.accountTransactionDetailCoordinator = AccountTransactionDetailCoordinator(dependenciesResolver: self.dependenciesEngine, navigationController: navigationController)
        self.accountDetailCoordinator = AccountDetailCoordinator(dependenciesResolver: self.dependenciesEngine, navigationController: navigationController)
        self.withHoldingCoordinator = WithholdingCoordinator(dependenciesResolver: self.dependenciesEngine, navigationController: navigationController)
        self.otherOperativesCoordinator = OtherOperativesCoordinator(resolver: self.dependenciesEngine,
                                                                     coordinatingViewController: navigationController)
        self.accountTransactionsSearchCoordinator = AccountTransactionsSearchCoordinator(resolver: self.dependenciesEngine, coordinatingViewController: navigationController)
        self.setupDependencies()
        self.navigationController = navigationController
    }
    
    public func start() {
        self.navigationController?.blockingPushViewController(self.dependenciesEngine.resolve(for: AccountsHomeViewController.self), animated: true)
    }
    
    // MARK: - Internal & Private methods
    
    func didSelectTransaction(_ transaction: AccountTransactionEntity, in transactions: [AccountTransactionEntity], for entity: AccountEntity, section: AccountsModuleCoordinator.AccountsSection = .detail) {
        self.dependenciesEngine.register(for: AccountTransactionDetailConfiguration.self) { _ in
            return AccountTransactionDetailConfiguration(selectedAccount: entity, selectedTransaction: transaction, allTransactions: transactions)
        }
        self.accountTransactionDetailCoordinator.start(section)
    }
    
    func didSelectDetail(_ transaction: AccountTransactionEntity, in transactions: [AccountTransactionEntity], for entity: AccountEntity, section: AccountsModuleCoordinator.AccountsSection = .detail) {
        self.dependenciesEngine.register(for: AccountTransactionDetailConfiguration.self) { _ in
            return AccountTransactionDetailConfiguration(selectedAccount: entity, selectedTransaction: transaction, allTransactions: transactions)
        }
        self.accountTransactionDetailCoordinator.start(section)
    }

    func didSelectWithholding(for detailEntity: AccountDetailEntity) {
        self.dependenciesEngine.register(for: WithholdingConfiguration.self) { _ in
            return WithholdingConfiguration(detailEntity: detailEntity)
        }
        self.withHoldingCoordinator.start()
    }
    
    func didSelectShare(for shareable: Shareable) {
        guard let topController = self.navigationController?.topViewController else { return }
        let sharedHandle = self.dependenciesEngine.resolve(for: SharedHandler.self)
        sharedHandle.doShare(for: shareable, in: topController)
    }
    
    func didSelectShowFilters(_ presenter: AccountsHomePresenterProtocol) {
        self.dependenciesEngine.register(for: AccountTransactionsSearchDelegate.self) { _ in
            return presenter
        }
        self.accountTransactionsSearchCoordinator.start()
    }
    
    func gotToMoreOptions(for account: AccountEntity) {
        self.dependenciesEngine.register(for: OtherOperativesConfiguration.self) { _ in
            return OtherOperativesConfiguration(account: account)
        }
        self.otherOperativesCoordinator.start()
    }
    
    func didSelectAction(_ action: AccountActionType, _ entity: AccountEntity) {
        if case .accountDetail = action {
            self.goToAccountDetail(account: entity)
        } else {
            actionModifier.didSelectAction(action, entity)
        }
    }
    
    func didSelectSearch() {
        self.delegate.didSelectSearch()
    }
    
    func didSelectDownloadTransactions(for account: AccountEntity, withFilters: TransactionFiltersEntity?, withScaSate scaState: ScaState?) {
        if let modifier = self.accountTransactionsPDFGenerator {
            self.delegate.showLoading()
            modifier.generatePDF(for: account, withFilters: withFilters, withScaSate: scaState)
        } else {
            self.delegate.didSelectDownloadTransactions(for: account, withFilters: withFilters, withScaSate: scaState)
        }
    }
    
    func didSelectDismiss() {
        self.delegate.didSelectDismiss()
    }
    
    func didSelectMenu() {
        self.delegate.didSelectMenu()
    }
    
    func didSelectOffer(offer: OfferEntity) {
        self.delegate.didSelectOffer(offer: offer)
    }
    
    func showDialog(acceptTitle: LocalizedStylableText?, cancelTitle: LocalizedStylableText?, title: LocalizedStylableText?, body: LocalizedStylableText?, showsCloseButton: Bool, source: UIViewController, acceptAction: (() -> Void)?, cancelAction: (() -> Void)?) {
        self.delegate.showDialog(acceptTitle: acceptTitle, cancelTitle: cancelTitle, title: title, body: body, showsCloseButton: showsCloseButton, source: source, acceptAction: acceptAction, cancelAction: cancelAction)
    }
    
    func goToAccountsOTP(delegate: OtpScaAccountPresenterDelegate, scaTransactionParams: SCATransactionParams) {
        self.delegate.goToAccountsOTP(delegate: delegate, scaTransactionParams: scaTransactionParams)
    }

    private func setupDependencies() {
        self.dependenciesEngine.register(for: AccountsHomePresenterProtocol.self) { dependenciesResolver in
            return AccountsHomePresenter(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: AccountsHomeViewProtocol.self) { dependenciesResolver in
            return dependenciesResolver.resolve(for: AccountsHomeViewController.self)
        }
        self.dependenciesEngine.register(for: GetPullOffersUseCase.self) { dependenciesResolver in
            return GetPullOffersUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: GetAccountEasyPayUseCase.self) { dependenciesResolver in
            return GetAccountEasyPayUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: GetAccountsHomeUseCase.self) { dependenciesResolver in
            return GetAccountsHomeUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: GetScaStateUseCase.self) { dependenciesResolver in
            return GetScaStateUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: GetAccountDetailUseCase.self) { dependenciesResolver in
            return GetAccountDetailUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: GetWithholdingUseCase.self) { dependenciesResolver in
            return GetWithholdingUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: AccountsHomeViewController.self) { dependenciesResolver in
            let presenter: AccountsHomePresenterProtocol = dependenciesResolver.resolve(for: AccountsHomePresenterProtocol.self)
            let viewController = AccountsHomeViewController(nibName: "AccountsHome", bundle: Bundle.module, presenter: presenter)
            presenter.view = viewController
            return viewController
        }
        self.dependenciesEngine.register(for: AccountsHomeCoordinator.self) { _ in
            return self
        }
        self.dependenciesEngine.register(for: SetReadAccountTransactionsUseCase.self) { dependenciesResolver in
            return SetReadAccountTransactionsUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: SharedHandler.self) { _ in
            return SharedHandler()
        }
        self.dependenciesEngine.register(for: GetFilteredAccountTransactionsUseCaseProtocol.self) { _ in
            return DefaultGetFilteredAccountTransactionsUseCase()
        }
        self.dependenciesEngine.register(for: GetAccountTransactionsUseCaseProtocol.self) { dependenciesResolver in
            return DefaultGetAccountTransactionsUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: AccountActionAdapter.self) { dependenciesResolver in
            return AccountActionAdapter(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: AccountTransactionPullOfferConfigurationUseCase.self) { dependenciesResolver in
            return AccountTransactionPullOfferConfigurationUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: OfferCarouselBuilderProtocol.self) { _ in
            return OfferCarouselBuilder()
        }
        self.dependenciesEngine.register(for: DisableOnSessionPullOfferUseCase.self) { resolver in
            DisableOnSessionPullOfferUseCase(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: GetAccountOtherOperativesUseCaseProtocol.self) { resolver in
            GetAccountOtherOperativesUseCase(dependenciesResolver: resolver)
        }
    }
    
    func goToAccountDetail(account: AccountEntity) {
        self.dependenciesEngine.register(for: AccountDetailConfiguration.self) { _ in
            return AccountDetailConfiguration(accountEntity: account)
        }
        self.accountDetailCoordinator.start()
    }
}
