import Foundation
import CoreFoundationLib
import OpenCombine
import CoreDomain

// swiftlint:disable large_tuple
enum LoanTransactionDetailState: State {
    case idle
    case transactionsLoaded((list: [LoanTransactionRepresentable],
                             loan: LoanRepresentable,
                             detailConfig: LoanTransactionDetailConfigurationRepresentable))
    case transactionsSelected((selected: LoanTransactionRepresentable, loan: LoanRepresentable))
    case transationDetailLoaded((detail: LoanTransactionDetailRepresentable,
                                 transaction: LoanTransactionRepresentable,
                                 loan: LoanRepresentable))
    case actionsLoaded((actions: [LoanTransactionDetailActionRepresentable], loan: LoanRepresentable))
    case pdfDataLoaded((pdfData: Data,
                        transaction: LoanTransactionRepresentable,
                        loan: LoanRepresentable))
    case isLoading(Bool)
    case errorReceived
}
// swiftlint:enable large_tuple

final class LoanTransactionDetailViewModel: DataBindable {
    @BindingOptional var loan: LoanRepresentable?
    @BindingOptional var transactionList: [LoanTransactionRepresentable]?
    private var selectedTransaction: LoanTransactionRepresentable?
    private var selectedTransactionDetail: LoanTransactionDetailRepresentable?
    private let dependencies: LoanTransactionDetailDependenciesResolver
    private let stateSubject = CurrentValueSubject<LoanTransactionDetailState, Never>(.idle)
    private let loadTransactionDetailSubject = PassthroughSubject<(LoanTransactionRepresentable, LoanRepresentable), Never>()
    private let loadDetailSubject = PassthroughSubject<LoanRepresentable, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    var state: AnyPublisher<LoanTransactionDetailState, Never>
    var dataBinding: DataBinding {
        return dependencies.resolve()
    }
    private lazy var getLoanTransactionDetailUseCase: GetLoanTransactionDetailUseCase = {
        return dependencies.resolve()
    }()
    
    init(dependencies: LoanTransactionDetailDependenciesResolver) {
        self.dependencies = dependencies
        state = stateSubject.eraseToAnyPublisher()
        self.selectedTransaction = dataBinding.get()
    }
    
    func viewDidLoad() {
        subscribeLoadTransactionList()
        subscribeLoadTransactionDetail()
        if let selectedTransaction = selectedTransaction {
            subscribeLoadTransactionDetailActions(transaction: selectedTransaction)
        }
        if let selected = self.selectedTransaction, let loan = self.loan {
            loadTransactionDetailSubject.send((selected, loan))
        }
        subscribeLoadTransactionDetail()
        subscribeLoanDetail()
        trackScreen()
    }
    
    func didSelectGoBack() {
        coordinator.dismiss()
    }
    
    func didSelectOpenMenu() {
        coordinator.didSelectMenu()
    }
    
    func didSelectTransaction(_ transaction: LoanTransactionDetail) {
        selectedTransaction = transaction.transaction
        selectedTransactionDetail = transaction.transactionDetail
        loadTransactionDetailSubject.send((transaction.transaction, transaction.loan))
    }
    
    func didSelectAction(_ actionType: LoanTransactionDetailActionType, transactionDetail: LoanTransactionDetail) {
        switch actionType {
        case .share:
            self.doShare()
        case .showDetail:
            loadDetailSubject.send(transactionDetail.loan)
        case .pdfExtract:
            self.loadPDFInfo(for: transactionDetail)
        case .partialAmortization:
            self.coordinator.didSelectLoanPartialAmortization(transaction: transactionDetail.transaction,
                                                              loan: transactionDetail.loan)
        default:
            self.coordinator.didSelectAction(actionType,
                                             transaction: transactionDetail.transaction,
                                             loan: transactionDetail.loan)
        }
    }
    
    func showPDF(_ data: Data, transaction: LoanTransactionRepresentable, loan: LoanRepresentable) {
        self.coordinator.didSelectAction(.pdfExtract(data),
                                         transaction: transaction,
                                         loan: loan)
    }
}

private extension LoanTransactionDetailViewModel {
    var coordinator: LoanTransactionDetailCoordinator {
        return dependencies.resolve()
    }
    
    var getDetailConfigurationUseCase: GetLoanTransactionDetailConfigurationUseCase {
        return dependencies.external.resolve()
    }
    
    var getLoanTransactionDetailActionUseCase: GetLoanTransactionDetailActionUseCase {
        return dependencies.external.resolve()
    }
    
    var getLoanPDFInfoUseCase: GetLoanPDFInfoUseCase {
        return dependencies.external.resolve()
    }
    
    var getLoanDetailUsecase: GetLoanDetailUsecase {
        return dependencies.external.resolve()
    }
}

private extension LoanTransactionDetailViewModel {
    func subscribeLoadTransactionList() {
        guard let loan = self.loan,
        let list = self.transactionList else { return }
        transactionDetailConfigurationPublisher()
            .sink { [unowned self] detailConfiguration in
                self.stateSubject.send(.transactionsLoaded((list: list, loan: loan, detailConfig: detailConfiguration)))
                self.loadSelectedTransaction()
            }
            .store(in: &subscriptions)
    }
    
    func subscribeLoadTransactionDetail() {
        transactionDetailPublisher()
            .sink { [unowned self] detail in
            guard let loan = self.loan,
                  let selected = self.selectedTransaction,
                  let detail = detail else { return }
            self.selectedTransactionDetail = detail
            self.stateSubject.send(.transationDetailLoaded((detail, selected, loan)))
        }
        .store(in: &subscriptions)
    }
    
