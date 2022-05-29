//

import Foundation

class CheckViewModel: TableModelViewItem<CheckTableViewCell> {
    
    // MARK: - Public attributes
    
    let title: LocalizedStylableText
    var isSelected: Bool
    let showLine: Bool

    private var checkChanged: ((_ selected: Bool) -> Void)?

    // MARK: - Public methods
    
    init(dependencies: PresentationComponent,
         title: LocalizedStylableText,
         isSelected: Bool = false,
         showLine: Bool = false,
         checkChanged: ((_ selected: Bool) -> Void)? = nil) {

        self.title = title
        self.isSelected = isSelected
        self.showLine = showLine
        self.checkChanged = checkChanged
        super.init(dependencies: dependencies)
    }

    override func bind(viewCell: CheckTableViewCell) {
        viewCell.setSelected(isSelected)
        viewCell.setTitle(title)
        viewCell.delegate = self

        showLineIfNeed(viewCell)
    }

    private func showLineIfNeed(_ viewCell: CheckTableViewCell) {
        (showLine == true) ? viewCell.showLine() : viewCell.hideLine()
    }

}

extension CheckViewModel: CheckTableViewCellDelegate {
    
    func checkTableViewCellDidSelect() {
        isSelected = !isSelected
        checkChanged?(isSelected)
    }
}
