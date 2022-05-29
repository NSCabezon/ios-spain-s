import UIKit

class ChangeLogFirstViewModel: GroupableCellViewModel<ChangeLogFirstViewCellItem> {
    
    var title: String
    
    init(title: String, dependencies: PresentationComponent, isFirst: Bool, isLast: Bool) {
        self.title = title
        super.init(dependencies: dependencies)
        self.isLast = isLast
        self.isFirst = isFirst
    }
    
    override func bind(viewCell: ChangeLogFirstViewCellItem) {
        super.bind(viewCell: viewCell)
        viewCell.title = title
    }
    
}
