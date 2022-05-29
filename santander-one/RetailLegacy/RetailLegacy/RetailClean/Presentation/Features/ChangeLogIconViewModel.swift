import UIKit

class ChangeLogIconViewModel: TableModelViewItem<ChangeLogIconViewCellItem> {
    
    var title: String
    var iconName: String
    var buttonText: String
    var showUpgrade: Bool
    var buttonCallback: (() -> Void)?

    init(title: String, iconName: String, buttonText: String, showUpgrade: Bool, buttonCallback: (() -> Void)?, dependencies: PresentationComponent) {
        self.title = title
        self.iconName = iconName
        self.showUpgrade = showUpgrade
        self.buttonText = buttonText
        self.buttonCallback = buttonCallback
        super.init(dependencies: dependencies)
    }
    
    override func bind(viewCell: ChangeLogIconViewCellItem) {
        viewCell.title = title
        viewCell.iconImageName = iconName
        viewCell.showUpgradeButton = showUpgrade
        viewCell.buttonText = buttonText
        viewCell.buttonCallback = buttonCallback
    }
    
}
