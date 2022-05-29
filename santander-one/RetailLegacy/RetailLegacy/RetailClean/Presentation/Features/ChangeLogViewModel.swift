import UIKit

class ChangeLogViewModel: GroupableCellViewModel<ChangeLogViewCellItem> {
    
    var descriptionText: String

    init(description: String, dependencies: PresentationComponent, isFirst: Bool, isLast: Bool) {
        self.descriptionText = description
        super.init(dependencies: dependencies)
        self.isLast = isLast
        self.isFirst = isFirst
    }
    
    override func bind(viewCell: ChangeLogViewCellItem) {
        super.bind(viewCell: viewCell)
        viewCell.value = descriptionText
        viewCell.isSeparatorVisible = !isLast
    }
    
}
