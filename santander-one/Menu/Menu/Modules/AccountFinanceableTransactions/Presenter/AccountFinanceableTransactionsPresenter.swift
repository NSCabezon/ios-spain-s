import Foundation
import CoreFoundationLib

protocol AccountFinanceableTransactionsPresenterProtocol: AnyObject, MenuTextWrapperProtocol {
    var view: AccountFinanceableTransactionsViewProtocol? { get set }
    func viewDidLoad()
    func dismissViewController()
    func openMenu()
    func didselectAccountViewModel(_ viewModel: AccountFinanceableViewModel)
    func didSelectTransaction(_ viewModel: AccountListFinanceableTransactionViewModel)
}

final class AccountFinanceableTransactionsPresenter {
    weak var view: AccountFinanceableTransactionsViewProtocol?
    let dependenciesResolver: DependenciesResolver
    private var accounts: [AccountEntity] = []
    private var accountTransactions: Set = Set<AccountFinanceableTransactionsList>()
    private var selectedAccount: AccountEntity?
    private let locations: [PullOfferLocation] = PullOffersLocationsFactoryEntity().financing
    private var pullOfferCandidates: [PullOfferLocation: OfferEntity] = [:]
    private var easyPay: AccountEasyPay?
    
    var coordinatorDelegate: AccountFinanceableTransactionCoordinatorDelegate {
        return self.dependenciesResolver.resolve(for: AccountFinanceableTransactionCoordinatorDelegate.self)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension AccountFinanceableTransactionsPresenter: AccountFinanceableTransactionsPresenterProtocol {
    
    func viewDidLoad() {
        self.view?.showLoadingView(nil)
        self.fetchData()
        trackScreen()
    }
    
    func dismissViewController() {
        self.coordinatorDelegate.didSelectDismiss()
    }
    
    func openMenu() {
        self.coordinatorDelegate.didSelectMenu()
    }
    
    func didselectAccountViewModel(_ viewModel: AccountFinanceableViewModel) {
        self.view?.showLoadingView(nil)
        self.selectedAccount = viewModel.account
        self.loadAccountTransactions(for: viewModel.account)
    }
    
    func didSelectTransaction(_ viewModel: AccountListFinanceableTransactionViewModel) {
        trackEvent(.fractionablesAccountMonthDetail)
        self.coordinatorDelegate.didSelectOffer(viewModel.offer)
    }
}

private extension AccountFinanceableTransactionsPresenter {
    var getAccountsUseCase: GetAccountsUseCase {
        self.dependenciesResolver.resolve()
    }
    var getAccountFinanceableTransactionsUseCase: GetAccountFinanceableTransactionsUseCase {
        return self.dependenciesResolver.resolve(for: GetAccountFinanceableTransactionsUseCase.self)
    }
    var useCaseHandler: UseCaseHandler {
        self.dependenciesResolver.resolve(for: UseCaseHandler.self)
    }
    var getPullOffersCandidatesUseCase: GetOffersCandidatesUseCase {
        self.dependenciesResolver.resolve()
    }
    var getAccountEasyPayUseCase: GetAccountEasyPayUseCase {
        self.dependenciesResolver.resolve()
    }
    
    func fetchData() {
        self.selectedAccount = self.getSelectedAccount()
        self.getAccounts { accounts in
            guard let accounts = accounts, accounts.count > 0,
                let selectedAccount = self.getSelectedAccount() else {
                    self.view?.hideLoadingView(nil)
                    self.performEmptyViewActions()
                    return
            }
            self.accounts = accounts
            self.setDropDownSelector(with: accounts)
            self.loadAccountTransactions(for: selectedAccount)
        }
    }
    
    func getAccounts(_ completion: @escaping ([AccountEntity]?) -> Void) {
        UseCaseWrapper(
            with: self.getAccountsUseCase,
            useCaseHandler: self.dependenciesResolver.resolve(),
            onSuccess: { result in
                completion(result.accountList)
            },
            onError: { _ in
                completion(nil)
            }
        )
    }
    
    func getSelectedAccount() -> AccountEntity? {
        let configuration = self.dependenciesResolver.resolve(for: AccountFinanceableTransactionConfigurationProtocol.self)
        return configuration.selectedAccount ?? accounts.first
    }
    
    func setDropDownSelector(with accounts: [AccountEntity]) {
        let accountFinanceableViewModels = accounts.map({ AccountFinanceableViewModel(account: $0) })
        let selectedViewModel = AccountFinanceableViewModel(account: self.selectedAccount ?? accounts[0])
        self.view?.showAccountDropDown(with: accountFinanceableViewModels, selectedViewModel: selectedViewModel)
    }
    
    func loadAccountTransactions(for account: AccountEntity) {
        self.loadOffers { result in
            guard let pullOfferCandidates = result else {
                self.performEmptyViewActions()
                return
            }
            self.pullOfferCandidates = pullOfferCandidates
            self.getAccountEasyPay { result in
                self.easyPay = result
                self.loadFinanceableTransactions(for: account)
            }
        }
    }
    
    func loadFinanceableTransactions(for account: AccountEntity) {
        guard let easyPay = self.easyPay, self.accounts.count > 0 else {
            self.view?.hideLoadingView(nil)
            self.performEmptyViewActions()
            return
        }
        let input = GetAccountFinanceableTransactionsUseCaseInput(
            account: account,
            easyPayAccount: easyPay,
            offers: self.pullOfferCandidates
        )
        UseCaseWrapper(
            with: self.getAccountFinanceableTransactionsUseCase.setRequestValues(requestValues: input),
            useCaseHandler: self.useCaseHandler,
            onSuccess: { [weak self] response in
                self?.view?.hideLoadingView(nil)
                self?.addAccountTransactions(response)
            },
            onError: {[weak self] _ in
                self?.view?.hideLoadingView(nil)
                self?.performEmptyViewActions()
            }
        )
    }
    
    func addAccountTransactions(_ response: GetAccountFinanceableTransactionsUseCaseOkOutput) {
        let financeableTransactionList = AccountFinanceableTransactionsList(
            account: response.account,
            transactions: response.transactions
        )
        self.accountTransactions.insert(financeableTransactionList)
        self.showAccountFinanceableTransactions(financeableTransactionList)
        self.view?.showDateFilters(self.getSearchedDates())
    }
    
    func showAccountFinanceableTransactions(_ transactionList: AccountFinanceableTransactionsList) {
        let viewModels = self.generateViewModelsFor(transactionList)
        if viewModels.isEmpty {
            self.view?.showEmptyView()
        } else {
            self.view?.showFinanceableTransactions(viewModels: viewModels)
        }
    }
    
    func generateViewModelsFor(_ transactionList: AccountFinanceableTransactionsList) -> [AccountListFinanceableTransactionViewModel] {
        let account = transactionList.account
        let viewModels = transactionList.transactions.map({ transaction -> AccountListFinanceableTransactionViewModel in
            let viewModel = AccountListFinanceableTransactionViewModel(
                account: account,
                easyPayTransaction: transaction
            )
            return viewModel
        })
        return viewModels
    }
    
    func loadOffers(completion: @escaping ([PullOfferLocation: OfferEntity]?) -> Void) {
        UseCaseWrapper(with: self.getPullOffersCandidatesUseCase.setRequestValues(requestValues: GetOffersCandidatesUseCaseInput(locations: self.locations)),
                       useCaseHandler: self.useCaseHandler,
                       queuePriority: .normal,
             onSuccess: { result in
                        completion(result.pullOfferCandidates)
            }, onError: { _ in
                completion(nil)
        })
    }
    
    func getAccountEasyPay(completion: @escaping (AccountEasyPay?) -> Void) {
        UseCaseWrapper(
            with: self.getAccountEasyPayUseCase.setRequestValues(requestValues: GetAccountEasyPayUseCaseInput(type: .transaction)),
            useCaseHandler: self.useCaseHandler,
            onSuccess: { result in
                completion(result.accountEasyPay)
            },
            onError: { _ in
                completion(nil)
            })
    }
    
    func performEmptyViewActions() {
        self.view?.showEmptyView()
        self.view?.showDateFilters(self.getSearchedDates())
    }
}

extension AccountFinanceableTransactionsPresenter: FinanciableTransactionsDatesProtocol {}

extension AccountFinanceableTransactionsPresenter: AutomaticScreenActionTrackable {
    var trackerPage: AccountFinanceableDistributionPage {
        return AccountFinanceableDistributionPage()
    }
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
}
