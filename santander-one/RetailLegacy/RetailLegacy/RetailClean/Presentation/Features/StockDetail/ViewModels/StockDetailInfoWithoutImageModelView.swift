//

import Foundation

class StockDetailInfoWithoutImageModelView: TableModelViewItem<StockDetailInfoWithoutImageTableViewCell> {
    
    private let titleInfo: LocalizedStylableText
    
    init(titleInfo: LocalizedStylableText, dependencies: PresentationComponent) {
        self.titleInfo = titleInfo
        super.init(dependencies: dependencies)
    }
    
    override func bind(viewCell: StockDetailInfoWithoutImageTableViewCell) {
        viewCell.titleLabelString = titleInfo
    }
}
