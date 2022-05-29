//
//  HistoricalEmittedPresenter.swift
//  Transfer
//
//  Created by Cristobal Ramos Laina on 01/04/2020.
//

import Foundation
import CoreFoundationLib
import UI

protocol HistoricalTransferPresenterProtocol: SuperUseCaseDelegate, MenuTextWrapperProtocol {
    var view: HistoricalTransferViewProtocol? { get set }
    func viewDidLoad()
    func didSelectMenu()
    func didSelectDismiss()
    func didSearchText(_ text: String, inTable idx: Int)
    func clearSearch()
    func showTransferDetail(viewModel: TransferViewModel)
    func didChangedSegmented(_ index: Int)
}

final class HistoricalTransferPresenter {
    weak var view: HistoricalTransferViewProtocol?
    let dependenciesResolver: DependenciesResolver
    private var selectedAccount: AccountEntity?
    private let stringTransferTypeAll = "todos"
    private let stringTransferTypeEmitted = "emitidas"
    private let stringTransferTypeReceived = "recibidas"
    
    private var coordinator: HistoricalTransferCoordinatorProtocol {
        return self.dependenciesResolver.resolve(for: HistoricalTransferCoordinatorProtocol.self)
    }
    
    private var coordinatorDelegate: TransferHomeModuleCoordinatorDelegate {
        return self.dependenciesResolver.resolve(for: TransferHomeModuleCoordinatorDelegate.self)
    }
    
    private var useCaseHandler: UseCaseHandler {
        return self.dependenciesResolver.resolve(for: UseCaseHandler.self)
    }
    
    private var globalPositionV2UseCase: GetGlobalPositionV2UseCase {
        return dependenciesResolver.resolve(for: GetGlobalPositionV2UseCase.self)
    }
    
    private var timer: Timer?
    private var searchedTableIndex: Int?
    private var searchedTerm: String = ""
    
    private var allTransfers: [EmittedGroupViewModel]? {
        didSet {
            guard let allTransfers = allTransfers else { return }
            self.view?.setAllTransfers(allTransfers)
        }
    }
    private var receivedTransfers: [EmittedGroupViewModel]? {
        didSet {
            guard let received = receivedTransfers else { return }
            self.view?.setReceivedTransfers(received)
        }
    }
    private var emittedTransfers: [EmittedGroupViewModel]? {
        didSet {
            guard let emitted = emittedTransfers else { return }
            self.view?.setEmittedTransfers(emitted)
        }
    }

    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    private var accountsUseCase: GetTransfersHomeUseCase {
        return self.dependenciesResolver.resolve(for: GetTransfersHomeUseCase.self)
    }
    
    lazy var getTransferUseCase: GetTransferUseCaseProtocol? = {
        return self.dependenciesResolver.resolve(forOptionalType: GetTransferUseCaseProtocol.self)
    }()
    private var timeManager: TimeManager {
        return self.dependenciesResolver.resolve(for: TimeManager.self)
    }
    
    private var baseURLProvider: BaseURLProvider {
        return self.dependenciesResolver.resolve(for: BaseURLProvider.self)
    }
}

// MARK: - getInfo & sort methods

private extension HistoricalTransferPresenter {
    
    func loadAccounts(_ completion: @escaping([AccountEntity]) -> Void) {
        self.view?.showLoadingView()
        MainThreadUseCaseWrapper(
            with: accountsUseCase,
            onSuccess: { [weak self] response in
                self?.selectedAccount = response.configuration.selectedAccount
                completion(response.accounts)
        })
    }
    
    func loadGlobalPositionV2(accounts: [AccountEntity], _ completion: @escaping() -> Void) {
        UseCaseWrapper(with: self.globalPositionV2UseCase,
            useCaseHandler: useCaseHandler,
                onSuccess: {_ in
                completion()
            }, onError: {_ in
                completion()
            }
        )
    }
    
    func loadEmittedTransfer(for accounts: [AccountEntity]) {
        guard let useCase = self.dependenciesResolver.resolve(forOptionalType: GetAllTransfersUseCaseProtocol.self) else { return }
        let input = GetAllTransfersUseCaseInput(accounts: accounts)
        Scenario(useCase: useCase.setRequestValues(requestValues: input), input: input)
            .execute(on: self.dependenciesResolver.resolve())
            .onSuccess { [weak self] output in
                self?.handleTransferEmitted(output.0, received: output.1)
            }
    }
    
