//
//  MonthTransfersPresenter.swift
//  Menu
//
//  Created by David Gálvez Alonso on 03/06/2020.
//

import CoreFoundationLib

enum SelectedSection: Int {
    case all = 0
    case emmited = 1
    case received = 2
}

protocol MonthTransfersPresenterProtocol: AnyObject, MenuTextWrapperProtocol {
    var view: MonthTransfersViewProtocol? { get set }
    func viewDidLoad()
    func didSelectMenu()
    func didSelectDismiss()
    func didSelectEmitted(viewModel: TransferEmittedViewModel)
}

final class MonthTransfersPresenter {
    weak var view: MonthTransfersViewProtocol?

    let dependenciesResolver: DependenciesResolver

    private var coordinator: MonthTransfersCoordinatorProtocol {
        self.dependenciesResolver.resolve(for: MonthTransfersCoordinatorProtocol.self)
    }
    
    private var coordinatorDelegate: OldAnalysisAreaCoordinatorDelegate {
        self.dependenciesResolver.resolve(for: OldAnalysisAreaCoordinatorDelegate.self)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
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
    
    private var baseURLProvider: BaseURLProvider {
        return self.dependenciesResolver.resolve(for: BaseURLProvider.self)
    }
    
    private var timeManager: TimeManager {
        return self.dependenciesResolver.resolve(for: TimeManager.self)
    }
    
    private var configuration: MonthTransfersConfiguration {
        return self.dependenciesResolver.resolve(for: MonthTransfersConfiguration.self)
    }
}

private extension MonthTransfersPresenter {
    
    func setTypeOfTransfers() {
        view?.setSelectedTransfer(configuration.selectedTransfer)
        let allTransfers = configuration.allTransfers
        if configuration.selectedTransfer == .bizumEmitted || configuration.selectedTransfer == .bizumReceived {
            let total = [allTransfers.bizumsIn, allTransfers.bizumsOut]
            setTransfers(totalTransfers: total)
        } else {
            let total = [allTransfers.transfersIn, allTransfers.transfersOut, allTransfers.transfersScheduled]
            setTransfers(totalTransfers: total)
        }
    }

    func groupTransactionsByDate(_ groupedTransactions: [Date: [TransferEmittedWithColorViewModel]], transaction: TransferEmittedWithColorViewModel) -> [Date: [TransferEmittedWithColorViewModel]] {
        var groupedTransactions = groupedTransactions
        guard let operationDate = transaction.transferEmitted.executedDate else { return groupedTransactions }
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
            .toStringFromCurrentLocale(date: date,
                                       outputFormat: .eeee)?.camelCasedString ?? ""
        dateString.append(" | \(weekDayString)")
        if date.isDayInToday() {
            return localized("product_label_todayTransaction", [StringPlaceholder(.date, dateString)])
        } else {
            return LocalizedStylableText(text: dateString, styles: nil)
        }
    }
    
    func setTransferDate() {
        guard let transferDate = allTransfers?.last?.date else { return }
        view?.setTransferDate(transferDate)
    }
    
    func setResumeMovements() {
        guard let allMovements = self.allTransfers else { return }
        guard let emittedMovements = self.emittedTransfers else { return }
        guard let receivedMovements = self.receivedTransfers else { return }

        let allMovementsNumbers = getNumberAndAmountMovements(allMovements)
        let emittedMovementsNumbers = getNumberAndAmountMovements(emittedMovements)
        let receivedMovementsNumbers = getNumberAndAmountMovements(receivedMovements)

        view?.setAllResume(transfersNumbers: allMovementsNumbers.transfersNumbers, totalAmount: allMovementsNumbers.totalAmount)
        view?.setEmittedResume(transfersNumbers: emittedMovementsNumbers.transfersNumbers, totalAmount: emittedMovementsNumbers.totalAmount)
        view?.setReceivedResume(transfersNumbers: receivedMovementsNumbers.transfersNumbers, totalAmount: receivedMovementsNumbers.totalAmount)
    }
    
    func getNumberAndAmountMovements(_ movements: [EmittedGroupViewModel]) -> (transfersNumbers: Int, totalAmount: AmountEntity) {
        let transfers = movements.flatMap {$0.transfer}
        let totalAmount = transfers.compactMap { $0.transferEmitted.transfer.amountEntity.value }.reduce(0, +)
        return (transfersNumbers: transfers.count, totalAmount: AmountEntity(value: totalAmount))
    }
    
