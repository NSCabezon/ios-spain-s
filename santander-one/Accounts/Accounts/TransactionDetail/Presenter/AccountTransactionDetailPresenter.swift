import CoreFoundationLib

protocol AccountTransactionDetailPresenterProtocol: AnyObject, MenuTextWrapperProtocol {
    var view: AccountTransactionDetailViewProtocol? { get set }
    func didSelectTransaction(_ viewModel: AccountTransactionDetailViewModel)
    func didSelectAssociatedTransaction(_ viewModel: AssociatedTransactionViewModel)
    func viewDidLoad()
    func dismiss()
    func didSelectMenu()
    func didSelectEasyPay()
    func didSelectOffer()
    func scrollViewDidEndDecelerating()
}

final class AccountTransactionDetailPresenter {
    weak var view: AccountTransactionDetailViewProtocol?
    let dependenciesResolver: DependenciesResolver
    var configuration: AccountTransactionDetailConfiguration
    var associatedTransactions: [AccountTransactionEntity] = []
    var section: AccountsModuleCoordinator.AccountsSection?
    
    var selectedAccount: AccountEntity {
        get {
            return self.configuration.selectedAccount
        }
        set(newValue) {
            self.configuration.selectedAccount = newValue
        }
    }
    
    var selectedTransaction: AccountTransactionEntity {
        didSet {
            self.loadConfiguration {
                self.loadAccountTransactionDetail()
            }
        }
    }
    
    var transactions: [AccountTransactionEntity] {
        self.configuration.allTransactions
    }
    
    var resultTransactions: [AccountTransactionWithAccountEntity]? {
        self.configuration.resultTransactions
    }
    
    lazy var selectedTransactionViewModel: AccountTransactionDetailViewModel = {
        AccountTransactionDetailViewModel(
            transaction: self.selectedTransaction,
            account: self.selectedAccount,
            detail: nil,
            isEasyPayEnabled: isEasyPayEnabled,
            isSplitExpensesEnabled: isSplitExpensesEnabled,
            timeManager: self.dependenciesResolver.resolve(for: TimeManager.self),
            offerEntity: self.crossSellingOffer,
            dependenciesResolver: dependenciesResolver
        )
    }()

    lazy var transactionViewModels: [AccountTransactionDetailViewModel] = {
        self.transactions.map {
            AccountTransactionDetailViewModel(
                transaction: $0,
                account: self.selectedAccount,
                detail: nil,
                isEasyPayEnabled: isEasyPayEnabled,
                isSplitExpensesEnabled: isSplitExpensesEnabled,
                timeManager: self.dependenciesResolver.resolve(for: TimeManager.self),
                offerEntity: nil,
                dependenciesResolver: dependenciesResolver
            )
        }
    }()
    
    private var accountTransactionModifier: AccountTransactionProtocol? {
        return self.dependenciesResolver.resolve(forOptionalType: AccountTransactionProtocol.self)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.selectedTransaction = self.dependenciesResolver.resolve(for: AccountTransactionDetailConfiguration.self).selectedTransaction
        self.configuration =  self.dependenciesResolver.resolve(for: AccountTransactionDetailConfiguration.self)
    }
    
    var easyPay: AccountEasyPay?
    
    var isEasyPayEnabled: Bool {
        guard !self.selectedAccount.isPiggyBankAccount else {
            return false
        }
        switch easyPayFundableType {
        case .low where offers.contains(location: AccountsPullOffers.lowEasyPayAmount): return true
        case .high where offers.contains(location: AccountsPullOffers.highEasyPayAmount): return true
        default: return false
        }
    }
    
    var crossSellingOffer: OfferEntity? {
        return self.offers.location(key: AccountsPullOffers.movAccountDetail)?.offer
    }
    
    var easyPayFundableType: AccountEasyPayFundableType {
        guard
            let amount = self.selectedTransaction.amount,
            let easyPay = self.easyPay
        else { return .notAllowed }
        return easyPayFundableType(for: amount,
                                   transaction: self.selectedTransaction,
                                   accountEasyPay: easyPay)
    }
    
