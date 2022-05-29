class PersonalWithoutManagerSectionTitleViewModel: TableModelViewItem<PersonalWithoutManagerSectionTitleViewCell> {
    private let title: LocalizedStylableText
    
    init(dependencies: PresentationComponent, title: LocalizedStylableText) {
        self.title = title
        super.init(dependencies: dependencies)
    }
    
    override func bind(viewCell: PersonalWithoutManagerSectionTitleViewCell) {
        viewCell.titleLabel.set(localizedStylableText: title)
    }
    
}
