import CoreFoundationLib
import UnitTestCommons
@testable import Cards

final class NotificationViewMock: NSObject, NotificationsViewProtocol {

    var spyAskedForSettings: SpyableObject<Bool> = SpyableObject(value: false)
    var spyPushNotificationRequestResult: SpyableObject<Bool> = SpyableObject(value: false)
    var spyPushNotificationsEnabledResult: SpyableObject<Bool> = SpyableObject(value: false)
    
    var isFirstStep: Bool = false
    var associatedLoadingView: UIViewController = UIViewController()
    var associatedOldDialogView: UIViewController  = UIViewController()
    var associatedGenericErrorDialogView: UIViewController = UIViewController()
    
    func askForSettings() {
        spyAskedForSettings.value = true
    }
    
    func pushNotificationRequestResult(result: Bool) {
        spyPushNotificationRequestResult.value = result
    }
    
    func pushNotificationsEnabledResult(result: Bool) {
        self.spyPushNotificationsEnabledResult.value = result
    }
}