    var timeManager: TimeManager {
        self.dependenciesResolver.resolve(for: TimeManager.self)
    }
    
    private var useCaseHandler: UseCaseHandler {
        return self.dependenciesResolver.resolve(for: UseCaseHandler.self)
    }
    var transactionDetailUseCase: AccountTransactionDetailUseCase {
        self.dependenciesResolver.resolve(for: AccountTransactionDetailUseCase.self)
    }
    
    var easyPayAccountUseCase: GetAccountEasyPayUseCase {
        self.dependenciesResolver.resolve(for: GetAccountEasyPayUseCase.self)
    }
    
    var transactionPullOffersUseCase: AccountTransactionPullOfferConfigurationUseCase {
        self.dependenciesResolver.resolve(for: AccountTransactionPullOfferConfigurationUseCase.self)
    }
    
    var accountDetailSectionConfiguration: AccountDetailSectionConfiguration {
        self.dependenciesResolver.resolve(for: AccountDetailSectionConfiguration.self)
    }
    
    var associatedAccountTransactionsUseCase: GetAssociatedAccountTransactionsUseCase {
        self.dependenciesResolver.resolve(firstTypeOf: GetAssociatedAccountTransactionsUseCase.self)
    }
    var coordinator: AccountTransactionDetailCoordinator {
        self.dependenciesResolver.resolve(for: AccountTransactionDetailCoordinator.self)
    }
    
    var locations: [PullOfferLocation] {
        return [
            PullOfferLocation(stringTag: AccountsPullOffers.lowEasyPayAmount,
                              hasBanner: false,
                              pageForMetrics: self.trackerPage.page),
            PullOfferLocation(stringTag: AccountsPullOffers.highEasyPayAmount,
                              hasBanner: false,
                              pageForMetrics: self.trackerPage.page)
        ]
    }
    
    var specificLocations: [PullOfferLocation] {
        return [
            PullOfferLocation(stringTag: AccountsPullOffers.movAccountDetail,
                              hasBanner: true,
                              pageForMetrics: self.trackerPage.page)
        ]
    }
    
    var offers: [PullOfferLocation: OfferEntity] = [:]
    var isSplitExpensesEnabled: Bool = false
}

extension AccountTransactionDetailPresenter: AccountTransactionDetailPresenterProtocol {
    func viewDidLoad() {
        self.trackScreen()
        self.checkBizumSplitExpenses()
        self.loadConfiguration { [weak self] in
            guard let self = self else { return }
            self.loadEasyPay { [weak self] in
                self?.loadAccountTransactionDetail()
            }
            self.loadTransactions()
            self.createActionsForSelectedTransaction()
            self.loadAssociatedTransactions(self.selectedTransaction)
        }
    }
    
    func didSelectTransaction(_ viewModel: AccountTransactionDetailViewModel) {
        self.selectedAccount = viewModel.account
        self.selectedTransaction = viewModel.transaction
        self.selectedTransactionViewModel = viewModel
        self.createActionsForSelectedTransaction()
        self.loadAssociatedTransactions(self.selectedTransaction)
    }
    
    func didSelectAssociatedTransaction(_ viewModel: AssociatedTransactionViewModel) {
        trackerManager.trackScreen(screenId: AccountAssociatedTransactionPage().page, extraParameters: [:])
        self.coordinator.didSelectAssociatedTransaction(viewModel.entity.accountTransactionEntity,
                                                        in: self.associatedTransactions,
                                                        for: viewModel.entity.accountEntity,
                                                        section: AccountsModuleCoordinator.AccountsSection.detailWithOutAssociated)
    }
    
    func dismiss() {
        self.coordinator.dismiss()
    }
    
    func didSelectMenu() {
        self.coordinator.didSelectMenu()
    }
    