    func handleTransferEmitted(_ transferEmitted: [AccountEntity: [TransferEmittedEntity]], received: [AccountEntity: [TransferReceivedEntity]]) {
        let total = self.makeTransferViewModels(transferEmitted) + self.makeTransferViewModels(received)
        let viewModels = total.sorted { $0 > $1 }
        
        let transactionsByDate: [Date: [TransferEmittedWithColorViewModel]] = viewModels.reduce([:], groupTransactionsByDate)
        var allTransfers = transactionsByDate.map({ EmittedGroupViewModel( date: $0.key,
                                                                           dateFormatted: formatedDate($0.key),
                                                                           transfers: $0.value)
        })
        allTransfers = allTransfers.sorted(by: { $0.date > $1.date })
        
        let emitted = filterGroupedTransferViewModels(allTransfers, byType: .emitted)
        let received = filterGroupedTransferViewModels(allTransfers, byType: .received)

        self.allTransfers = allTransfers
        self.emittedTransfers = emitted
        self.receivedTransfers = received
    }
    
    func filterGroupedTransferViewModels(_ viewModels: [EmittedGroupViewModel], byType tranferType: KindOfTransfer) -> [EmittedGroupViewModel] {
        return viewModels.compactMap {
            let transfers = ($0.transfer.filter { (viewModel) in viewModel.viewModel.transferType == tranferType })
            guard !transfers.isEmpty else { return nil }
            return EmittedGroupViewModel( date: $0.date,
                                          dateFormatted: formatedDate($0.date),
                                          transfers: transfers)
        }
    }
    
    func makeTransferViewModels(_ transferEmitted: [AccountEntity: [TransferEntityProtocol]]) -> [TransferEmittedWithColorViewModel] {
        let colorsEngine: ColorsByNameEngine = self.dependenciesResolver.resolve()
        
        let viewColorsModels = transferEmitted.reduce([TransferEmittedWithColorViewModel]()) { (result, next) in
            let account = next.key
            let viewModels: [TransferEmittedWithColorViewModel] = next.value.map {
                let colorType = colorsEngine.get($0.beneficiary ?? "")
                let colorsByNameViewModel = ColorsByNameViewModel(colorType)
                return TransferEmittedWithColorViewModel(viewModel: TransferViewModel(account,
                                                                                      transfer: $0,
                                                                                      timeManager: timeManager,
                                                                                      baseUrl: baseURLProvider.baseURL),
                                                         colorsByNameViewModel: colorsByNameViewModel,
                                                         highlightedText: nil)
            }
            return result + viewModels
        }
        return viewColorsModels
    }
    
    func groupTransactionsByDate(_ groupedTransactions: [Date: [TransferEmittedWithColorViewModel]], transaction: TransferEmittedWithColorViewModel) -> [Date: [TransferEmittedWithColorViewModel]] {
        var groupedTransactions = groupedTransactions
        guard let operationDate = transaction.viewModel.executedDate else { return groupedTransactions }
        guard
            let dateByDay = groupedTransactions.keys.first(where: { $0.isSameDay(than: operationDate) }),
            let transactionsByDate = groupedTransactions[dateByDay]
            else {
                groupedTransactions[operationDate.startOfDay()] = [transaction]
                return groupedTransactions
        }
        groupedTransactions[dateByDay] = transactionsByDate + [transaction]
        return groupedTransactions
    }
    
    func formatedDate(_ date: Date) -> LocalizedStylableText {
        var dateString =  dependenciesResolver.resolve(for: TimeManager.self)
            .toStringFromCurrentLocale(date: date,
                                       outputFormat: .d_MMM)?.uppercased() ?? ""
        let weekDayString = dependenciesResolver.resolve(for: TimeManager.self)
            .toString(date: date, outputFormat: .eeee)?.camelCasedString ?? ""
        dateString.append(" | \(weekDayString)")
        if date.isDayInToday() {
            return localized("product_label_todayTransaction", [StringPlaceholder(.date, dateString)])
        } else {
            return LocalizedStylableText(text: dateString, styles: nil)
        }
    }
}

// MARK: - filter methods

