class PersonalAreaLinkCellViewModel: GroupableCellViewModel<PersonalAreaLinkTableCell> {
    
    var title: LocalizedStylableText?
    var value: String?
    
    init(title: LocalizedStylableText?, value: String?, dependencies: PresentationComponent) {
        self.title = title
        self.value = value
        super.init(dependencies: dependencies)
    }
    
    override func bind(viewCell: PersonalAreaLinkTableCell) {
        super.bind(viewCell: viewCell)
        viewCell.title = title
        viewCell.value = value
    }
}
