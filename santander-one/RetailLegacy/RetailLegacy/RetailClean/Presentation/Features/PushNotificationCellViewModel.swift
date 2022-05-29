import UIKit
import CoreFoundationLib

class PushNotificationCellViewModel: GroupableCellViewModel<PushNotificationTableViewCell> {
    private let title: LocalizedStylableText?
    private let message: LocalizedStylableText
    private let date: LocalizedStylableText
    private let read: Bool
    var isEditionActivated: Bool
    var isCheckSelected: Bool? = false
    let pushNotification: PushNotification
    
    init(title: LocalizedStylableText?, message: LocalizedStylableText, date: LocalizedStylableText, read: Bool, isEditionActivated: Bool, pushNotification: PushNotification, dependencies: PresentationComponent) {
        self.title = title
        self.message = message
        self.date = date
        self.read = read
        self.pushNotification = pushNotification
        self.isEditionActivated = isEditionActivated
        super.init(dependencies: dependencies)
    }
    
    override func bind(viewCell: PushNotificationTableViewCell) {
        super.bind(viewCell: viewCell)
        viewCell.cellSelected = read
        viewCell.title = title
        viewCell.message = message
        viewCell.date = date
        viewCell.read = read
        viewCell.isEdition = isEditionActivated
        viewCell.checkSelected = isCheckSelected
        viewCell.markAsNew = dependencies.stringLoader.getString("notificationMailbox_label_new")
    }
    
    func checkChanged() {
        guard var checkSelect = isCheckSelected else { return }
        checkSelect = !checkSelect
        isCheckSelected = checkSelect
    }
}
