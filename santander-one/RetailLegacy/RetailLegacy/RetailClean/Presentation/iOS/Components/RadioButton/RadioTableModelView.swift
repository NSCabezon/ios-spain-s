class RadioTableModelView: TableModelViewItem<RadioTableViewCell> {
    
    private let info: RadioTableInfo
    weak private var radioTable: RadioTable?
    private var bordered: Bool
    var inputIdentifier: String?
    
    init(info: RadioTableInfo, radioTable: RadioTable, _ privateComponent: PresentationComponent, bordered: Bool = true, inputIdentifier: String? = nil) {
        self.info = info
        self.radioTable = radioTable
        self.bordered = bordered
        self.inputIdentifier = inputIdentifier
        super.init(dependencies: privateComponent)
    }
    
    override func bind(viewCell: RadioTableViewCell) {
        if let indexPath = viewCell.indexPath {
            if bordered {
                viewCell.setupBorder()
            }
            radioTable?.configure(cell: viewCell, indexPath: indexPath, info: info)
            if let inputIdentifier = inputIdentifier {
                viewCell.setAccessibilityIdentifiers(identifier: inputIdentifier)
            }
        }
    }
}
