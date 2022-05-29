import Foundation
import CoreFoundationLib
import SANLegacyLibrary

protocol GetLastBillSuperUseCaseDelegateDelegate: AnyObject {
    func didFinishLastBillSuccessfully(with response: LastBillResponse)
    func didFinishLastBillWithError(_ error: String?)
}

final class GetLastBillSuperUseCaseDelegateHandler: SuperUseCaseDelegate {
    var allowMoreRequest: Bool = true
    var fromDate: Date = Date()
    var months: Int = 0
    var accountBills: [AccountEntity: [LastBillEntity]] = [:]
    weak var delegate: GetLastBillSuperUseCaseDelegateDelegate?
    
    func onSuccess() {
        let response = LastBillResponse(
            accountBills: accountBills,
            fromDate: fromDate,
            allowMoreRequest: allowMoreRequest,
            months: months
        )
        self.delegate?.didFinishLastBillSuccessfully(with: response)
    }
    
    func onError(error: String?) {
        self.delegate?.didFinishLastBillWithError(error)
    }
}

final class GetLastBillSuperUseCase: SuperUseCase<GetLastBillSuperUseCaseDelegateHandler> {
    private let dependenciesResolver: DependenciesResolver
    private let handlerDelegate: GetLastBillSuperUseCaseDelegateHandler
    private var monthStack: MonthStack
    private var toDate: Date
    private var filters: BillFilter? {
        didSet {
            guard self.filters == nil else { return }
            let appConfig = self.dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
            let monthLimit = appConfig.getString(BillsConstants.monthsLimit) ?? "2"
            self.handlerDelegate.months = 0
            self.handlerDelegate.allowMoreRequest = true
            self.monthStack = MonthStack(months: Int(monthLimit) ?? 2)
        }
    }
    
    weak var delegate: GetLastBillSuperUseCaseDelegateDelegate? {
        get { return self.handlerDelegate.delegate }
        set { self.handlerDelegate.delegate = newValue }
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.toDate = Date()
        self.dependenciesResolver = dependenciesResolver
        let appConfig = self.dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
        let monthLimit = appConfig.getString(BillsConstants.monthsLimit) ?? "2"
        self.monthStack = MonthStack(months: Int(monthLimit) ?? 2)
        self.handlerDelegate = GetLastBillSuperUseCaseDelegateHandler()
        let useCaseHandler = self.dependenciesResolver.resolve(for: UseCaseHandler.self)
        super.init(useCaseHandler: useCaseHandler, delegate: self.handlerDelegate)
    }
    
    func setToDate(_ date: Date) {
        self.toDate = date
    }
    
    func setFilters(_ filters: BillFilter?) {
        self.filters = filters
    }
    
    override func setupUseCases() {
        self.handlerDelegate.accountBills = [:]
        if let filter = self.filters {
            self.loadLastBillApplyingFilters(filter)
        } else {
            self.cancelRequestIfNeed()
            self.loadLastBillFromStartDate()
        }
    }
}

private extension GetLastBillSuperUseCase {
    func cancelRequestIfNeed() {
        guard monthStack.isEmpty else { return }
        self.handlerDelegate.allowMoreRequest = false
        self.cancel()
    }
    
    func loadLastBillFromStartDate() {
        guard !monthStack.isEmpty else { return }
        let accountUseCase = self.dependenciesResolver.resolve(for: GetAccountUseCase.self)
        let months = self.monthStack.nextMonths
        self.handlerDelegate.months += months
        self.add(accountUseCase) { [weak self] result in
            result.accounts.forEach { account in
                self?.loadLastBillForAccount(account, in: months)
            }
        }
    }
    
    func loadLastBillForAccount(_ account: AccountEntity, in months: Int) {
        let useCase = self.dependenciesResolver.resolve(for: GetLastBillUseCase.self)
        let dateRange = BillFilter.DateRange(startDate: toDate.addMonth(months: -months), endDate: toDate, index: 0)
        let filter = BillFilter(account: account, billStatus: .unknown, dateRange: dateRange)
        let input = GetLastBillUseCaseInput(pagination: nil, filter: filter)
        self.add(useCase.setRequestValues(requestValues: input), isMandatory: false) { result in
            self.handlerDelegate.accountBills[account] = result.bills
            self.handlerDelegate.fromDate = result.fromDate
        }
    }
    
    func loadLastBillApplyingFilters(_ filter: BillFilter) {
        guard filter.account == nil else {
            self.loadLastBillWithFilters(filter)
            return
        }
        let accountUseCase = self.dependenciesResolver.resolve(for: GetAccountUseCase.self)
        self.add(accountUseCase) { [weak self] result in
            result.accounts.forEach { account in
                let newFilter = BillFilter(account: account, billStatus: filter.billStatus, dateRange: filter.dateRange)
                self?.loadLastBillWithFilters(newFilter)
            }
        }
    }
    
    func loadLastBillWithFilters(_ filter: BillFilter) {
        let useCase = self.dependenciesResolver.resolve(for: GetLastBillUseCase.self)
        let input = GetLastBillUseCaseInput(pagination: nil, filter: filter)
        guard let account = filter.account else { return }
        self.add(useCase.setRequestValues(requestValues: input), isMandatory: false) { result in
            self.handlerDelegate.accountBills[account] = result.bills
            self.handlerDelegate.fromDate = result.fromDate
        }
    }
}
