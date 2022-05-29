//

import Foundation

class StockDetailInfoTwoElementsModelView: TableModelViewItem<StockDetailInfoTwoElementsTableViewCell> {
    
    private let firstTitleInfo: LocalizedStylableText
    private let firstValueInfo: String
    private let secondTitleInfo: LocalizedStylableText
    private let secondValueInfo: String

    init(firstTitleInfo: LocalizedStylableText, firstValueInfo: String, secondTitleInfo: LocalizedStylableText, secondValueInfo: String, dependencies: PresentationComponent) {
        self.firstTitleInfo = firstTitleInfo
        self.firstValueInfo = firstValueInfo
        self.secondTitleInfo = secondTitleInfo
        self.secondValueInfo = secondValueInfo
        super.init(dependencies: dependencies)
    }
    
    override func bind(viewCell: StockDetailInfoTwoElementsTableViewCell) {
        viewCell.firstTitleLabelString = firstTitleInfo
        viewCell.firstValueLabelString = firstValueInfo
        viewCell.secondTitleLabelString = secondTitleInfo
        viewCell.secondValueLabelString = secondValueInfo
    }
}
