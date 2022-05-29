//

import Foundation

class StockDetailInfoOneElementModelView: TableModelViewItem<StockDetailInfoOneElementTableViewCell> {
    
    private let firstTitleInfo: LocalizedStylableText
    private let firstValueInfo: String

    init(firstTitleInfo: LocalizedStylableText, firstValueInfo: String, dependencies: PresentationComponent) {
        self.firstTitleInfo = firstTitleInfo
        self.firstValueInfo = firstValueInfo
        super.init(dependencies: dependencies)
    }
    
    override func bind(viewCell: StockDetailInfoOneElementTableViewCell) {
        viewCell.firstTitleLabelString = firstTitleInfo
        viewCell.firstValueLabelString = firstValueInfo
    }
}
