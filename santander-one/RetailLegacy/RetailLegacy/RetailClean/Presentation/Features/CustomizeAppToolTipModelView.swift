import UIKit

class CustomizeAppToolTipModelView<T: CustomizeAppToolTipTableCell>: GroupableCellViewModel<T> {
    
    let title: LocalizedStylableText
    let message: LocalizedStylableText
    let forcedArrowDirection: UIPopoverArrowDirection?
    weak var delegate: ToolTipablePresenter?
    
    init(title: LocalizedStylableText, message: LocalizedStylableText, forcedArrowDirection: UIPopoverArrowDirection? = nil, delegate: ToolTipablePresenter, dependencies: PresentationComponent) {
        self.title = title
        self.message = message
        self.forcedArrowDirection = forcedArrowDirection
        self.delegate = delegate
        super.init(dependencies: dependencies)
    }
    
    override func bind(viewCell: T) {
        super.bind(viewCell: viewCell)
        viewCell.title = title
        viewCell.iconButtonTouched = { [weak self, weak viewCell] in
            guard let thisViewModel = self, let delegate = thisViewModel.delegate else {
                return
            }
            viewCell?.showToolTip(description: thisViewModel.message, inPresenter: delegate, forcedDirection: self?.forcedArrowDirection)
        }
    }
}
