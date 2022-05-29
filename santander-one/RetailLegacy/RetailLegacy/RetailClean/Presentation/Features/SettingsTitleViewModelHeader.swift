import UIKit

class SettingsTitleHeaderViewModel: TableModelViewHeader<SettingsTitleHeaderView> {

    var title: LocalizedStylableText
    
    init(title: LocalizedStylableText) {
        self.title = title
        super.init()
    }
    
    override func bind(viewHeader: SettingsTitleHeaderView) {
        viewHeader.setTitle(title)
    }
    
}
