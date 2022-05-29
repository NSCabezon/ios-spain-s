//

import Foundation

enum OperativeSeparatorColor {
    case normal
    case background
    case paleGrey
}

class OperativeSeparatorModelView: TableModelViewItem<OperativeSeparatorTableViewCell> {
    
    let insets: Insets?
    let heightSepartor: Double
    let color: OperativeSeparatorColor
    
    init(heightSepartor: Double = 1, color: OperativeSeparatorColor = .normal, insets: Insets? = nil, privateComponent: PresentationComponent) {
        self.insets = insets
        self.heightSepartor = heightSepartor
        self.color = color
        super.init(dependencies: privateComponent)
    }
    
    override func bind(viewCell: OperativeSeparatorTableViewCell) {
        viewCell.heightSepartor = heightSepartor
        viewCell.applyColor(color: color)
        viewCell.applyInsets(insets: insets)
    }
}
