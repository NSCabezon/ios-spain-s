class PersonalAreaIconedCellViewModel: GroupableCellViewModel<PersonalAreaIconedTableCell> {
    var icon: PersonalAreaIcon
    var title: LocalizedStylableText?
    
    init(icon: PersonalAreaIcon, title: LocalizedStylableText?, dependencies: PresentationComponent) {
        self.icon = icon
        self.title = title
        super.init(dependencies: dependencies)
    }
    
    override func bind(viewCell: PersonalAreaIconedTableCell) {
        super.bind(viewCell: viewCell)
        
        viewCell.icon = icon
        viewCell.title = title
    }
}
