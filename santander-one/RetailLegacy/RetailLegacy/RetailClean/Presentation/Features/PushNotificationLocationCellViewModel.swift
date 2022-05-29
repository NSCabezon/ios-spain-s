import UIKit

class PushNotificationLocationCellViewModel: TableModelViewItem<PushNotificationLocationTableViewCell> {
    private let isEmailSms: Bool
    private let isSettings: Bool
    var actionEmailSms: (() -> Void)?
    var actionSettings: (() -> Void)?
    
    init(isEmailSms: Bool, isSettings: Bool, dependencies: PresentationComponent) {
        self.isEmailSms = isEmailSms
        self.isSettings = isSettings
        super.init(dependencies: dependencies)
    }
    
    override func bind(viewCell: PushNotificationLocationTableViewCell) {
        viewCell.emailAndSmsTitle = dependencies.stringLoader.getString("mailbox_buttom_emailAndSms")
        viewCell.settingsTitle = dependencies.stringLoader.getString("mailbox_buttom_setting")
        viewCell.isEmailSms = isEmailSms
        viewCell.isSettings = isSettings
        viewCell.actionEmailSms = actionEmailSms
        viewCell.actionSettings = actionSettings
    }
}
