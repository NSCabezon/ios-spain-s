import UIKit

protocol OperativeStackButtonDelegate: class {
    func selectAmount(at index: Int)
}

class OperativeStackViewModel: TableModelViewItem<OperativeStackViewTableViewCell> {
    let elements: [String]
    private weak var actionDelegate: OperativeStackButtonDelegate?
    var tagSelected: Int?
    
    init(elements: [String], actionDelegate: OperativeStackButtonDelegate, dependencies: PresentationComponent) {
        self.elements = elements
        self.actionDelegate = actionDelegate
        super.init(dependencies: dependencies)
    }
    
    override func bind(viewCell: OperativeStackViewTableViewCell) {
        viewCell.elements = elements
        viewCell.selectAmount = { [weak self] tag in
            guard let strongSelf = self else {
                return
            }
            strongSelf.tagSelected = tag
            strongSelf.actionDelegate?.selectAmount(at: tag)
        }
        viewCell.highlightButtons(tag: tagSelected)
    }
}
