import CoreFoundationLib

protocol InboxNotificationPresenterProtocol: class, MenuTextWrapperProtocol {
    var view: InboxNotificationViewProtocol? { get set }
    func viewWillAppear()
    func dismissViewController()
    func openMenu()
    func loadNotifications()
    func deleteNotifications(notifications: [PushNotificationConformable])
    func deleteNotification(notification: PushNotificationEntity, atIndex index: Int)
    func didSelectOffer()
    func showDetail(for: PushNotificationViewModel, atIndex index: Int)
    func trackClickAll()
    func deleteSwipe(notificationViewModel: PushNotificationViewModel)
}

public protocol InboxNotificationDataSourceProtocol: class {
    func getInbox(completion: @escaping(_ list: [PushNotificationConformable]?) -> Void)
    func delete(notification: [PushNotificationConformable], completion: @escaping(Bool) -> Void)
}

final class InboxNotificationPresenter {
    weak var view: InboxNotificationViewProtocol?
    weak var datasource: InboxNotificationDataSourceProtocol?
    let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    var useCaseHandler: UseCaseHandler {
        self.dependenciesResolver.resolve(for: UseCaseHandler.self)
    }
    
    var coordinator: InboxNotificationCoordinatorProtocol {
        self.dependenciesResolver.resolve(for: InboxNotificationCoordinatorProtocol.self)
    }
    
    var pullOfferUseCase: GetPullOffersUseCase {
        return self.dependenciesResolver.resolve(for: GetPullOffersUseCase.self)
    }
    
    var locations: [PullOfferLocation] {
        return [PullOfferLocation(stringTag: InboxPullOffers.inboxSetup,
                                  hasBanner: false,
                                  pageForMetrics: trackerPage.page)]
    }
    
    var offers: [PullOfferLocation: OfferEntity] = [:]
    
    func viewWillAppear() {
        view?.showLoading { [weak self] in
            self?.loadPullOffers { [weak self] in
                self?.loadNotifications()
            }
        }
        trackScreen()
    }
    
    func loadPullOffers(_ completion: @escaping () -> Void) {
        Scenario(useCase: self.pullOfferUseCase, input: GetPullOffersUseCaseInput(locations: locations))
            .execute(on: self.useCaseHandler)
            .onSuccess { [weak self] result in
                self?.offers = result.pullOfferCandidates
                completion()
            }
            .onError { _ in
                completion()
            }
    }
    
    // MARK: - Helpers
    private func calculateInboxTime(date: Date?) -> String {
        let currentDate = Date().toLocalTime()
        guard let notificationDate = date else { return "" }
        let inboxLiteral: String
        var calendar = Calendar.current
        calendar.timeZone = .current
        
        let components = calendar.dateComponents([.day, .hour, .minute], from: notificationDate, to: currentDate)
        
        guard let days = components.day,
              let hours = components.hour,
              let minutes = components.minute else { return "" }
        
        if days > 0 {
            guard let day = dateToString(date: notificationDate, outputFormat: .d_MMM_yyyy),
                  let hour =  dateToString(date: notificationDate, outputFormat: .HHmm) else {
                return ""
            }
            inboxLiteral = "\(day) \(hour)h."
        } else if hours > 0 {
            inboxLiteral = localized("notificationMailbox_label_untilHours",
                                     [StringPlaceholder(.number, "\(hours)")]).text
        } else {
            let minutesFinal = minutes > 0 ? minutes : 0
            inboxLiteral = localized("notificationMailbox_label_untilMinutes",
                                     [StringPlaceholder(.number, "\(minutesFinal)")]).text
        }
        
        return inboxLiteral
    }
}

extension InboxNotificationPresenter: InboxNotificationPresenterProtocol {
    func loadNotifications() {
        guard let datasource = self.dependenciesResolver.resolve(forOptionalType: InboxNotificationDataSourceProtocol.self) else {
            self.view?.dismissLoading()
            return
        }
        datasource.getInbox(completion: { [weak self] notifications in
            guard  let notifications = notifications else { return }
            let viewModel = notifications.map {
                PushNotificationViewModel(
                    title: $0.title,
                    message: $0.message,
                    date: self?.calculateInboxTime(date: $0.date) ?? "",
                    read: $0.isRead, entity: $0) }
            self?.view?.didLoadNotifications(viewModel: viewModel)
            DispatchQueue.main.async {
                self?.view?.dismissLoading()
            }
        })
    }
    
    func deleteNotifications(notifications: [PushNotificationConformable]) {
        guard let datasource = self.dependenciesResolver.resolve(forOptionalType: InboxNotificationDataSourceProtocol.self) else { return }
        view?.showLoading()
        datasource.delete(notification: notifications, completion: { [weak self] _ in
            self?.view?.dismissLoading()
            self?.view?.didDeleteNotifications()
        })
        trackEvent(.delete, parameters: [:])
    }
    
    func deleteNotification(notification: PushNotificationEntity, atIndex index: Int) {
        guard let datasource = self.dependenciesResolver.resolve(forOptionalType: InboxNotificationDataSourceProtocol.self) else { return }
        view?.showLoading()
        datasource.delete(notification: [notification], completion: { _ in
            self.view?.dismissLoading()
            self.view?.didDeleteNotification(atIndex: index)
        })
    }
    
    func didSelectOffer() {
        let offer = offers.location(key: InboxPullOffers.inboxSetup)?.offer
        coordinator.didSelectOffer(offer)
    }
    
    func dismissViewController() {
        coordinator.dismissViewController()
    }
    
    func openMenu() {
        coordinator.openMenu()
    }
    
    func showDetail(for viewModel: PushNotificationViewModel, atIndex index: Int) {
        self.coordinator.didSelectNotification(viewModel.entity)
        view?.markAsRead(atIndex: index)
    }
    
    func trackClickAll() {
        trackEvent(.selectAll, parameters: [:])
    }
    
    func deleteSwipe(notificationViewModel: PushNotificationViewModel) {
        guard let datasource = self.dependenciesResolver.resolve(forOptionalType: InboxNotificationDataSourceProtocol.self) else { return }
        view?.showLoading()
        datasource.delete(notification: [notificationViewModel.entity], completion: { _ in
            self.view?.dismissLoading()
        })
        trackEvent(.deleteSwipe, parameters: [:])
    }
}

extension InboxNotificationPresenter: AutomaticScreenActionTrackable {
    var trackerPage: InboxNotificationPage {
        return InboxNotificationPage()
    }
    
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
}
