//
//  MonthReceiptsPresenter.swift
//  Menu
//
//  Created by Ignacio González Miró on 09/06/2020.
//

import CoreFoundationLib

protocol MonthReceiptsPresenterProtocol: AnyObject, MenuTextWrapperProtocol {
    var view: MonthReceiptsViewProtocol? { get set }
    func viewDidLoad()
    func didSelectMenu()
    func didSelectDismiss()
    func didSelectReceipt(_ viewModel: ReceiptsViewModel)
    func didSelectItemAtIndexPath(_ indexPath: IndexPath)
}

final class MonthReceiptsPresenter {
    weak var view: MonthReceiptsViewProtocol?
    let dependenciesResolver: DependenciesResolver

    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    private var allReceipts: [ReceiptsGroupViewModel]? {
        didSet {
            guard let receipts = allReceipts else { return }
            self.view?.setAllReceipts(receipts)
        }
    }
}

private extension MonthReceiptsPresenter {
    var coordinator: MonthReceiptsCoordinatorProtocol {
        self.dependenciesResolver.resolve(for: MonthReceiptsCoordinatorProtocol.self)
    }
    
    var coordinatorDelegate: OldAnalysisAreaCoordinatorDelegate {
        self.dependenciesResolver.resolve(for: OldAnalysisAreaCoordinatorDelegate.self)
    }
    
    var configuration: MonthReceiptsConfiguration {
        return self.dependenciesResolver.resolve(for: MonthReceiptsConfiguration.self)
    }
    
    var timeManager: TimeManager {
        return self.dependenciesResolver.resolve(for: TimeManager.self)
    }
    
    var baseURLProvider: BaseURLProvider {
        return self.dependenciesResolver.resolve(for: BaseURLProvider.self)
    }

    func setReceipts() {
        let receipts = self.makeReceiptViewModels(configuration.allReceipts.receipts)
        let viewModels = receipts.sorted {
            guard let date1 = $0.executedDate, let date2 = $1.executedDate else {
                return false
            }
            return date1 > date2
        }
        let transactionsByDate: [Date: [ReceiptsViewModel]] = viewModels.reduce([:], groupReceiptsByDate)
        var allReceipts = transactionsByDate.map({
            ReceiptsGroupViewModel( date: $0.key, dateFormatted: formatedDate($0.key), receipts: $0.value)
        })
        allReceipts = allReceipts.sorted(by: { $0.date > $1.date })
        self.allReceipts = allReceipts
    }
    
    func setReceiptsDate() {
        guard let receiptDate = allReceipts?.last?.date else {
            return
        }
        view?.setReceiptDate(receiptDate)
    }
    
    func setResumeMovements() {
        guard let allMovements = self.allReceipts else {
            return
        }

        let allMovementsNumbers = getNumberAndAmountMovements(allMovements)
        view?.setAllResume(receiptNumbers: allMovementsNumbers.receiptNumbers,
                           totalAmount: allMovementsNumbers.totalAmount)
    }
    
    func getNumberAndAmountMovements(_ movements: [ReceiptsGroupViewModel]) -> (receiptNumbers: Int, totalAmount: AmountEntity) {
        let receipts = movements.flatMap { $0.receipts }
        let totalAmount = receipts
            .compactMap { $0.amountEntity.value }
            .reduce(0, +)
        return (receiptNumbers: receipts.count, totalAmount: AmountEntity(value: totalAmount))
    }
    
    func makeReceiptViewModels(_ receipts: [TimeLineReceiptEntity]?) -> [ReceiptsViewModel] {
        let viewModels = receipts?.map { (receipt) -> ReceiptsViewModel in
            return ReceiptsViewModel(receipt.ibanEntity, receipt: receipt, timeManager: timeManager, baseUrl: baseURLProvider.baseURL)
        }
        guard let list = viewModels else {
            return [ReceiptsViewModel]()
        }
        return list
    }
    
    func groupReceiptsByDate(_ groupedReceipts: [Date: [ReceiptsViewModel]], receipt: ReceiptsViewModel) -> [Date: [ReceiptsViewModel]] {
        var groupedTransactions = groupedReceipts
        guard let operationDate = receipt.executedDate else {
            return groupedTransactions
        }
        guard
            let dateByDay = groupedTransactions.keys.first(where: { $0.isSameDay(than: operationDate) }),
            let receiptsByDate = groupedTransactions[dateByDay]
            else {
                groupedTransactions[operationDate.startOfDay()] = [receipt]
                return groupedTransactions
        }
        groupedTransactions[dateByDay] = receiptsByDate + [receipt]
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
}

extension MonthReceiptsPresenter: MonthReceiptsPresenterProtocol {
    func didSelectItemAtIndexPath(_ indexPath: IndexPath) {
        if let movements = allReceipts?.flatMap({$0.receipts.flatMap({$0.receipt})}) {
            guard let viewModel = allReceipts?[indexPath.section].receipts[indexPath.row] else {
                return
            }
            if let index = movements.firstIndex(where: {$0 == viewModel.receipt}) {
                coordinator.showDetailForMovement(movements, selected: index)
            }            
         }
    }
    
    func viewDidLoad() {
        self.setReceipts()
        self.setReceiptsDate()
        self.setResumeMovements()
        trackScreen()
    }
    
    func didSelectMenu() {
        self.coordinatorDelegate.didSelectMenu()
    }
    
    func didSelectDismiss() {
        self.coordinatorDelegate.didSelectDismiss()
    }
    
    func didSelectReceipt(_ viewModel: ReceiptsViewModel) { }
}

extension MonthReceiptsPresenter: AutomaticScreenTrackable {
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
    var trackerPage: OldAnalysisAreaReceiptsPage {
        return OldAnalysisAreaReceiptsPage()
    }
}