    func didSelectEasyPay() {
        switch self.easyPayFundableType {
        case .low:
            guard let offer = offers.location(key: AccountsPullOffers.lowEasyPayAmount) else { return }
            self.coordinator.didSelectOffer(offer: offer.offer)
            self.trackEvent(.easyPay, parameters: [:])
        case .high:
            guard let offer = offers.location(key: AccountsPullOffers.highEasyPayAmount) else { return }
            self.coordinator.didSelectOffer(offer: offer.offer)
            self.trackEvent(.easyPay, parameters: [:])
        default:
            self.trackEvent(.easyPayError, parameters: [:])
        }
    }
    
    func scrollViewDidEndDecelerating() {
        trackEvent(.swipe, parameters: [:])
    }
    
    func didSelectOffer() {
        guard let offer = self.offers.location(key: AccountsPullOffers.movAccountDetail) else { return }
        self.coordinator.didSelectOffer(offer: offer.offer)
    }
}

extension AccountTransactionDetailPresenter: AutomaticScreenActionTrackable {
    
    var trackerPage: AccountTransactionDetail {
        AccountTransactionDetail()
    }
    
    var trackerManager: TrackerManager {
        dependenciesResolver.resolve(for: TrackerManager.self)
    }
}

extension AccountTransactionDetailPresenter: AccountEasyPayChecker {}

private extension AccountTransactionDetailPresenter {
    private var transactionCategoryUseCase: GetTransactionCategoryUseCase {
        dependenciesResolver.resolve(for: GetTransactionCategoryUseCase.self)
    }
    
    private var getUserCampaignsUseCase: GetUserCampaignsUseCase {
        dependenciesResolver.resolve(for: GetUserCampaignsUseCase.self)
    }
    
    private var getAccountMovementsCategoryUseCase: GetAccountMovementsCategoryUseCase {
        dependenciesResolver.resolve(for: GetAccountMovementsCategoryUseCase.self)
    }
    
    func loadTransactions() {
        if let results = self.resultTransactions {
            loadTransactionsFromGlobalSearch(with: results)
        } else {
            self.view?.showTransactions(self.transactionViewModels, withSelected: self.selectedTransactionViewModel)
        }
    }
    
    func loadTransactionsFromGlobalSearch(with results: [AccountTransactionWithAccountEntity]) {
        let resultViewModels = results.map { viewModelFor(resultTransaction: $0) }
        self.view?.showTransactions(resultViewModels, withSelected: self.selectedTransactionViewModel)
    }
    
    func viewModelFor(resultTransaction: AccountTransactionWithAccountEntity) -> AccountTransactionDetailViewModel {
        return AccountTransactionDetailViewModel(
            transaction: resultTransaction.accountTransactionEntity,
            account: resultTransaction.accountEntity,
            detail: nil,
            isEasyPayEnabled: isEasyPayEnabled,
            isSplitExpensesEnabled: isSplitExpensesEnabled,
            timeManager: self.dependenciesResolver.resolve(for: TimeManager.self),
            offerEntity: nil,
            dependenciesResolver: dependenciesResolver
        )
    }

    func checkBizumSplitExpenses() {
        let useCase = GetBizumSplitExpensesStatusUseCase(dependenciesResolver: self.dependenciesResolver)
        Scenario(useCase: useCase)
            .execute(on: dependenciesResolver.resolve())
            .onSuccess { [weak self] output in
                self?.isSplitExpensesEnabled = output.isBizumSplitExpensesEnabled
            }
    }
    
    func createActionsForSelectedTransaction() {
        if self.selectedTransactionViewModel.customActions != nil {
            self.view?.showActions(self.loadStrategy(CustomAccountTransactionActionsStrategy.self).loadActions())
            return
        }
        let actionsStrategy: AccountTransactionActionsStrategy
        switch self.selectedTransaction.type {
        case .transfer:
            actionsStrategy = self.loadStrategy(TransferAccountTransactionActionsStrategy.self)
        case .bill:
            actionsStrategy = self.loadStrategy(BillAccountTransactionActionsStrategy.self)
        case .shopping, .contactless, .bizum, .unknown:
            actionsStrategy = self.loadStrategy(AnyAccountTransactionActionsStrategy.self)
        }
        self.view?.showActions(actionsStrategy.loadActions())
    }
    
