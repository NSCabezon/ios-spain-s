//
//  NotificationsPresenter.swift
//  Cards
//
//  Created by Cristobal Ramos Laina on 04/11/2020.
//

import Foundation
import CoreFoundationLib

protocol NotificationsPresenterProtocol {
    var view: NotificationsViewProtocol? { get set }
    func didSelectNext()
    func didSelectBack()
    func viewWillAppear()
    func openSettings()
    func requestPushNotificationAccess()
}

final class NotificationsPresenter {
    weak var view: NotificationsViewProtocol?
    private let dependenciesResolver: DependenciesResolver
    private var pushNotificationPermissionManager: PushNotificationPermissionsManagerProtocol? {
        return self.dependenciesResolver.resolve(forOptionalType: PushNotificationPermissionsManagerProtocol.self)
    }

    private var coordinator: CardBoardingCoordinatorProtocol {
        return dependenciesResolver.resolve(for: CardBoardingCoordinatorProtocol.self)
    }
    
    private var configuration: CardboardingConfiguration {
        dependenciesResolver.resolve(for: CardboardingConfiguration.self)
    }
    
    private var cardBoardingStepTracker: CardBoardingStepTracker {
        return self.dependenciesResolver.resolve(for: CardBoardingStepTracker.self)
    }
    
    private var coordinatorDelegate: CardBoardingCoordinatorDelegate {
        return self.dependenciesResolver.resolve(for: CardBoardingCoordinatorDelegate.self)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension NotificationsPresenter: NotificationsPresenterProtocol {
    func viewWillAppear() {
        self.checkForEnabledNotifications()
    }
    
    func openSettings() {
        self.coordinatorDelegate.openSettings()
    }

    func requestPushNotificationAccess() {
        self.pushNotificationPermissionManager?.isAlreadySet { [weak self] (result) in
            if result {
                Async.main {
                    self?.view?.askForSettings()
                }
            } else {
                self?.pushNotificationPermissionManager?.requestAccess { (result) in
                    Async.main {
                        self?.view?.pushNotificationRequestResult(result: result)
                    }
                }
            }
        }
    }
    
    func didSelectBack() {
        self.coordinator.didSelectGoBackwards()
    }
    
    func didSelectNext() {
        self.coordinator.didSelectGoFoward()
    }
}

extension NotificationsPresenter {
    /**
     Ask the systems about the app's ability to schedule and receive local and remote notifications
     
     This method check if the app is authorized and also if any of this values are *enabled* in **UNNotificationSettings** : .alertSetting, .badgeSetting, .lockScreenSetting, .notificationCenterSetting, .soundSetting.
     */
    func checkForEnabledNotifications() {
        self.pushNotificationPermissionManager?.isNotificationsEnabled { [weak self] (result) in
            Async.main {
                self?.view?.pushNotificationsEnabledResult(result: result)
            }
        }
    }
}
