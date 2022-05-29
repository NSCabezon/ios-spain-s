import Foundation

class MaxMinItemViewModel: TableModelViewItem<MaxMinCellItem> {
    private let title: LocalizedStylableText?
    private let isHidden: Bool
    
    init(_ title: LocalizedStylableText, isHidden: Bool, _ privateComponent: PresentationComponent) {
        self.title = title
        self.isHidden = isHidden
        super.init(dependencies: privateComponent)
    }
    
    override func bind(viewCell: MaxMinCellItem) {
        viewCell.labelTextString = title
        viewCell.isHidden = isHidden
    }
}