    func setTransfers(totalTransfers: [[TransferEntityProtocol]?]) {
        let viewModels = totalTransfers.flatMap { makeTransferViewModels($0) }
        
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
    
    func makeTransferViewModels(_ transferEmitted: [TransferEntityProtocol]?) -> [TransferEmittedWithColorViewModel] {
        let colorsEngine: ColorsByNameEngine = self.dependenciesResolver.resolve()
        
        let viewColorsModels = transferEmitted?.map { (transfer) -> TransferEmittedWithColorViewModel in
            let colorType = colorsEngine.get(transfer.beneficiary ?? "")
            let colorsByNameViewModel = ColorsByNameViewModel(colorType)
            let transferVm = TransferEmittedViewModel((transfer as? TimeLineEntityConformable)?.ibanEntity, transfer: transfer, timeManager: timeManager, baseUrl: baseURLProvider.baseURL)
            
            return TransferEmittedWithColorViewModel(transferEmitted: transferVm,
                                                     colorsByNameViewModel: colorsByNameViewModel,
                                                     highlightedText: nil)
        }
        return viewColorsModels ?? [TransferEmittedWithColorViewModel]()
    }
    
    func filterGroupedTransferViewModels(_ viewModels: [EmittedGroupViewModel], byType transferType: KindOfTransfer) -> [EmittedGroupViewModel] {
        return viewModels.compactMap {
            let transfers = ($0.transfer.filter { (viewModel) in
                viewModel.transferEmitted.transferType == transferType })
            guard !transfers.isEmpty else { return nil }
            return EmittedGroupViewModel( date: $0.date,
                                          dateFormatted: formatedDate($0.date),
                                          transfers: transfers)
        }
    }
}

// MARK: - presenterProtocol

extension MonthTransfersPresenter: MonthTransfersPresenterProtocol {
    
    func viewDidLoad() {
        setTypeOfTransfers()
        setTransferDate()
        setResumeMovements()
        trackScreen()
    }
    
    func didSelectMenu() {
        self.coordinatorDelegate.didSelectMenu()
    }
    
    func didSelectDismiss() {
        self.coordinator.dismiss()
    }
    
    func didSelectEmitted(viewModel: TransferEmittedViewModel) {
        guard let selectedIndex = self.view?.selectedSegmentIndex, let selectedSegment = SelectedSection(rawValue: selectedIndex) else {
            return
        }
        switch selectedSegment {
        case .emmited:
            if let movements = emittedTransfers.flatMap({$0.flatMap({$0.transfer.flatMap({$0.transferEmitted})})}) {
                if let selectedItemIndex = indexOfItem(viewModel: viewModel, inMovements: movements) {
                    coordinator.showDetailForMovement(movements, selected: selectedItemIndex)
                }
            }
        case .received:
            if let movements = receivedTransfers.flatMap({$0.flatMap({$0.transfer.flatMap({$0.transferEmitted})})}) {
                if let selectedItemIndex = indexOfItem(viewModel: viewModel, inMovements: movements) {
                    coordinator.showDetailForMovement(movements, selected: selectedItemIndex)
                }
            }
        case .all:
            if let movements = allTransfers.flatMap({$0.flatMap({$0.transfer.flatMap({$0.transferEmitted})})}) {
                if let selectedItemIndex = indexOfItem(viewModel: viewModel, inMovements: movements) {
                    coordinator.showDetailForMovement(movements, selected: selectedItemIndex)
                }
            }
        }
    }
    
    func indexOfItem(viewModel: TransferEmittedViewModel, inMovements movements: [TransferEmittedViewModel]) -> Int? {
        return movements.firstIndex(where: {$0 == viewModel}) ?? nil
    }
}

extension MonthTransfersPresenter: TrackerScreenProtocol {
    var screenId: String? {
        if configuration.selectedTransfer == .bizumEmitted || configuration.selectedTransfer == .bizumReceived {
            return OldAnalysisAreaBizumPage().page
        }
        return OldAnalysisAreaTransfersPage().page
    }
    
    var emmaScreenToken: String? {
        return nil
    }
}

extension MonthTransfersPresenter: ScreenTrackable {
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
}
