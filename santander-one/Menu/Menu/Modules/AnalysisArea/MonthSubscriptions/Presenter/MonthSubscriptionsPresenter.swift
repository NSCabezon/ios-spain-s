//
//  MonthSubscriptionsPresenter.swift
//  Menu
//
//  Created by Laura González on 11/06/2020.
//

import CoreFoundationLib

protocol MonthSubscriptionsPresenterProtocol: AnyObject, MenuTextWrapperProtocol {
    var view: MonthSubscriptionsViewProtocol? { get set }
    func viewDidLoad()
    func didSelectMenu()
    func didSelectDismiss()
    func didSelectItemAtIndexPath(_ indexPath: IndexPath)
}

final class MonthSubscriptionsPresenter {
    weak var view: MonthSubscriptionsViewProtocol?
    
    let dependenciesResolver: DependenciesResolver
    
    private var coordinator: MonthSubscriptionsCoordinatorProtocol {
        self.dependenciesResolver.resolve(for: MonthSubscriptionsCoordinatorProtocol.self)
    }
    
    private var coordinatorDelegate: OldAnalysisAreaCoordinatorDelegate {
        self.dependenciesResolver.resolve(for: OldAnalysisAreaCoordinatorDelegate.self)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    private var subscriptions: [SubscriptionsGroupViewModel]? {
        didSet {
            guard let subscriptions = subscriptions else { return }
            self.view?.setSubscriptions(subscriptions)
        }
    }
    
    private var timeManager: TimeManager {
        return self.dependenciesResolver.resolve(for: TimeManager.self)
    }
    
    private var configuration: MonthSubscriptionsConfiguration {
        return self.dependenciesResolver.resolve(for: MonthSubscriptionsConfiguration.self)
    }
}

// MARK: - Private Methods

private extension MonthSubscriptionsPresenter {
    func groupSubscriptionsByDate(_ groupedSubscriptions: [Date: [MonthSubscriptionsViewModel]], subscription: MonthSubscriptionsViewModel) -> [Date: [MonthSubscriptionsViewModel]] {
        var groupedSubscriptions = groupedSubscriptions
        guard let operationDate = subscription.executedDate else { return groupedSubscriptions }
        guard
            let dateByDay = groupedSubscriptions.keys.first(where: { $0.isSameDay(than: operationDate) }),
            let subscriptionsByDate = groupedSubscriptions[dateByDay]
            else {
                groupedSubscriptions[operationDate.startOfDay()] = [subscription]
                return groupedSubscriptions
        }
        groupedSubscriptions[dateByDay] = subscriptionsByDate + [subscription]
        return groupedSubscriptions
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
    
    func setSubscriptionDate() {
        guard let subscriptionDate = subscriptions?.last?.date else { return }
        view?.setSubscriptionDate(subscriptionDate)
    }
    
    func setResume() {
        guard let subscriptions = self.subscriptions else { return }
        let subscriptionsData = getNumberAndAmountMovements(subscriptions)
        view?.setResume(subscriptionsData.subscriptionsNumbers, totalAmount: subscriptionsData.totalAmount)
    }
    
    func getNumberAndAmountMovements(_ movements: [SubscriptionsGroupViewModel]) -> (subscriptionsNumbers: Int, totalAmount: AmountEntity) {
        let subscriptions = movements.flatMap {$0.subscription}
        let totalAmount = subscriptions.compactMap { $0.subscription.amount }.reduce(0, +)
        return (subscriptionsNumbers: subscriptions.count, totalAmount: AmountEntity(value: totalAmount))
    }
    
    func setSubscriptions() {
        let total = self.makeSubscriptionViewModel(configuration.allSubscriptions.subscriptions)
        let viewModels = total.sorted { $0 > $1 }
        let subscriptionsByDate: [Date: [MonthSubscriptionsViewModel]] = viewModels.reduce([:], groupSubscriptionsByDate)
        var subscriptions = subscriptionsByDate.map({
            SubscriptionsGroupViewModel( date: $0.key, dateFormatted: formatedDate($0.key), subscription: $0.value)
        })
        subscriptions = subscriptions.sorted(by: { $0.date > $1.date })
        
        self.subscriptions = subscriptions
    }
    
    func makeSubscriptionViewModel(_ subscriptionEntity: [TimeLineSubscriptionEntity]?) -> [MonthSubscriptionsViewModel] {
        let viewModels = subscriptionEntity?.map { (subscription) -> MonthSubscriptionsViewModel in
            return MonthSubscriptionsViewModel(subscription.ibanEntity, subscription: subscription, timeManager: timeManager)
        }
        return viewModels ?? [MonthSubscriptionsViewModel]()
    }
}

// MARK: - Presenter Protocol

extension MonthSubscriptionsPresenter: MonthSubscriptionsPresenterProtocol {
    func didSelectItemAtIndexPath(_ indexPath: IndexPath) {
        if let movements = subscriptions?.flatMap({$0.subscription.flatMap({$0.subscription})}) {
            coordinator.showDetailForMovement(movements, selected: indexPath.row)
        }
    }
    
    func viewDidLoad() {
        setSubscriptions()
        setSubscriptionDate()
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

extension MonthSubscriptionsPresenter: AutomaticScreenTrackable {
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
    var trackerPage: OldAnalysisAreaSubscriptionsPage {
        return OldAnalysisAreaSubscriptionsPage()
    }
}
