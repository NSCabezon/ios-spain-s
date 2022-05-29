//
//  InboxNotificationDetailPresenter.swift
//  Pods
//
//  Created by José María Jiménez Pérez on 18/5/21.
//  

import CoreFoundationLib
import ESCommons

protocol InboxNotificationDetailPresenterProtocol: MenuTextWrapperProtocol {
    var view: InboxNotificationDetailViewProtocol? { get set }
    func viewWillAppear()
    func dismissViewController()
    func openMenu()
    func didSelectShareOfType(_ type: ShareCase)
    func didTapOnDelete()
}

final class InboxNotificationDetailPresenter {
    weak var view: InboxNotificationDetailViewProtocol?
    let dependenciesResolver: DependenciesResolver
    private let notification: PushNotification?
    private lazy var inboxMessagesManager: InboxMessagesManager = {
        self.dependenciesResolver.resolve()
    }()

    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.notification = dependenciesResolver.resolve(for: InboxNotificationDetailConfiguration.self).pushNotification
    }
}

private extension InboxNotificationDetailPresenter {
    var coordinator: InboxNotificationDetailCoordinatorProtocol {
        return self.dependenciesResolver.resolve()
    }
}

extension InboxNotificationDetailPresenter: InboxNotificationDetailPresenterProtocol {
    func viewWillAppear() {
        guard let notification = notification else { return }
        switch notification.type {
        case .salesforce:
            self.inboxMessagesManager.markAsRead(notification: notification)
        case .twinpush: break
        }
        trackScreen()
        let viewModel = NotificationDetailViewModel(title: notification.title, message: notification.message, date: notification.calculateInboxTime(stringLoader: dependenciesResolver.resolve(), timeManager: dependenciesResolver.resolve()))
        view?.showNotification(viewModel)
    }
    
    func dismissViewController() {
        coordinator.dismissViewController()
    }
    
    func openMenu() {
        coordinator.openMenu()
    }
    
    func didSelectShareOfType(_ type: ShareCase) {
        guard type.canShare() else {
            self.view?.showError(localizedKey: type.shareNotAvailableErrorKey)
            return
        }
        switch type {
        case .sms:
            trackEvent(.shareSms)
        case .mail:
            trackEvent(.shareMail)
        case .share:
            trackEvent(.shareOther)
        }
        view?.shareWithCase(type, delegate: self)
    }
    
    func didTapOnDelete() {
        guard let notification = self.notification else { return }
        trackEvent(.delete)
        self.inboxMessagesManager.delete(notification: [notification]) { [weak self] _ in
            self?.coordinator.goBack()
        }
    }
}

extension InboxNotificationDetailPresenter: AutomaticScreenActionTrackable {
    var trackerPage: InboxNotificationDetailPage {
        return InboxNotificationDetailPage()
    }
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve()
    }
}

extension InboxNotificationDetailPresenter: Shareable {
    func getShareableInfo() -> String {
        guard let notification = notification else { return "" }
        return "\(notification.title)\n\(notification.message)"
    }
}