    private func loadStrategy<Strategy: AccountTransactionActionsStrategy>(_ type: Strategy.Type) -> Strategy {
        let builder = AccountTransactionDetailOptionsBuilder()
        return Strategy(transaction: self.selectedTransaction,
                        viewModel: self.selectedTransactionViewModel,
                        builder: builder,
                        trackerManager: self.trackerManager,
                        delegate: self)
    }
    
    func loadConfiguration(_ completion: @escaping () -> Void) {
        let input = AccountTransactionOfferConfigurationUseCaseInput(
            account: self.selectedAccount,
            transaction: self.selectedTransaction,
            locations: self.locations,
            specificLocations: self.specificLocations,
            filterToApply: nil)
        Scenario(useCase: transactionPullOffersUseCase, input: input)
            .execute(on: dependenciesResolver.resolve())
            .onSuccess { [weak self] result in
                self?.offers = result.pullOfferCandidates
                completion()
            }.onError { _ in
                completion()
            }
    }
    
    func loadEasyPay(_ completion: @escaping () -> Void) {
        Scenario(useCase: easyPayAccountUseCase,
                 input: GetAccountEasyPayUseCaseInput(type: .transaction))
            .execute(on: dependenciesResolver.resolve())
            .onSuccess { [weak self] result in
                self?.easyPay = result.accountEasyPay
                self?.selectedTransactionViewModel.isEasyPayEnabled = self?.isEasyPayEnabled ?? false
                completion()
            }.onError { [weak self] error in
                defer { completion() }
                guard let error = error.getErrorDesc() else { return }
                guard let isDisabled = self?.accountTransactionModifier?.disabledEasyPayAccount, isDisabled == true else {
                    self?.trackEvent(.easyPayError, parameters: [.codError: error])
                    return
                }
            }
    }
    
    func loadAccountTransactionDetail() {
        let input = AccountTransactionDetailUseCaseInput(transaction: selectedTransaction,
                                                         account: selectedAccount)
        Scenario(useCase: transactionDetailUseCase,
                 input: input)
            .execute(on: dependenciesResolver.resolve())
            .onSuccess { [weak self] output in
                guard let self = self else { return }
                self.selectedTransactionViewModel.detail = output.detail
            }.onError { [weak self] error in
                guard let self = self else { return }
                var errorString: String? = ""
                if case .networkUnavailable = error {
                    errorString = error.getErrorDesc()
                } else if let serviceError = self.accountTransactionModifier?.getError() {
                    errorString = serviceError
                }
                let transactionViewModel = AccountTransactionDetailViewModel(
                    transaction: self.selectedTransaction,
                    account: self.selectedAccount,
                    error: errorString,
                    isEasyPayEnabled: self.isEasyPayEnabled,
                    isSplitExpensesEnabled: self.isSplitExpensesEnabled,
                    timeManager: self.timeManager,
                    offerEntity: self.crossSellingOffer,
                    dependenciesResolver: self.dependenciesResolver)
                self.selectedTransactionViewModel = transactionViewModel
                self.createActionsForSelectedTransaction()
                self.view?.update(viewModel: transactionViewModel)
            }.finally {
                self.loadTransactionCategory()
            }
    }
    
