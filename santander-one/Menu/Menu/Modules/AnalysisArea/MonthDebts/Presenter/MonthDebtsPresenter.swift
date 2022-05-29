//
//  MonthDebtsPresenter.swift
//  Menu
//
//  Created by Laura González on 05/06/2020.
//

import CoreFoundationLib

protocol MonthDebtsPresenterProtocol: AnyObject, MenuTextWrapperProtocol {
    var view: MonthDebtsViewProtocol? { get set }
    func viewDidLoad()
    func didSelectMenu()
    func didSelectDismiss()
    func didSelectItemAtIndexPath(_ indexPath: IndexPath)
}

final class MonthDebtsPresenter {
    weak var view: MonthDebtsViewProtocol?
    
    let dependenciesResolver: DependenciesResolver
    
    private var coordinator: MonthDebtsCoordinatorProtocol {
        self.dependenciesResolver.resolve(for: MonthDebtsCoordinatorProtocol.self)
    }
    
    private var coordinatorDelegate: OldAnalysisAreaCoordinatorDelegate {
        self.dependenciesResolver.resolve(for: OldAnalysisAreaCoordinatorDelegate.self)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    private var allDebts: [DebtsGroupViewModel]? {
        didSet {
            guard let allDebts = allDebts else { return }
            self.view?.setAllDebts(allDebts)
        }
    }
    
    private var timeManager: TimeManager {
        return self.dependenciesResolver.resolve(for: TimeManager.self)
    }
    
    private var configuration: MonthDebtsConfiguration {
        return self.dependenciesResolver.resolve(for: MonthDebtsConfiguration.self)
    }
}

// MARK: - Private Methods

private extension MonthDebtsPresenter {
    func groupDebtsByDate(_ groupedDebts: [Date: [MonthDebtsViewModel]], debt: MonthDebtsViewModel) -> [Date: [MonthDebtsViewModel]] {
        var groupedDebts = groupedDebts
        guard let operationDate = debt.executedDate else { return groupedDebts }
        guard
            let dateByDay = groupedDebts.keys.first(where: { $0.isSameDay(than: operationDate) }),
            let debtsByDate = groupedDebts[dateByDay]
            else {
                groupedDebts[operationDate.startOfDay()] = [debt]
                return groupedDebts
        }
        groupedDebts[dateByDay] = debtsByDate + [debt]
        return groupedDebts
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
    
    func setDebtDate() {
        guard let debtDate = allDebts?.last?.date else { return }
        view?.setDebtDate(debtDate)
    }
    
    func setResume() {
        guard let allDebts = self.allDebts else { return }
        let debtMap = allDebts.flatMap {$0.debt}
        let totalAmount = debtMap.compactMap { $0.debt.amount }.reduce(0, +)
        view?.setResume(AmountEntity(value: totalAmount))
    }
    
    func setDebts() {
        let total = self.makeDebtViewModel(configuration.allDebts.reducedDebt)
        let viewModels = total.sorted { $0 > $1 }
        let debtsByDate: [Date: [MonthDebtsViewModel]] = viewModels.reduce([:], groupDebtsByDate)
        var allDebts = debtsByDate.map({
            DebtsGroupViewModel( date: $0.key, dateFormatted: formatedDate($0.key), debt: $0.value)
        })
        allDebts = allDebts.sorted(by: { $0.date > $1.date })
        
        self.allDebts = allDebts
    }
    
    func makeDebtViewModel(_ debtEntity: [TimeLineDebtEntity]?) -> [MonthDebtsViewModel] {
        let viewModels = debtEntity?.map { (debt) -> MonthDebtsViewModel in
            return MonthDebtsViewModel(debt.ibanEntity, debt: debt, timeManager: timeManager)
        }
        return viewModels ?? [MonthDebtsViewModel]()
    }
}

// MARK: - Presenter Protocol

extension MonthDebtsPresenter: MonthDebtsPresenterProtocol {
    func didSelectItemAtIndexPath(_ indexPath: IndexPath) {
        if let movements = allDebts?.flatMap({$0.debt.map({$0.debt})}) {
            guard let viewModel = allDebts?[indexPath.section].debt[indexPath.row] else {
                return
            }
            if let index = movements.firstIndex(where: {$0 == viewModel.debt}) {
                coordinator.showDetailForMovement(movements, selected: index)
            }
        }
    }
    
    func viewDidLoad() {
        setDebts()
        setDebtDate()
        setResume()
        trackScreen()
    }
    
    func didSelectMenu() {
        self.coordinatorDelegate.didSelectMenu()
    }
    
    func didSelectDismiss() {
        self.coordinator.dismiss()
    }
}

extension MonthDebtsPresenter: AutomaticScreenTrackable {
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
    var trackerPage: OldAnalysisAreaDebtsPage {
        return OldAnalysisAreaDebtsPage()
    }
}
