class PersonalWithoutManagerTitleViewModel: TableModelViewItem<PersonalWithoutManagerTitleViewCell> {
    private let title: LocalizedStylableText
    private let subtitle: LocalizedStylableText
    
    init(dependencies: PresentationComponent, title: LocalizedStylableText, subtitle: LocalizedStylableText) {
        self.title = title
        self.subtitle = subtitle
        super.init(dependencies: dependencies)
    }
    
    override func bind(viewCell: PersonalWithoutManagerTitleViewCell) {
        viewCell.titleLabel.set(localizedStylableText: title)
        viewCell.subtitleLabel.set(localizedStylableText: subtitle)
    }
    
}