    func loadTransactionCategory() {
        let sce1: Scenario<Void, GetUserCampaignsUseCaseOutput, StringErrorOutput> = Scenario(useCase: getUserCampaignsUseCase)
        let sce2: Scenario<Void, GetAccountMovementsCategoryOutput, StringErrorOutput> = Scenario(useCase: getAccountMovementsCategoryUseCase)
        let values: (userCampaings: [String], accounts: [String]) = ([""], [""])
        MultiScenario(handledOn: dependenciesResolver.resolve(), initialValue: values)
            .addScenario(sce1) { (updatedValues, output, _) in
                updatedValues.userCampaings = output.campaigns
            }.addScenario(sce2) { (updatedValues, output, _) in
                updatedValues.accounts = output.accountMovementsCategory
            }
            .asScenarioHandler()
            .onSuccess { [weak self] values in
                guard let self = self else { return }
                if !values.accounts.isEmpty,
                   !values.userCampaings.isEmpty,
                   values.userCampaings.contains(where: { values.accounts.contains($0) == true }) {
                    self.loadCategoryDetail()
                } else {
                    self.view?.update(viewModel: self.selectedTransactionViewModel)
                }
            }.onError { _ in
                self.view?.update(viewModel: self.selectedTransactionViewModel)
            }
    }
    
    func loadCategoryDetail() {
        let input = TransactionCategoryUseCaseInput(
            dgoNumber: self.selectedTransaction.dgo,
            transactionDescription: self.selectedTransaction.description ?? "",
            amount: self.selectedTransaction.amount?.value ?? 0.0,
            date: self.selectedTransaction.operationDate ?? Date()
        )
        
        Scenario(useCase: transactionCategoryUseCase, input: input)
            .execute(on: dependenciesResolver.resolve())
            .onSuccess { [weak self] output in
                if let transactionInfo = TransactionCategory(rawValue: output.category) {
                    self?.selectedTransactionViewModel.category = transactionInfo
                } else {
                    self?.selectedTransactionViewModel.category = TransactionCategory.none
                }
            }
            .finally {
                self.view?.update(viewModel: self.selectedTransactionViewModel)
            }
    }
    
    func loadTransactionDetail() {
        let input = AccountTransactionDetailUseCaseInput(transaction: selectedTransaction,
                                                         account: selectedAccount)
        Scenario(useCase: transactionDetailUseCase,
                 input: input)
            .execute(on: dependenciesResolver.resolve())
            .onSuccess { [weak self] output in
                guard let self = self else { return }
                self.selectedTransactionViewModel.detail = output.detail
            }.onError { [weak self] error in
                guard let self = self else { return }
                var errorString: String? = ""
                if case .networkUnavailable = error {
                    errorString = error.getErrorDesc()
                }
                self.selectedTransactionViewModel.error = errorString
            }
            .finally {
                self.loadTransactionCategory()
            }
    }
    
    func loadAssociatedTransactions(_ transaction: AccountTransactionEntity) {
        guard accountDetailSectionConfiguration.section == .detail else {
            self.view?.showAssociatedTransactions([])
            return
        }
        Scenario(useCase: associatedAccountTransactionsUseCase,
                 input: GetAssociatedAccountTransactionsUseCaseInput(accountTransaction: transaction))
            .execute(on: dependenciesResolver.resolve())
            .onSuccess { [weak self] result in
                guard let strongSelf = self else { return }
                let viewModels: [AssociatedTransactionViewModel] = result.accountTransactions.map({ transaction in
                    return AssociatedTransactionViewModel(transaction, dependenciesResolver: strongSelf.dependenciesResolver)
                })
                strongSelf.associatedTransactions = result.accountTransactions.map({ $0.accountTransactionEntity })
                strongSelf.view?.showAssociatedTransactions(viewModels)
            }.onError { [weak self] _ in
                self?.view?.showAssociatedTransactions([])
            }
    }
}

extension AccountTransactionDetailPresenter: AccountTransactionActionsStrategyDelegate {
    func goToTransactionAction(type: AccountTransactionDetailAction) {
        self.coordinator.goToAction(
            type: type,
            transaction: self.selectedTransaction,
            detail: self.selectedTransactionViewModel.detail,
            account: self.selectedAccount
        )
    }
}
