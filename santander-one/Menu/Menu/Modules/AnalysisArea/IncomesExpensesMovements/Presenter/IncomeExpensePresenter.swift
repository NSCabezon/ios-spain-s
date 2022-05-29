import Foundation
import CoreFoundationLib
import CoreDomain

protocol IncomeExpensePresenterProtocol: AnyObject, MenuTextWrapperProtocol {
    var view: IncomeExpenseViewProtocol? { get set }
    var monthLiteral: String {get}
    func didSelectMenu()
    func didSelectDismiss()
    func viewDidLoad()
    func showBalanceDetailForEntity(_ entity: BalanceItem)
}

final class IncomeExpensePresenter {
    weak var view: IncomeExpenseViewProtocol?
    private var viewModel: IncomeExpenseViewModel?
    let dependenciesResolver: DependenciesResolver
    private var coordinator: IncomeExpenseCoordinatorProtocol {
        self.dependenciesResolver.resolve(for: IncomeExpenseCoordinatorProtocol.self)
    }
    private var coordinatorDelegate: OldAnalysisAreaCoordinatorDelegate {
        self.dependenciesResolver.resolve(for: OldAnalysisAreaCoordinatorDelegate.self)
    }
    private var configuration: IncomeExpenseConfiguration {
        return self.dependenciesResolver.resolve(for: IncomeExpenseConfiguration.self)
    }
    
    private lazy var accountTransactionsByMonth: GetAccountMonthTransactionsUseCase = {
        GetAccountMonthTransactionsUseCase(dependenciesResolver: dependenciesResolver)
    }()
    
    private lazy var useCaseHandler: UseCaseHandler = {
        dependenciesResolver.resolve(for: UseCaseHandler.self)
    }()
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension IncomeExpensePresenter: IncomeExpensePresenterProtocol {
    func showBalanceDetailForEntity(_ entity: BalanceItem) {
        if let balanceTransaction = viewModel?.transactionFromBalanceItem(entity),
            let selectedTransaction = balanceTransaction.selectedTransaction, let transactions = balanceTransaction.balanceTransactionsEntity {
            coordinatorDelegate.showTransactionDetailFromBalanceEntities(transactions, selectedTransaction: selectedTransaction)
        }
    }
    
    var monthLiteral: String {
        let monthDate = self.configuration.selectedMonthlyBalanceRepresentable.date
        return dateToString(date: monthDate, outputFormat: .MMMM) ?? ""
    }
    
    func viewDidLoad() {
        self.view?.toggleSegmentToOperation(self.configuration.selectedMovementType)
        let input = GetAccountsMonthAccountTransactionsInput(date: self.configuration.selectedMonthlyBalanceRepresentable.date)
        _ = accountTransactionsByMonth.setRequestValues(requestValues: input)
        UseCaseWrapper(with: accountTransactionsByMonth, useCaseHandler: self.useCaseHandler,
           onSuccess: { (results) in
            let viewModel = IncomeExpenseViewModel(balanceTransactions: results.items,
                                                  selectedDate: self.configuration.selectedMonthlyBalanceRepresentable.date,
                                                  balanceType: self.configuration.selectedMovementType)
            self.viewModel = viewModel
            self.view?.updateViewModel(viewModel)
        }, onError: { error in
            print(error)
        })
        trackScreen()
    }
    
    func didSelectMenu() {
        self.coordinatorDelegate.didSelectMenu()
    }
    
    func didSelectDismiss() {
        self.coordinator.dismiss()
    }
}

extension IncomeExpensePresenter: AutomaticScreenTrackable {
    
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
    
    var trackerPage: OldAnalysisAreaBalancePage {
        return OldAnalysisAreaBalancePage()
    }
}
