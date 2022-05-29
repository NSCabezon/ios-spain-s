//

import Foundation

protocol CustomizeAppSwitchAndToolTipDelegate: class {
    func switchValueChanged(inViewModel viewModel: CustomizeAppSwitchAndToolTipModelView)
}

class CustomizeAppSwitchAndToolTipModelView: CustomizeAppToolTipModelView<CustomizeAppSwitchAndToolTipTableCell> {
    var value: Bool
    weak var switchDelegate: CustomizeAppSwitchAndToolTipDelegate?
    
    init(title: LocalizedStylableText, value: Bool, message: LocalizedStylableText, switchDelegate: CustomizeAppSwitchAndToolTipDelegate, delegate: ToolTipablePresenter, dependencies: PresentationComponent) {
        self.value = value
        self.switchDelegate = switchDelegate
        super.init(title: title, message: message, delegate: delegate, dependencies: dependencies)
    }
    
    override func bind(viewCell: CustomizeAppSwitchAndToolTipTableCell) {
        super.bind(viewCell: viewCell)
        viewCell.value = value
        viewCell.switchValueChanged = { [weak self] value in
            self?.value = value
            if let thisViewModel = self {
                thisViewModel.switchDelegate?.switchValueChanged(inViewModel: thisViewModel)
            }
        }
    }
}
