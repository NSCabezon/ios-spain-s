// swiftlint:disable class_delegate_protocol
// disable because PullOfferActionsPresenter is a class protocol
protocol PersonalAreaCMCCellViewModelDelegate: ToolTipablePresenter {
    var tooltipMessage: LocalizedStylableText { get }
}
// swiftlint:enable class_delegate_protocol

class PersonalAreaCMCCellViewModel: GroupableCellViewModel<PersonalAreaCMCStatusTableCell> {
    var title: LocalizedStylableText?
    var value: (text: LocalizedStylableText?, operative: Bool)
    weak var delegate: PersonalAreaCMCCellViewModelDelegate?
    
    init(title: LocalizedStylableText?, value: (text: LocalizedStylableText?, operative: Bool), dependencies: PresentationComponent) {
        self.title = title
        self.value = value
        super.init(dependencies: dependencies)
    }
    
    override func bind(viewCell: PersonalAreaCMCStatusTableCell) {
        super.bind(viewCell: viewCell)
        viewCell.title = title
        viewCell.value = value
        viewCell.iconButtonTouched = { [weak self, weak viewCell] in
            guard let thisViewModel = self, let delegate = thisViewModel.delegate else {
                return
            }
            viewCell?.showToolTip(description: delegate.tooltipMessage, inPresenter: delegate)
        }
    }
}
