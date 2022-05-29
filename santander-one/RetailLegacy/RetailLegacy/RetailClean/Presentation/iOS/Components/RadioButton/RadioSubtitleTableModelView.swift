protocol UpdateIdentificable {
    var inputIdentifier: String { get }
    func updateSubtitleInfo(subtitle: LocalizedStylableText)
}

class RadioSubtitleTableModelView: GroupableCellViewModel<RadioSubtitleTableViewCell>, UpdateIdentificable {
    private var info: RadioSubtitleTableInfo
    weak private var radioTable: RadioSubtitleTable?
    let inputIdentifier: String
    
    init(inputIdentifier: String, info: RadioSubtitleTableInfo, radioTable: RadioSubtitleTable, _ privateComponent: PresentationComponent) {
        self.inputIdentifier = inputIdentifier
        self.info = info
        self.radioTable = radioTable
        super.init(dependencies: privateComponent)
    }
    
    override func bind(viewCell: RadioSubtitleTableViewCell) {
        super.bind(viewCell: viewCell)
        if let indexPath = viewCell.indexPath {
            radioTable?.configure(cell: viewCell, indexPath: indexPath, info: info)
        }
        viewCell.setAccessibilityIdentifiers(identifier: inputIdentifier)
    }
    
    func updateSubtitleInfo(subtitle: LocalizedStylableText) {
        self.info.subtitle = subtitle
    }
}
