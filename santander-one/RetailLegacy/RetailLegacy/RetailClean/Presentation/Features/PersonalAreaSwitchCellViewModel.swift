protocol PersonalAreaSwitchCellViewModelDelegate: class {
    func switchValueChanged(inViewModel viewModel: PersonalAreaSwitchCellViewModel)
    func switchWidgetDidChange(inViewModel viewModel: PersonalAreaSwitchCellViewModel)
    func trackEventSwitchTouchIdChange(activate: Bool)
    func trackEventSwitchWidgetChange(activate: Bool)
}

class PersonalAreaSwitchCellViewModel: GroupableCellViewModel<PersonalAreaSwitchTableCell> {
    var title: LocalizedStylableText?
    var value: Bool
    var didChangeSwitch: ((PersonalAreaSwitchCellViewModel) -> Void)?
    
    init(title: LocalizedStylableText?, value: Bool, dependencies: PresentationComponent) {
        self.title = title
        self.value = value
        super.init(dependencies: dependencies)
    }
    
    override func bind(viewCell: PersonalAreaSwitchTableCell) {
        super.bind(viewCell: viewCell)
        viewCell.title = title
        viewCell.value = value
        viewCell.switchValueChanged = { [weak self] value in
            self?.value = value
            guard let strongSelf = self else { return }
            self?.didChangeSwitch?(strongSelf)
        }
    }
}
