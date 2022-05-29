import UIKit

class SettingsPGModelView: TableModelViewItem<SettingsPGViewCell> {

    override  func bind(viewCell: SettingsPGViewCell) {
        viewCell.setTitle(dependencies.stringLoader.getString("pg_link_setPg"))
    }
    
    override var height: CGFloat? {
        return 65.0
    }
}
