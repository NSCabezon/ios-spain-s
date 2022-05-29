import UIKit

class ItemTableViewModel: TableModelViewItem<ItemTableViewCell> {
    let title: String?
    let link: String?
    
    init(title: String?, link: String?, dependencies: PresentationComponent) {
        self.title = title
        self.link = link
        super.init(dependencies: dependencies)
    }
    
    override func bind(viewCell: ItemTableViewCell) {
        viewCell.setTitle(title ?? "")
    }
} 