private extension HistoricalTransferPresenter {
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] timer in
            timer.invalidate()
            self?.filter()
        }
    }
    
    func filter() {
        guard let searchedTableIndex = searchedTableIndex else { return }
        let list = searchedTableIndex == 0 ? allTransfers :
            (searchedTableIndex == 1) ? emittedTransfers : receivedTransfers
        
        var count = 0
        let filteredList: [EmittedGroupViewModel] = (list ?? []).compactMap({ viewModel in
            var filteredTransfers: [TransferEmittedWithColorViewModel] = viewModel.transfer.compactMap {
                guard
                    $0.viewModel.transfer.beneficiary?.range(of: searchedTerm,
                                                                   options: .caseInsensitive) != nil
                        || $0.viewModel.account.getIBANShort.range(of: searchedTerm,
                                                                         options: .caseInsensitive) != nil
                    else { return nil }
                return TransferEmittedWithColorViewModel(viewModel: $0.viewModel,
                                                         colorsByNameViewModel: $0.colorsByNameViewModel,
                                                         highlightedText: self.searchedTerm)
            }
            
            guard !filteredTransfers.isEmpty else { return nil }
            count += filteredTransfers.count
            filteredTransfers = filteredTransfers.sorted { $0 > $1 }
            return EmittedGroupViewModel(date: viewModel.date,
                                         dateFormatted: formatedDate(viewModel.date),
                                         transfers: filteredTransfers)
        })
        setFilteredResults(filteredList, count: count)
    }
    
    func setFilteredResults(_ results: [EmittedGroupViewModel], count: Int) {
        guard let searchedTableIndex = searchedTableIndex else { return }
        if results.isEmpty {
            view?.setEmptySearchedText(searchedTerm)
        }
        view?.setSearchedText(searchedTerm, resultsNum: count)
        trackEvent(.filter, parameters: [.textSearch: searchedTerm])
        switch searchedTableIndex {
        case 0:
            view?.setAllTransfers(results)
        case 1:
            view?.setEmittedTransfers(results)
        case 2:
            view?.setReceivedTransfers(results)
        default:
            break
        }
    }
}

// MARK: - presenterProtocol

extension HistoricalTransferPresenter: HistoricalTransferPresenterProtocol {
    func showTransferDetail(viewModel: TransferViewModel) {
        if viewModel.transferType == .emitted {
            trackEvent(.detail)
        }
        if let transferAdapterUseCase = self.getTransferUseCase {
            Scenario(useCase: transferAdapterUseCase, input: viewModel)
                .execute(on: self.useCaseHandler)
                .onSuccess { (response) in
                    self.coordinator.gotoTransferDetailWithConfiguration(response)
                }
        } else {
            switch viewModel.transferType {
            case .emitted:
                guard let transfer = viewModel.transfer as? TransferEmittedEntity else { return }
                self.coordinatorDelegate.showTransferDetail(transfer,
                                                            fromAccount: self.selectedAccount,
                                                            toAccount: viewModel.account,
                                                            presentationBlock: { [weak self] in
                                                                self?.coordinator.gotoTransferDetailWithConfiguration($0)
                                                            })
            case .received:
                self.coordinator.gotoTransferDetailWithConfiguration(TransferDetailConfiguration.receivedConfigurationFrom(viewModel))
            }
        }
    }
    
    func viewDidLoad() {
        trackScreen()
        self.loadAccounts { [weak self] accounts in
            self?.loadGlobalPositionV2(accounts: accounts) { [weak self] in
                self?.loadEmittedTransfer(for: accounts)
            }
        }
    }
    
    func didSelectMenu() {
        self.coordinatorDelegate.didSelectMenu()
    }
    
    func didSelectDismiss() {
        self.coordinator.dismiss()
    }
    
    func didSearchText(_ text: String, inTable idx: Int) {
        timer?.invalidate()
        searchedTerm = text.trim()
        searchedTableIndex = idx
        guard !searchedTerm.isEmpty && !searchedTerm.isBlank else { return clearSearch() }
        startTimer()
    }
    
    func clearSearch() {
        timer?.invalidate()
        searchedTerm = ""
        view?.setSearchedText(searchedTerm, resultsNum: 0)
        searchedTableIndex = nil
        restoreTables()
    }
    
    func restoreTables() {
        if let allTransfers = allTransfers {
            self.view?.setAllTransfers(allTransfers)
        }
        if let received = receivedTransfers {
            self.view?.setReceivedTransfers(received)
        }
        if let emitted = emittedTransfers {
            self.view?.setEmittedTransfers(emitted)
        }
    }
    
    func didChangedSegmented(_ index: Int) {
        switch index {
        case 0: trackEvent(.type, parameters: [.historicalTypeTransfer: stringTransferTypeAll])
        case 1: trackEvent(.type, parameters: [.historicalTypeTransfer: stringTransferTypeEmitted])
        case 2: trackEvent(.type, parameters: [.historicalTypeTransfer: stringTransferTypeReceived])
        default:
            break
        }
    }
}

extension HistoricalTransferPresenter: SuperUseCaseDelegate {
    func onSuccess() {}
    
    func onError(error: String?) {}
}

extension HistoricalTransferPresenter: AutomaticScreenActionTrackable {
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
    
    var trackerPage: SendMoneyHistoryPage {
        return SendMoneyHistoryPage()
    }
}
