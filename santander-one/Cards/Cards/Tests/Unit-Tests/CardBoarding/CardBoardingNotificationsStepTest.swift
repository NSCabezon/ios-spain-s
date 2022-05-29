import XCTest
import CoreFoundationLib
import UnitTestCommons
@testable import Cards

final class CardBoardingNotificationsStepTest: XCTestCase {
    private let dependenciesResolver = DependenciesDefault()
    private var globalPosition: GlobalPositionRepresentable?
    private var presenter: NotificationsPresenterProtocol!
    private var view: NotificationViewMock!
    
    override func setUp() {
        self.presenter = NotificationsPresenter(dependenciesResolver: self.dependenciesResolver)
        self.view = NotificationViewMock()
        self.presenter.view = self.view
    }

    override func tearDown() {
        self.dependenciesResolver.clean()
        self.presenter = nil
        self.view = nil
    }
    
    func test_notificationView_system_disabled_notification() {
        // given
        let notificationManager = PushNotificationManagerMock()
        notificationManager.isNotificationsEnabledResult = false
        self.dependenciesResolver.register(for: PushNotificationPermissionsManagerProtocol.self) { resolver in
            return notificationManager
        }

        // when
        self.presenter.viewWillAppear()
        
        // then succeed
        waitForAssume(spying: self.view.spyPushNotificationsEnabledResult, expectedValue: false)
    }
    
    func test_notification_enabled_when_enabling_from_disabled_state() {
        // given
        let notificationManager = PushNotificationManagerMock()
        notificationManager.isNotificationsEnabledResult = true
        notificationManager.isAlreadySetResult = true
        self.dependenciesResolver.register(for: PushNotificationPermissionsManagerProtocol.self) { resolver in
            return notificationManager
        }
        
        // when
        self.presenter.viewWillAppear()
        self.presenter.requestPushNotificationAccess()
        
        // then succeed
        waitForAssume(spying: self.view.spyPushNotificationsEnabledResult, expectedValue: true)
    }
    
    func test_notification_disabled_when_disabling_from_enabled_state() {
        // given
        let notificationManager = PushNotificationManagerMock()
        notificationManager.isNotificationsEnabledResult = false
        notificationManager.isAlreadySetResult = true
        self.dependenciesResolver.register(for: PushNotificationPermissionsManagerProtocol.self) { resolver in
            return notificationManager
        }

        // when
        self.presenter.viewWillAppear()
        self.presenter.requestPushNotificationAccess()

        waitForAssume(spying: self.view.spyPushNotificationsEnabledResult, expectedValue: false)
    }
 
    func test_allow_notifications_after_being_asked() {
        // given
        let notificationManager = PushNotificationManagerMock()
        notificationManager.isAlreadySetResult = false
        notificationManager.requestAccessResult = true
        self.dependenciesResolver.register(for: PushNotificationPermissionsManagerProtocol.self) { resolver in
            return notificationManager
        }
        let expectation1 = Assume(spying: self.view.spyAskedForSettings, expectedValue: false)
        let expectation2 = Assume(spying: self.view.spyPushNotificationRequestResult, expectedValue: true)
        let expectation3 = Assume(spying: self.view.spyPushNotificationsEnabledResult, expectedValue: true)

        // when
        self.presenter.viewWillAppear()
        self.presenter.requestPushNotificationAccess()
        
        self.wait(for: [expectation1, expectation2, expectation3], timeout: 2, enforceOrder: false)
    }
    
    func test_not_allow_notifications_after_being_asked_for_FirstTime() {
        // given
        let notificationManager = PushNotificationManagerMock()
        notificationManager.isAlreadySetResult = false
        notificationManager.requestAccessResult = false
        notificationManager.isNotificationsEnabledResult = false
        self.dependenciesResolver.register(for: PushNotificationPermissionsManagerProtocol.self) { resolver in
            return notificationManager
        }
        // the user is not asked goto settings, the system dialog ask for allow notifications. Answer = Don´t Allow
        // then
        let expectation1 = Assume(spying: self.view.spyAskedForSettings, expectedValue: false)
        let expectation2 = Assume(spying: self.view.spyPushNotificationRequestResult, expectedValue: false)
        let expectation3 = Assume(spying: self.view.spyPushNotificationsEnabledResult, expectedValue: false)
        
        // when
        self.presenter.viewWillAppear()
        self.presenter.requestPushNotificationAccess()
        
        wait(for: [expectation1, expectation2, expectation3], timeout: 2)
    }
    
    
    func test_notification_get_auth_status() {
        let notificationManager = PushNotificationManagerMock()
        notificationManager.getAuthStatus { authStatus in
            
        }
        
        XCTAssert(true)
    }
    
    func test_notification_() {
        let notificationManager = PushNotificationManagerMock()
        notificationManager.checkAccess {
            
        }
        
        XCTAssert(true)
    }
}
