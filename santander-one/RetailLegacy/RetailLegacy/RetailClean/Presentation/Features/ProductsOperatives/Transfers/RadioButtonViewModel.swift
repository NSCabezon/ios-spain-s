//

import Foundation

protocol RadioButtonSelectable: class {
    var isSelected: Bool { get set }
}

class RadioButtonViewModel<Cell: RadioButtonCell>: TableModelViewItem<Cell>, RadioButtonSelectable {
    
    private let title: LocalizedStylableText
    var isSelected: Bool
    
    init(title: LocalizedStylableText, isSelected selected: Bool, dependencies: PresentationComponent) {
        self.title = title
        self.isSelected = selected
        super.init(dependencies: dependencies)
    }
    
    override func bind(viewCell: Cell) {
        viewCell.title = title
        viewCell.setMarked(isMarked: isSelected)
    }
}
