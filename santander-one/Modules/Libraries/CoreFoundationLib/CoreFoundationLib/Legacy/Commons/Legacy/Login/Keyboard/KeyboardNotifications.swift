import Foundation

public struct KeyboardNotifications {
    public static let globalKeyboardCreateNotification = Notification.Name(rawValue: "GlobalKeyboardCreateNotification")
}

public protocol KeyboardTextFieldResponderButtons {
    var nextButtonTitle: String { get set }
    var doneButtonTitle: String { get set }
}
