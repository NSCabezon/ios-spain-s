//

import Foundation

protocol OperativeBottomButtonDelegate: class {
    func actionButtonOperativeBottom()
}

class OperativeBottomButtonModelView: TableModelViewItem<OperativeBottomButtonTableViewCell> {
    
    private let title: LocalizedStylableText
    private weak var actionDelegate: OperativeBottomButtonDelegate?
    
    init(title: LocalizedStylableText, actionDelegate: OperativeBottomButtonDelegate?, privateComponent: PresentationComponent) {
        self.title = title
        self.actionDelegate = actionDelegate
        super.init(dependencies: privateComponent)
    }
    
    override func bind(viewCell: OperativeBottomButtonTableViewCell) {
        viewCell.styledText = title
        viewCell.buttonTapped = { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.actionDelegate?.actionButtonOperativeBottom()
        }
    }
}