    func subscribeLoadTransactionDetailActions(transaction: LoanTransactionRepresentable) {
        guard let loan = self.loan else { return }
        transactionDetailActionsPublisher(transaction: transaction)
            .sink { [unowned self] actions in
                self.stateSubject.send(.actionsLoaded((actions, loan)))
            }
            .store(in: &subscriptions)
    }
    
    func loadSelectedTransaction() {
        guard let loan = self.loan,
        let selected = self.selectedTransaction else { return }
        stateSubject.send(.transactionsSelected((selected: selected, loan: loan)))
    }
    
    func subscribeLoanDetail() {
        loanDetailPublisher()
            .sink { (result) in
                guard let detail = result?.1,
                      let loan = result?.0 else { return }
                self.coordinator.didSelectShowLoanDetail(with: loan, detail: detail)
            }.store(in: &subscriptions)
    }
    
    func loadPDFInfo(for transactionDetail: LoanTransactionDetail) {
        guard let receiptId = transactionDetail.transaction.receiptId
        else { return self.stateSubject.send(.errorReceived) }
        stateSubject.send(.isLoading(true))
        loanPDFInfoPublisher(receiptId: receiptId)
            .sink { [unowned self] data in
                guard let data = data else { return self.stateSubject.send(.errorReceived) }
                self.stateSubject.send(.isLoading(false))
                self.stateSubject.send(.pdfDataLoaded((data, transactionDetail.transaction, transactionDetail.loan)))
            }
            .store(in: &subscriptions)
    }
    
    func doShare() {
        guard let loan = self.loan,
              let selected = self.selectedTransaction,
              let detail = self.selectedTransactionDetail else { return }
        self.coordinator.doShare(for: self.getShareable(loan: loan, transaction: selected, transactionDetail: detail))
        trackEvent(.share, parameters: [:])
    }
}

// MARK: Publishers
private extension LoanTransactionDetailViewModel {
    func transactionDetailPublisher() -> AnyPublisher<LoanTransactionDetailRepresentable?, Never> {
        return loadTransactionDetailSubject
            .flatMap { [unowned self] (transaction, loan) in
                getLoanTransactionDetailUseCase
                    .fetchLoanTransactionDetail(loan: loan, transaction: transaction)
                    .map { $0 }
                    .replaceError(with: nil)
            }
            .receive(on: Schedulers.main)
            .eraseToAnyPublisher()
    }
    
    func transactionDetailConfigurationPublisher() -> AnyPublisher<LoanTransactionDetailConfigurationRepresentable, Never> {
        return getDetailConfigurationUseCase
            .fetchLoanTransactionDetailConfiguration()
            .receive(on: Schedulers.main)
            .eraseToAnyPublisher()
    }
    
    func transactionDetailActionsPublisher(transaction: LoanTransactionRepresentable) -> AnyPublisher<[LoanTransactionDetailActionRepresentable], Never> {
        getLoanTransactionDetailActionUseCase
            .fetchLoanTransactionDetailActions(transaction: transaction)
            .receive(on: Schedulers.main)
            .eraseToAnyPublisher()
    }
    
    func loanPDFInfoPublisher(receiptId: String) -> AnyPublisher<Data?, Never> {
        getLoanPDFInfoUseCase
            .fetchLoanPDFInfo(receiptId: receiptId)
            .receive(on: Schedulers.main)
            .eraseToAnyPublisher()
    }
    
    func loanDetailPublisher() -> AnyPublisher<(LoanRepresentable, LoanDetailRepresentable)?, Never> {
        return loadDetailSubject
            .flatMap { [unowned self] loan in
                self.getLoanDetailUsecase
                    .fechDetailPublisher(loan: loan)
                    .map {(loan: loan, detail: $0)}
                    .replaceError(with: nil)
            }.receive(on: Schedulers.main)
            .eraseToAnyPublisher()
    }
}

private extension LoanTransactionDetailViewModel {
    func getShareable(loan: LoanRepresentable,
                      transaction: LoanTransactionRepresentable,
                      transactionDetail: LoanTransactionDetailRepresentable) -> AnySharable {
        let shareBuilder = LoanTransactionDetailStringBuilder()
            .add(description: loan.alias ?? "")
            .add(alias: transaction.alias)
            .add(amount: transaction.formattedAmount)
            .add(operationDate: transaction.operationDate)
            .add(bookingDate: transaction.annotationDate)
            .add(capitalAmount: transactionDetail.formattedCapitalAmount)
            .add(interestAmount: transactionDetail.formattedInterestAmount)
            .add(recipientAccountNumber: transactionDetail.recipientAccountNumber)
            .add(recipientData: transactionDetail.recipientData)
        return AnySharable(shareBuilder.build())
    }
    
    struct AnySharable: Shareable {
        private let stringToShare: String
        
        init(_ stringToShare: String) {
            self.stringToShare = stringToShare
        }
        
        func getShareableInfo() -> String {
            return stringToShare
        }
    }
}

// MARK: Analytics
extension LoanTransactionDetailViewModel: AutomaticScreenActionTrackable {
    var trackerManager: TrackerManager {
        dependencies.external.resolve()
    }

    var trackerPage: LoanTransactionDetailPage {
        LoanTransactionDetailPage()
    }
}
