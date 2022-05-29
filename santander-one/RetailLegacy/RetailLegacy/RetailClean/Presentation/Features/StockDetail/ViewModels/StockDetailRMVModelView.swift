//

import Foundation

class StockDetailRMVModelView: TableModelViewItem<StockDetailRMVTableViewCell> {
    
    private let firstText: LocalizedStylableText
    private let secondText: LocalizedStylableText
    private let thirdText: LocalizedStylableText
    private let fourthText: LocalizedStylableText
    private let fifthText: LocalizedStylableText
    private let isHeader: Bool
    
    init(firstText: LocalizedStylableText, secondText: LocalizedStylableText, thirdText: LocalizedStylableText, fourthText: LocalizedStylableText, fifthText: LocalizedStylableText, isHeader: Bool, dependencies: PresentationComponent) {
        self.firstText = firstText
        self.secondText = secondText
        self.thirdText = thirdText
        self.fourthText = fourthText
        self.fifthText = fifthText
        self.isHeader = isHeader
        super.init(dependencies: dependencies)
    }
    
    override func bind(viewCell: StockDetailRMVTableViewCell) {
        viewCell.firstLabelString = firstText
        viewCell.secondLabelString = secondText
        viewCell.thirdLabelString = thirdText
        viewCell.fourthLabelString = fourthText
        viewCell.fifthLabelString = fifthText
        viewCell.isHeader = isHeader
    }
}
