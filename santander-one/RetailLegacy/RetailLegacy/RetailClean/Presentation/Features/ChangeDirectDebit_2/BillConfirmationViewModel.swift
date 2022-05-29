class BillConfirmationViewModel: TableModelViewItem<BillConfirmationTableViewCell> {
    private let name: String
    private let entityIdentifier: String
    
    init(name: String, identifier: String, privateComponent: PresentationComponent) {
        self.name = name
        self.entityIdentifier = identifier
        super.init(dependencies: privateComponent)
    }
    
    override func bind(viewCell: BillConfirmationTableViewCell) {
        viewCell.set(name: name.uppercased(), identifier: entityIdentifier)
    }
}
